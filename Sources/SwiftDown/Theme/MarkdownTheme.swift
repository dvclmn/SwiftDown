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
      case .header3: .labelColor
      case .header4: .labelColor
      case .header5: .labelColor
      case .header6: .labelColor
      case .code: .systemBrown
      case .italic: .systemIndigo
      case .bold: .labelColor
      case .link: .labelColor
      case .image: .labelColor
      case .body: .labelColor
    }
  }
  
//  var defaultFont: FontConfig {
//    switch self {
//      case .quote: FontConfig.body
//      case .codeBlock: FontConfig.bold
//      case .header1: FontConfig.systemBold(withSize: 24)
//      case .header2: FontConfig.systemBold(withSize: 21)
//      case .header3: FontConfig.systemBold(withSize: 19)
//      case .header4: FontConfig.systemBold(withSize: 16)
//      case .header5: FontConfig.systemBold(withSize: 15)
//      case .header6: FontConfig.bold
//      case .code: FontConfig.monospace
//      case .italic: FontConfig.italic
//      case .bold: FontConfig.bold
//      case .body, .list, .image, .link: FontConfig.body
//    }
//  }
  
  var defaultStyle: FontStyleType {
    switch self {
      case .quote: .body
      case .list: .body
      case .codeBlock: .monospaced
      case .header1: .bold
      case .header2: .bold
      case .header3: .bold
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
