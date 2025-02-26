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
}

public struct FontConfig {
  public var descriptor: FontDescriptor
  public var traits: NSFontDescriptor.SymbolicTraits
  public var size: CGFloat
  
  public init(descriptor: FontDescriptor, traits: NSFontDescriptor.SymbolicTraits = [], size: CGFloat) {
    self.descriptor = descriptor
    self.traits = traits
    self.size = size
  }
  
  // Convenience initializers
  public static func system(
    weight: NSFont.Weight = .regular,
    design: NSFontDescriptor.SystemDesign = .default,
    size: CGFloat,
    traits: NSFontDescriptor.SymbolicTraits = []
  ) -> Self {
    Self(
      descriptor: .system(weight: weight, design: design),
      traits: traits,
      size: size
    )
  }
  
  public static func custom(
    name: String,
    size: CGFloat,
    traits: NSFontDescriptor.SymbolicTraits = []
  ) -> Self {
    Self(
      descriptor: .named(name),
      traits: traits,
      size: size
    )
  }
}

// Presets
extension FontConfig {
  public static let body = FontConfig.system(size: 14)
  public static let monospace = FontConfig.system(design: .monospaced, size: 14)
}


extension FontConfig {
  public func resolvedFont() -> NSFont? {
    switch descriptor {
      case .system(let weight, let design):
        let baseFont = NSFont.systemFont(ofSize: size, weight: weight)
        var descriptor = baseFont.fontDescriptor
        
        // Apply design
        if let designDescriptor = descriptor.withDesign(design) {
          descriptor = designDescriptor
        }
        
        // Combine traits
        let existingTraits = descriptor.symbolicTraits
        let combinedTraits = existingTraits.union(traits)
        descriptor = descriptor.withSymbolicTraits(combinedTraits)
        
        return NSFont(descriptor: descriptor, size: size)
        
      case .named(let name):
        guard let baseFont = NSFont(name: name, size: size) else {
          return nil
        }
        var descriptor = baseFont.fontDescriptor
        
        // Combine traits
        let existingTraits = descriptor.symbolicTraits
        let combinedTraits = existingTraits.union(traits)
        descriptor = descriptor.withSymbolicTraits(combinedTraits)
        
        return NSFont(descriptor: descriptor, size: size)
    }
  }
}
