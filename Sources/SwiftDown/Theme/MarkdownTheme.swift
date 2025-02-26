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
      case .quote: .labelColor
      case .list: .labelColor
      case .codeBlock: .systemBrown
      case .header1: .systemOrange
      case .header2: .labelColor
      case .header3: .systemPink
      case .header4: .labelColor
      case .header5: .labelColor
      case .header6: .labelColor
      case .code: .systemBrown
      case .italic: .systemIndigo
      case .bold: .systemGreen
      case .link: .labelColor
      case .image: .labelColor
      case .body: .labelColor
    }
  }

  var defaultStyle: FontStyleType {
    switch self {
      case .quote: .body
      case .list: .body
      case .codeBlock: .monospaced
      case .header1: .bold
      case .header2: .bold
      case .header3: .monospaced
      case .header4: .bold
      case .header5: .bold
      case .header6: .bold
      case .code: .monospaced
      case .italic: .italic
      case .bold: .bold
      case .link: .body
      case .image: .body
      case .body: .body
    }
  }
  
  func defaultFont(withSize size: CGFloat = 14) -> FontConfig {
    defaultStyle.preset(withSize: size)
  }

}
