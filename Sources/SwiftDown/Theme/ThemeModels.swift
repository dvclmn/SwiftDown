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

public typealias MarkdownColorMap = [MarkdownNode.MarkdownType: NSColor]
public typealias MarkdownFontMap = [MarkdownNode.MarkdownType: FontConfig]

public struct MarkdownTheme {
  public var colors: Colors
  public var fonts: Fonts
  public var editor: EditorStyles
  
  public static let defaultTheme: MarkdownTheme = .init()
  
  public init(
    colors: Colors = .defaults,
    fonts: Fonts = .defaults,
    editor: EditorStyles = .defaults
  ) {
    self.colors = colors
    self.fonts = fonts
    self.editor = editor
  }
}




protocol VisualProperty {
  var style: AnyHashable { get }
}

extension MarkdownTheme {
  public func set(
    _ type: MarkdownNode.MarkdownType,
    _ value: CGFloat
  ) -> Self {
    var copy = self
//    copy.fonts[type] =
    copy.fonts.setFont(type, value: value)
    
    return copy
  }
}


extension MarkdownTheme {

  // MARK: - Colours
  public struct Colors {
    private var colours: MarkdownColorMap = .defaultColours
    public static let defaults: Colors = .init()
  }

  // MARK: - Fonts
  public struct Fonts {
    public var fonts: MarkdownFontMap = [:]
    public static let defaults: Fonts = .init()
  }

  // MARK: - Editor Styles
  public struct EditorStyles {
    var backgroundColor: BackgroundStyle = .color(.controlBackgroundColor)
    var tintColor: NSColor = .controlAccentColor
    var cursorColor: NSColor = .blue

    public static let defaults: EditorStyles = .init()
  }
}

extension MarkdownTheme {

  func attributes(forType type: MarkdownNode.MarkdownType) -> [NSAttributedString.Key: Any] {
    var attributes: [NSAttributedString.Key: Any] = [:]

    /// Apply color
    attributes[.foregroundColor] = colors[type]

    if let fontConfig = fonts.fonts[type] {
      attributes[.font] = fontConfig.resolvedFont()
      attributes[.foregroundColor] = colors[type]
    }

    return attributes
  }

}

extension MarkdownTheme.Colors {
  public subscript(type: MarkdownNode.MarkdownType) -> NSColor {
    get { colours[type] ?? .labelColor }
    set { colours[type] = newValue }
  }
}

extension MarkdownTheme.Fonts {
  public subscript(type: MarkdownNode.MarkdownType) -> FontConfig {
    get { fonts[type] ?? .system(size: 14) }
    set { fonts[type] = newValue }
  }
//  public subscript(type: MarkdownNode.MarkdownType) -> NSFont {
//    get { fonts[type] ?? .systemFont(ofSize: 14) }
//    set { fonts[type] = newValue }
//  }
}


extension MarkdownTheme.Fonts {
  mutating func setFont(_ type: MarkdownNode.MarkdownType, value: CGFloat) {
    var currentFont = fonts[type]
    currentFont?.setSize(value)
  }
}





// MARK: - EditorStyles
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

// MARK: - Extensions
extension Dictionary where Key == MarkdownNode.MarkdownType {

  static var defaultColours: MarkdownColorMap {
    var map: MarkdownColorMap = [:]

    for type in MarkdownNode.MarkdownType.allCases {
      map[type] = type.defaultColor
    }
    return map
  }
}

extension Dictionary where Key == FontStyleType {

  static var defaultFonts: MarkdownFontMap {
    var map: MarkdownFontMap = [:]

    for type in MarkdownNode.MarkdownType.allCases {
      map[type] = type.defaultFont()
    }
    return map
  }
}
