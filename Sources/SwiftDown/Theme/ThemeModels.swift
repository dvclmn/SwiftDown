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

/// Goal: Incremental(?) configuration. Basically being able to override
/// a default with a single new declaration any time.

/// Usage:
///
/// ```swift
/// // Default theme
/// let defaultTheme = MarkdownTheme()
///
/// // Custom theme
/// var customTheme = MarkdownTheme()
/// customTheme.colors[.header1] = .systemRed
/// customTheme.colors[.codeBlock] = .systemBlue
///
/// // Completely custom theme
/// let allCustomColors: MarkdownTheme.ColorMap = [
///   .header1: .systemRed,
///   .header2: .systemOrange,
///   // other settings...
/// ]
/// let fullyCustomTheme = MarkdownTheme(colors: ThemeColors(values: allCustomColors))
///
/// ```

public struct MarkdownTheme {
  public var colors: ThemeColors = .defaults
  public var fonts: ThemeFonts = ThemeFonts()
  public var editor: EditorStyles = .defaults
}

public typealias MarkdownColorMap = [MarkdownNode.MarkdownType: NSColor]
public typealias MarkdownFontMap = [MarkdownNode.MarkdownType: FontConfig]

extension MarkdownTheme {

  // MARK: - Colours
  public struct ThemeColors {

    private var values: MarkdownColorMap = .defaultColours

    static let defaults: ThemeColors = .init()
  }

  // MARK: - Fonts
  public struct ThemeFonts {
    public var fonts: MarkdownFontMap = [:]

  }

  // MARK: - Editor Styles
  public struct EditorStyles {
    var backgroundColor: BackgroundStyle = .color(.controlBackgroundColor)
    var tintColor: NSColor = .controlAccentColor
    var cursorColor: NSColor = .blue

    static let defaults: EditorStyles = .init()
  }
}

extension Dictionary where Key == MarkdownNode.MarkdownType {
  
  static var defaultColours: MarkdownColorMap {
    var map: [MarkdownNode.MarkdownType: UniversalColor] = [:]
    
    for type in MarkdownNode.MarkdownType.allCases {
      map[type] = type.defaultColor
    }
    return map
  }
}

extension MarkdownTheme.ThemeColors {
  public subscript(type: MarkdownNode.MarkdownType) -> NSColor {
    get { values[type] ?? .labelColor }
    set { values[type] = newValue }
  }
}

// MARK: - Background Style

extension MarkdownTheme.EditorStyles {
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
}
