//
//  SwiftDown.swift
//
//
//  Created by Quentin Eude on 16/03/2021.
//

#if os(iOS)
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
#else
import AppKit

// MARK: - CustomTextView
public class CustomTextView: NSTextView {
   
   
   let engine = MarkdownEngine()
   var highlighter: SwiftDownHighlighter!
  
   var storage: Storage = Storage()
   var editorHeight: CGFloat = .zero
   var insetsSize: CGFloat
   
   init(
      frame: CGRect,
      theme: Theme,
      isEditable: Bool,
      insetsSize: CGFloat = 40,
      textContainer: NSTextContainer?
   ) {
      
      self.storage.theme = theme
      self.insetsSize = insetsSize
      
      let layoutManager = NSLayoutManager()
      let containerSize = CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)
      let container = NSTextContainer(size: containerSize)
      container.widthTracksTextView = true
      
      
      layoutManager.addTextContainer(container)
      storage.addLayoutManager(layoutManager)
      
      super.init(frame: frame, textContainer: container)

      self.storage.markdowner = { self.engine.render($0, offset: $1) }
      self.storage.applyMarkdown = { m in
         Theme.applyMarkdown(markdown: m, with: theme)
      }
      self.storage.applyBody = { Theme.applyBody(with: theme) }
      self.storage.theme = theme
      
      self.autoresizingMask = .width
      self.drawsBackground = false
      self.isEditable = isEditable
      self.isHorizontallyResizable = false
      self.isVerticallyResizable = true
      self.maxSize = NSSize(
         width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
      self.textContainerInset = NSSize(width: self.insetsSize, height: self.insetsSize)
      self.allowsUndo = true
//      self.allowsDocumentBackgroundColorChange = true
   
      self.insertionPointColor = theme.cursorColor

   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   public override var intrinsicContentSize: NSSize {
      
      guard let layoutManager = self.layoutManager, let container = self.textContainer else {
         return super.intrinsicContentSize
      }
      container.containerSize = NSSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
      layoutManager.ensureLayout(for: container)
      
      let rect = layoutManager.usedRect(for: container).size
      
      let contentSize = NSSize(width: NSView.noIntrinsicMetric, height: rect.height)
      
      self.editorHeight = contentSize.height
      
      return contentSize
   }
   
   public override func didChangeText() {
      super.didChangeText()
      invalidateIntrinsicContentSize()
//      editorHeight = intrinsicContentSize.height
      //        heightChangeHandler(height)
   }
   
   public override func viewWillDraw() {
      super.viewWillDraw()
      setupTextView()
      invalidateIntrinsicContentSize()
//      editorHeight = intrinsicContentSize.height
   }
   
   
   func setupTextView() {
      
      highlighter = SwiftDownHighlighter(textView: self)
      
      
      
   }
   
   func applyStyles() {
      assert(highlighter != nil)
      highlighter.applyStyles()
   }
   
   
   
   
}


// MARK: - SwiftDown macOS
class TransparentBackgroundScroller: NSScroller {
   override func draw(_ dirtyRect: NSRect) {
      self.drawKnob()
   }
}

//public class SwiftDown: NSView {


// MARK: - ScrollView setup
//   private lazy var scrollView: NSScrollView = {
//      let scrollView = NSScrollView()
//      scrollView.drawsBackground = false
//      scrollView.borderType = .noBorder
//      scrollView.hasVerticalScroller = true
//      scrollView.hasHorizontalRuler = false
//      scrollView.autoresizingMask = [.width, .height]
//      scrollView.translatesAutoresizingMaskIntoConstraints = false
//      scrollView.autohidesScrollers = true
//      scrollView.borderType = .noBorder
//      scrollView.verticalScroller = TransparentBackgroundScroller()
//      return scrollView
//   }()
//
// MARK: - TextView setup
//   private lazy var textView: CustomTextView = {
//
//      return textView
//   }()

//   init(
//      theme: Theme,
//      isEditable: Bool,
//
//   ) {
//      self.isEditable = isEditable
//      self.text = ""
//      self.theme = theme
//      self.insetsSize = insetsSize
//
//      super.init(frame: .zero)
//   }

//   required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//   }



//}
#endif
