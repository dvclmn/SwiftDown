//
//  File.swift
//  
//
//  Created by Dave Coleman on 7/8/2024.
//

import Foundation
import Down
import SwiftUI
import Combine
import TestStrings

#if os(iOS)
// MARK: - SwiftDownEditor iOS
public struct SwiftDownEditor: UIViewRepresentable {
   private var debounceTime = 0.3
   @Binding var text: String {
      didSet {
         onTextChange(text)
      }
   }
   
   private(set) var isEditable: Bool = true
   private(set) var theme: Theme = Theme.BuiltIn.defaultDark.theme()
   private(set) var insetsSize: CGFloat = 0
   private(set) var autocapitalizationType: UITextAutocapitalizationType = .sentences
   private(set) var autocorrectionType: UITextAutocorrectionType = .default
   private(set) var keyboardType: UIKeyboardType = .default
   private(set) var hasKeyboardToolbar: Bool = true
   private(set) var textAlignment: TextAlignment = .leading
   
   public var onTextChange: (String) -> Void = { _ in }
   public var onSelectionChange: (NSRange) -> Void = { _ in }
   let engine = MarkdownEngine()
   
   public init(
      text: Binding<String>,
      onTextChange: @escaping (String) -> Void = { _ in },
      onSelectionChange: @escaping (NSRange) -> Void = { _ in }
   ) {
      _text = text
      self.onTextChange = onTextChange
      self.onSelectionChange = onSelectionChange
   }
   
   public func makeUIView(context: Context) -> SwiftDown {
      let swiftDown = SwiftDown(frame: .zero, theme: theme)
      swiftDown.storage.markdowner = { self.engine.render($0, offset: $1) }
      swiftDown.storage.applyMarkdown = { m in Theme.applyMarkdown(markdown: m, with: self.theme) }
      swiftDown.storage.applyBody = { Theme.applyBody(with: self.theme) }
      swiftDown.delegate = context.coordinator
      swiftDown.isEditable = isEditable
      swiftDown.isScrollEnabled = true
      swiftDown.keyboardType = keyboardType
      swiftDown.hasKeyboardToolbar = hasKeyboardToolbar
      swiftDown.autocapitalizationType = autocapitalizationType
      swiftDown.autocorrectionType = autocorrectionType
      swiftDown.textContainerInset = UIEdgeInsets(
         top: insetsSize, left: insetsSize, bottom: insetsSize, right: insetsSize)
      swiftDown.backgroundColor = theme.backgroundColor
      swiftDown.tintColor = theme.tintColor
      swiftDown.textColor = theme.tintColor
      swiftDown.text = text
      
      return swiftDown
   }
   
   public func updateUIView(_ uiView: SwiftDown, context: Context) {
      context.coordinator.cancellable?.cancel()
      context.coordinator.cancellable = Timer
         .publish(every: debounceTime, on: .current, in: .default)
         .autoconnect()
         .first()
         .sink { _ in
            let selectedRange = uiView.selectedRange
            uiView.text = text
            uiView.highlighter?.applyStyles()
            uiView.selectedRange = selectedRange
         }
   }
   
   public func makeCoordinator() -> Coordinator {
      Coordinator(self)
   }
}

// MARK: - SwiftDownEditor iOS Coordinator
extension SwiftDownEditor {
   public class Coordinator: NSObject, UITextViewDelegate {
      var cancellable: Cancellable?
      var parent: SwiftDownEditor
      
      init(_ parent: SwiftDownEditor) {
         self.parent = parent
      }
      
      public func textViewDidChange(_ textView: UITextView) {
         guard textView.markedTextRange == nil else { return }
         
         DispatchQueue.main.async {
            self.parent.text = textView.text
         }
      }
      
      public func textViewDidChangeSelection(_ textView: UITextView) {
         guard textView.markedTextRange == nil else { return }
         self.parent.onSelectionChange(textView.selectedRange)
      }
   }
}

// MARK: - iOS Specifics modifiers
extension SwiftDownEditor {
   public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
      var new = self
      new.autocapitalizationType = type
      return new
   }
   
   public func autocorrectionType(_ type: UITextAutocorrectionType) -> Self {
      var new = self
      new.autocorrectionType = type
      return new
   }
   
   public func keyboardType(_ type: UIKeyboardType) -> Self {
      var new = self
      new.keyboardType = type
      return new
   }
   
   public func textAlignment(_ type: TextAlignment) -> Self {
      var new = self
      new.textAlignment = type
      return new
   }
   
   public func hasKeyboardToolbar(_ hasKeyboardToolbar: Bool) -> Self {
      var editor = self
      editor.hasKeyboardToolbar = hasKeyboardToolbar
      return editor
   }
}


import UIKit

// MARK: - SwiftDown iOS
public class SwiftDown: UITextView, UITextViewDelegate {
   var storage: Storage = Storage()
   var highlighter: SwiftDownHighlighter?
   var hasKeyboardToolbar: Bool = true
   
   convenience init(frame: CGRect, theme: Theme) {
      self.init(frame: frame, textContainer: nil)
      self.storage.theme = theme
      self.backgroundColor = theme.backgroundColor
      self.tintColor = theme.tintColor
      self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      if hasKeyboardToolbar {
         self.addKeyboardToolbar()
      }
   }
   
   override init(frame: CGRect, textContainer: NSTextContainer?) {
      let layoutManager = NSLayoutManager()
      let containerSize = CGSize(width: frame.size.width, height: frame.size.height)
      let container = NSTextContainer(size: containerSize)
      container.widthTracksTextView = true
      
      layoutManager.addTextContainer(container)
      storage.addLayoutManager(layoutManager)
      super.init(frame: frame, textContainer: container)
      self.delegate = self
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      let layoutManager = NSLayoutManager()
      let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
      let container = NSTextContainer(size: containerSize)
      container.widthTracksTextView = true
      layoutManager.addTextContainer(container)
      storage.addLayoutManager(layoutManager)
      self.delegate = self
   }
   
   public override func willMove(toSuperview newSuperview: UIView?) {
      self.highlighter = SwiftDownHighlighter(textView: self)
   }
}

#endif
