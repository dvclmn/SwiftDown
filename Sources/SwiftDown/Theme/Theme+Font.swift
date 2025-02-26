//
//  Theme+Font.swift
//  SwiftDown
//
//  Created by Dave Coleman on 26/2/2025.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// ```
/// // System font with design and traits
/// let titleFont = FontConfig.system(
///   weight: .bold,
///   design: .serif,
///   size: 20,
///   traits: [.italic]
/// )
///
/// // Custom font with traits
/// let customFont = FontConfig.custom(
///   name: "Comic Sans",
///   size: 14,
///   traits: [.bold, .italic]
/// )
///
/// // Using presets
/// let bodyFont = FontConfig.body
/// let codeFont = FontConfig.monospace
/// ```

public enum FontDescriptor {
  case system(weight: NSFont.Weight, design: NSFontDescriptor.SystemDesign)
  case named(String)

  static var `default` = FontDescriptor.system(
    weight: .regular,
    design: .default
  )
}

public struct FontConfig {
  public var size: CGFloat
  public var descriptor: FontDescriptor
  public var traits: NSFontDescriptor.SymbolicTraits

  //  static let defaultFontSize: CGFloat = 14

  public init(
    descriptor: FontDescriptor,
    size: CGFloat,
    traits: NSFontDescriptor.SymbolicTraits = []
  ) {
    self.descriptor = descriptor
    self.size = size
    self.traits = traits
  }

  public static func system(
    size: CGFloat,
    weight: NSFont.Weight = .regular,
    design: NSFontDescriptor.SystemDesign = .default,
    traits: NSFontDescriptor.SymbolicTraits = []
  ) -> Self {
    Self(
      descriptor: .system(weight: weight, design: design),
      size: size,
      traits: traits
    )
  }

  public static func custom(
    name: String,
    size: CGFloat,
    traits: NSFontDescriptor.SymbolicTraits = []
  ) -> Self {
    Self(
      descriptor: .named(name),
      size: size,
      traits: traits
    )
  }

  public static func systemBold(
    withSize size: CGFloat
  ) -> Self {
    Self(
      descriptor: .default,
      size: size,
      traits: []
    )
  }
}

enum FontPresetGroup: CaseIterable {
  case bold
  case italic
  case boldItalic
  case body
  case monospaced

  func preset(withSize size: CGFloat) -> FontConfig {
    switch self {
      case .bold: FontConfig.system(size: size, weight: .bold)
      case .italic: FontConfig.system(size: size, traits: .italic)
      case .boldItalic: FontConfig.system(size: size, weight: .bold, traits: .italic)
      case .body: FontConfig.system(size: size)
      case .monospaced: FontConfig.system(size: size, design: .monospaced)
    }
  }

  public func presetGroup(withSize size: CGFloat) -> FontGroup {
    var map: FontGroup = [:]
    for preset in Self.allCases {
      map[preset] = preset.preset(withSize: size)
    }
    return map
  }
}

typealias FontGroup = [FontPresetGroup: FontConfig]

// MARK: - Presets
extension FontConfig {
  public static let body = FontConfig.system(size: 14)
  public static let monospace = FontConfig.system(size: 14, design: .monospaced)
  public static let italic = FontConfig.system(size: 14, traits: .italic)
  public static let bold = FontConfig.system(size: 14, weight: .bold)
  public static let boldItalic = FontConfig.system(size: 14, weight: .bold, traits: .italic)

}

extension FontConfig {
  public func resolvedFont() -> NSFont? {
    switch descriptor {
      case .system(let weight, let design):
        resolveSystem(weight: weight, design: design)
      case .named(let name):
        resolveNamed(name)
    }
  }

  private func resolveSystem(
    weight: NSFont.Weight,
    design: NSFontDescriptor.SystemDesign
  ) -> NSFont? {

    let baseFont = NSFont.systemFont(ofSize: size, weight: weight)
    let descriptor = combineTraits(baseFont: baseFont)

    return NSFont(descriptor: descriptor, size: size)
  }

  private func resolveNamed(_ name: String) -> NSFont? {
    guard let baseFont = NSFont(name: name, size: size) else {
      return nil
    }
    let descriptor = combineTraits(baseFont: baseFont)
    return NSFont(descriptor: descriptor, size: size)
  }
  
  private func combineTraits(
    baseFont: NSFont,
    design: NSFontDescriptor.SystemDesign? = nil
  ) -> NSFontDescriptor {
    
    var descriptor = baseFont.fontDescriptor
    
    if let design, let designDescriptor = descriptor.withDesign(design) {
      descriptor = designDescriptor
    }

    let existingTraits = descriptor.symbolicTraits
    let combinedTraits = existingTraits.union(traits)
    descriptor = descriptor.withSymbolicTraits(combinedTraits)
    return descriptor
  }
}
