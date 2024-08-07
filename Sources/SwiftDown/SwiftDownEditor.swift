//
//  SwiftDownEditor.swift
//
//
//  Created by Quentin Eude on 16/03/2021.
//

import Down
import SwiftUI
import Combine
import TestStrings

#if os(macOS)

// MARK: - SwiftDownEditor macOS
public struct SwiftDownEditor: NSViewRepresentable {
   
   private var debounceTime = 0.3
   @Binding public var text: String
   
   public var isEditable: Bool
   public var insetsSize: CGFloat
   
   private(set) var onTextChange: (_ text: String) -> Void
   private(set) var onSelectionChange: (NSRange) -> Void
   private(set) var output: (_ editorHeight: CGFloat) -> Void
   
   public init(
      text: Binding<String>,
      isEditable: Bool = true,
      insetsSize: CGFloat = 40,
      
      onTextChange: @escaping (_ text: String) -> Void = { _ in },
      onSelectionChange: @escaping (NSRange) -> Void = { _ in },
      output: @escaping (_ editorHeight: CGFloat) -> Void = { _ in }
   ) {
      self._text = text
      self.isEditable = isEditable
      self.insetsSize = insetsSize
      self.onTextChange = onTextChange
      self.onSelectionChange = onSelectionChange
      self.output = output
   }
   
   private let minHeight: CGFloat = 60

   public func makeNSView(context: Context) -> CustomTextView {
      
      let textView = CustomTextView(
         frame: NSRect(origin: .zero, size: CGSize(width: 200, height: 200)),
         theme: Theme.BuiltIn.defaultDark.theme(),
         isEditable: isEditable,
         insetsSize: insetsSize,
         textContainer: nil
      )
      textView.delegate = context.coordinator
      textView.setupTextView()
      
      textView.string = text
      
      sendNewHeight(for: textView, isColdStart: true)
      
      return textView
   }
   
   
   
   
   /// When a @Binding or @State property used by the view changes.
   /// When an @ObservedObject or @StateObject referenced by the view is modified.
   /// When the view's environment changes (e.g., color scheme, size classes).
   /// When the parent view triggers a re-render that affects this view.
   ///
   public func updateNSView(_ textView: CustomTextView, context: Context) {
      
      
//      context.coordinator.parent = self
//      context.coordinator.cancellable?.cancel()
//      context.coordinator.cancellable = Timer
//         .publish(every: debounceTime, on: .current, in: .default)
//         .autoconnect()
//         .first()
//         .sink { _ in
//            
//            
//         }
      
      if self.text != textView.string {
         textView.string = text
         textView.applyStyles()
         self.sendNewHeight(for: textView)
      }
      
//      self.sendUpdatedMetrics(for: textView)
      
      
      //      if self.text != textView.string {
      //         context.coordinator.nsViewUpdateCount += 1
      //      }
      
      
      
   } // END update nsview

   
   public func makeCoordinator() -> Coordinator {
      Coordinator(self)
   }
   
}

// MARK: - SwiftDownEditor Coordinator macOS
extension SwiftDownEditor {
   // MARK: - Coordinator
   public class Coordinator: NSObject, NSTextViewDelegate {
      var parent: SwiftDownEditor
      var cancellable: Cancellable?
      
      var previousHeight: CGFloat = .zero
      
      
      
      init(_ parent: SwiftDownEditor) {
         self.parent = parent
      }
      
      public func textDidChange(_ notification: Notification) {
         guard let textView = notification.object as? CustomTextView
         else { return }
         
         self.parent.text = textView.string
         self.parent.onTextChange(textView.metrics)
         
      }
      
      public func textViewDidChangeSelection(_ notification: Notification) {
         guard let textView = notification.object as? NSTextView else {
            return
         }
         self.parent.onSelectionChange(textView.selectedRange())
      }
   }
   
   @MainActor
   private func sendNewHeight(for textView: CustomTextView, isColdStart: Bool = false) {
      
      if isColdStart {
         
         var finalResult: CGFloat {
            if textView.editorHeight < self.minHeight {
               return self.minHeight
            } else {
               return textView.editorHeight
            }
         }

         Task { @MainActor in
            
//            textView.string += "Hello"
            textView.invalidateIntrinsicContentSize()
            textView.needsDisplay = true
            
            self.output(finalResult)
         }
         
      } else {
         
         guard let coordinator = textView.delegate as? Coordinator else { return }
         
//         if textView.editorHeight != coordinator.previousHeight {
            
            Task { @MainActor in
               let finalResult = heightCalculation(for: textView.editorHeight)
               self.output(finalResult)
               coordinator.previousHeight = finalResult
               textView.viewUpdatesCount += 1
            }
//         }
         
      }
   } // END calc new height
   
   @MainActor
   func sendUpdatedMetrics(for textView: CustomTextView) {
      self.onTextChange(textView.metrics)
   }
   
   private func heightCalculation(for height: CGFloat) -> CGFloat {
      let clampedHeight = max(height, self.minHeight)
      let insetCompensation = self.insetsSize * 2
      let finalValue: CGFloat = clampedHeight + insetCompensation
      
      return finalValue
   }
   
}
#endif

struct SwiftDownExampleView: View {
   
   @State private var text: String = "Usually, `NSTextView` manages the *layout* process inside **the viewport** interacting ~~with its delegate~~. A `viewport` is a _rectangular_ area within a ==flipped coordinate system== expanding along the y-axis, with __bold alternate__, as well as ***bold italic*** emphasis."
   
   @State private var isStreaming: Bool = false
   @State private var metrics: String = "Metrics"
   @State private var closureEditorHeight: CGFloat = .zero
   
   var body: some View {
      
      if #available(macOS 13.0, *) {
         
         VStack {
            
            SwiftDownEditor(text: $text, onTextChange: { text in
               metrics = text
            }, output: { height in
               closureEditorHeight = height
            })
            .frame(height: closureEditorHeight)
            .border(Color.green.opacity(0.3))
            Spacer()
            
         }
         .overlay(alignment: .bottom) {
            HStack(alignment: .bottom) {
               Text(metrics)
               Spacer()
               Text("Local editor height: \(closureEditorHeight.formatted())")
            }
            .monospaced()
            .foregroundStyle(.secondary)
            .fontWeight(.medium)
            
         } // END overlay
         
         .task {
            if isStreaming {
               do {
                  for try await chunk in MockupTextStream.chunks(chunkSize: 1, speed: 300) {
                     await MainActor.run {
                        text += chunk
                     }
                  }
               } catch {
                  print("Error: \(error)")
               }
            }
         } // END task
      } // END if available
   }
}
#Preview {
   SwiftDownExampleView()
      .padding(40)
      .frame(width: 600, height: 700)
      .background(.black.opacity(0.6))
}


enum TextChunkError: Error {
   case cancelled
}

public class MockupTextStream {
   
   public static func chunks(
      from text: String? = nil,
      chunkSize: Int = 5,
      speed: Int = 200
   ) -> AsyncThrowingStream<String, Error> {
      AsyncThrowingStream { continuation in
         Task {
            do {
               for chunk in splitContentPreservingWhitespace(text, chunkSize: chunkSize) {
                  try Task.checkCancellation()
                  continuation.yield(chunk)
                  if #available(macOS 13.0, *) {
                     try await Task.sleep(for: .milliseconds(speed))
                  } else {
                     // Fallback on earlier versions
                  }
               }
               continuation.finish()
            } catch {
               continuation.finish(throwing: error)
            }
         }
      }
   }
   
   private static func splitContentPreservingWhitespace(_ content: String? = nil, chunkSize: Int = 5) -> [String] {
      var chunks: [String] = []
      var currentChunk = ""
      var wordCount = 0
      
      var textContent: String = ""
      
      if let content = content {
         textContent = content
      } else {
         textContent = TestStrings.paragraphsWithCode[0]
      }
      
      for character in textContent {
         currentChunk.append(character)
         
         if character.isWhitespace || character.isNewline {
            wordCount += 1
            if wordCount >= chunkSize {
               chunks.append(currentChunk)
               currentChunk = ""
               wordCount = 0
            }
         }
      }
      
      if !currentChunk.isEmpty {
         chunks.append(currentChunk)
      }
      
      return chunks
   }
}

