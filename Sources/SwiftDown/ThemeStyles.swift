//
//  ThemeStyles.swift
//  SwiftDown
//
//  Created by Dave Coleman on 26/2/2025.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension MarkdownNode.MarkdownType {
  var defaultColor: UniversalColor {
    switch self {
      case .quote: return .labelColor
      case .list: return .labelColor
      case .codeBlock: return .systemBrown
      case .header1: return .systemOrange
      case .header2: return .labelColor
      case .header3: return .labelColor
      case .header4: return .labelColor
      case .header5: return .labelColor
      case .header6: return .labelColor
      case .code: return .systemBrown
      case .italic: return .systemIndigo
      case .bold: return .labelColor
      case .link: return .labelColor
      case .image: return .labelColor
      case .body: return .labelColor
    }
  }
  
  static func defaultColorMap() -> MarkdownColorMap {
    var map: [MarkdownNode.MarkdownType: UniversalColor] = [:]
    for type in MarkdownNode.MarkdownType.allCases {
      map[type] = type.defaultColor
    }
    return map
  }
}

/// Usage:
///
/// ```
/// var customTheme = MarkdownTheme()
/// customTheme.colors[.header1] = .systemRed
/// customTheme.colors[.code] = .systemBlue
///
/// ```
public struct MarkdownTheme {
  public var colors: ThemeColors = ThemeColors()
  public var fonts: ThemeFonts = ThemeFonts()

}

public typealias MarkdownColorMap = [MarkdownNode.MarkdownType: NSColor]


extension MarkdownTheme {


  public struct ThemeColors {
    private var values: MarkdownColorMap = [:]

    public subscript(type: MarkdownNode.MarkdownType) -> NSColor {
      get { values[type] ?? .labelColor }
      set { values[type] = newValue }
    }
    
    public init(values: MarkdownColorMap? = nil) {
      self.values = values ?? MarkdownNode.MarkdownType.defaultColorMap()
    }
    
  }
}

extension MarkdownTheme {

  public struct ThemeFonts {
    // Similar implementation for fonts
  }
}
