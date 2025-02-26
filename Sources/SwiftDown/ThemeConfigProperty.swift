//
//  ThemeConfigProperty.swift
//
//
//  Created by Quentin Eude on 10/03/2021.
//

import Foundation

// MARK: - ConfigProperty
enum ConfigProperty: String {
  case editor
  case styles
  case unknown

  static func from(rawValue: String) -> ConfigProperty {
    return ConfigProperty(rawValue: rawValue) ?? .unknown
  }

}

// MARK: - EditorConfigProperty
enum EditorConfigProperty: String {
  case backgroundColor
  case tintColor
  case cursorColor
  case unknown

  static func from(rawValue: String) -> EditorConfigProperty {
    return EditorConfigProperty(rawValue: rawValue) ?? .unknown
  }
}

// MARK: - StyleConfigProperty
enum StyleConfigProperty: String {
  case font
  case size
  case color
  case traits
  case unknown

  static func from(rawValue: String) -> StyleConfigProperty {
    return StyleConfigProperty(rawValue: rawValue) ?? .unknown
  }
}

// MARK: - TraitConfigProperty
enum TraitConfigProperty: String {
  case bold
  case italic
  case mono
  case expanded
  case condensed
  case unknown

  static func from(rawValue: String) -> TraitConfigProperty {
    return TraitConfigProperty(rawValue: rawValue) ?? .unknown
  }

}
