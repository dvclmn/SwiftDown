//
//  SwiftDown.swift
//
//
//  Created by Quentin Eude on 16/03/2021.
//


#if os(macOS)

import AppKit

// MARK: - CustomTextView
public class CustomTextView: NSTextView {
   
   
   let engine = MarkdownEngine()
   var highlighter: SwiftDownHighlighter!
  
   var storage: Storage = Storage()
   var editorHeight: CGFloat = .zero
   var insetsSize: CGFloat
   
   var metrics: String = ""
   
   init(
      frame: CGRect,
      theme: Theme,
      isEditable: Bool,
      insetsSize: CGFloat,
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
      
//      self.autoresizingMask = .width
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
      
//      self.editorHeight = contentSize.height
      
      return contentSize
   }
   
   public override func didChangeText() {
      super.didChangeText()
      invalidateIntrinsicContentSize()
      
      self.updateEditorMetrics()
      
      editorHeight = intrinsicContentSize.height

   }
   
   public override func viewWillDraw() {
      super.viewWillDraw()

      setupTextView()
      self.updateEditorMetrics()
      self.editorHeight = self.intrinsicContentSize.height
   }
   
   var viewUpdatesCount: Int = 0
   var nsViewUpdateCount: Int = 0
   var lastFunctionToEditText: String = ""

   
   private func updateEditorMetrics() {
      
      let result = """
      Insets: \(self.insetsSize)
      View updates: \\(self.viewUpdatesCount)
      NSView updates: \(self.nsViewUpdateCount)
      Edited text: \(self.lastFunctionToEditText)
      
      Editor height: \(self.editorHeight.formatted())
      """
      
      self.metrics = result
   }
   
   
   func setupTextView() {
      highlighter = SwiftDownHighlighter(textView: self)
   }
   
   func applyStyles() {
      assert(highlighter != nil)
      let selected = self.selectedRanges
      highlighter.applyStyles()
      self.selectedRanges = selected
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
