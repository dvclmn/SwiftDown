//
//  ThemeModels.swift
//  SwiftDown
//
//  Created by Dave Coleman on 26/2/2025.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif


public struct MarkdownTheme {
  public var colors: ThemeColors = .defaults
  public var fonts: ThemeFonts = ThemeFonts()
  public var editor: EditorStyles = .defaults
}

public typealias MarkdownColorMap = [MarkdownNode.MarkdownType: NSColor]

extension MarkdownTheme {
  
  // MARK: - Colours
  public struct ThemeColors {
    
    private var values: MarkdownColorMap = [:]
    
    public init(values: MarkdownColorMap? = nil) {
      self.values = values ?? MarkdownNode.MarkdownType.defaultColorMap()
    }
    static let defaults: ThemeColors = .init()
  }
  
  // MARK: - Colours
  public struct ThemeFonts {
    
  }
  
  // MARK: - Editor Styles
  public struct EditorStyles {
    var backgroundColor: BackgroundStyle = .color(.controlBackgroundColor)
    var tintColor: NSColor = .controlAccentColor
    var cursorColor: NSColor = .blue
    
    enum BackgroundStyle {
      case color(NSColor)
      case noBackground
      
      var asUniversalColor: UniversalColor {
        switch self {
          case .color(let color):
            return color
          case .noBackground:
            return .clear
        }
      }
    }
    
    static let defaults: EditorStyles = .init()
  }
}

extension MarkdownTheme.ThemeColors {
  public subscript(type: MarkdownNode.MarkdownType) -> NSColor {
    get { values[type] ?? .labelColor }
    set { values[type] = newValue }
  }
}

