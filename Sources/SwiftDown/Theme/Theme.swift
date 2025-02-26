//
//  Theme.swift
//
//
//  Created by Quentin Eude on 10/03/2021.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct Theme {
  // MARK: - BuildIn
  public enum BuiltIn: String {
    case defaultDark = "default-dark"
    case defaultLight = "default-light"

    public func theme() -> Theme {
      return Theme(self.rawValue)
    }
  }

  var backgroundColor: UniversalColor = UniversalColor.clear
  var tintColor: UniversalColor = UniversalColor.blue
  var cursorColor: UniversalColor = UniversalColor.blue
  var styles: [MarkdownNode.MarkdownType: Style] = [:]

  public init(_ name: String) {
    self.init()
    let bundle = Bundle.module

    guard let path = bundle.path(forResource: "Themes/\(name)", ofType: "json") else {
      print("[SwiftDown] Unable to load your theme file.")
      assertionFailure()
      return
    }

    self.init(themePath: path)
  }

  public init(themePath: String) {
    self.init()
    if let data = convertFile(themePath) {
      configure(data)
    }
  }

  public init(theme: MarkdownTheme) {
    self.init()
    configure(theme)
  }

  public init() {
    MarkdownNode.MarkdownType.allCases.forEach { type in
      styles[type] = Style()
    }
  }

  mutating func configure(_ theme: MarkdownTheme) {
    configureEditor(theme.editor)
  }

  
  mutating func configure(_ data: [String: AnyObject]) {
    data.forEach { key, value in
      switch ConfigProperty.from(rawValue: key) {
        case .editor:
          if let editorStyles = value as? [String: String] {
            configureEditor(editorStyles)
          }
        case .styles:
          if let styles = value as? [String: AnyObject] {
            configureStyles(styles)
          }
        case .unknown:
          break
      }
    }
  }

  mutating private func configureStyles(_ style: MarkdownTheme) {
//let style =
    //    attributes.forEach { key, value in
    //      if let value = value as? [String: AnyObject],
    //         let style = configureStyle(value as [String: AnyObject]),
    //         let mdType = MarkdownNode.MarkdownType.from(string: key)
    //      {
    //        styles[mdType] = Style(attributes: style)
    //      }
    //    }
  }

  mutating private func configureStyles(_ attributes: [String: AnyObject]) {
    attributes.forEach { key, value in
      if let value = value as? [String: AnyObject],
        let style = configureStyle(value as [String: AnyObject]),
        let mdType = MarkdownNode.MarkdownType.from(string: key)
      {
        styles[mdType] = Style(attributes: style)
      }
    }
  }
  
  mutating private func configureStyle(
    theme: MarkdownTheme
//    _ attributes: [String: AnyObject]
  ) -> [NSAttributedString
    .Key: Any]?
  {
    var stringAttributes: [NSAttributedString.Key: Any] = [:]
    var fontSize: CGFloat = 15
//    var font: UniversalFont? = UniversalFont.systemFont(ofSize: fontSize)
//    var fontTraits = ""
    
    stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.labelColor
    
    
    
  }
  
  

  mutating private func configureStyle(
    _ attributes: [String: AnyObject]
  ) -> [NSAttributedString
    .Key: Any]?
  {
    var stringAttributes: [NSAttributedString.Key: Any] = [:]
    var fontSize: CGFloat = 15
    var font: UniversalFont? = UniversalFont.systemFont(ofSize: fontSize)
    var fontTraits = ""

    stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.labelColor

    attributes.forEach { key, value in
      switch StyleConfigProperty.from(rawValue: key) {
        case .color:

          if let colorString = value as? String {

            if let markdownType = MarkdownNode.MarkdownType.from(string: colorString) {

              switch markdownType {
                case .header1:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemBrown

                case .header2:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemTeal

                case .header3, .header4, .header5, .header6:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemIndigo

                case .quote:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemGray

                case .code, .codeBlock:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemBrown

                case .italic:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemPurple

                case .list:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemOrange

                case .link, .image:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemMint

                case .bold:
                  stringAttributes[NSAttributedString.Key.foregroundColor] = UniversalColor.systemGreen
                    .withAlphaComponent(0.9)

                case .body:
                  break
              }
            }
          }

        case .font:
          if let fontName = value as? String, fontName != "System" {
            font = UniversalFont(name: fontName, size: fontSize) ?? font
          }
        case .size:
          if let size = value as? CGFloat {
            fontSize = size
          }
        case .traits:
          if let traits = value as? String {
            fontTraits = traits
          }
        case .unknown:
          break
      }
    }
    font = font?.with(traits: fontTraits, size: fontSize)
    stringAttributes[NSAttributedString.Key.font] = font
    return stringAttributes
  }

  mutating private func configureEditor(_ style: MarkdownTheme.EditorStyles) {
    backgroundColor = style.backgroundColor.asUniversalColor
    tintColor = style.tintColor
    cursorColor = style.cursorColor
  }

  mutating private func configureEditor(_ attributes: [String: String]) {
    attributes.forEach { key, value in
      switch EditorConfigProperty.from(rawValue: key) {
        case .backgroundColor:
          backgroundColor = UniversalColor(hexString: value)
        case .tintColor:
          tintColor = UniversalColor(hexString: value)
        case .cursorColor:
          cursorColor = UniversalColor(hexString: value)
        case .unknown:
          break
      }
    }
  }

  private func convertFile(_ path: String) -> [String: AnyObject]? {
    do {
      let json = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
      if let data = json.data(using: .utf8) {
        do {
          let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
          //          dump(jsonResult, indent: 2)
          return jsonResult
        } catch let error as NSError {
          print(error)
        }
      }
    } catch let error as NSError {
      print(error)
    }

    return nil
  }

  // MARK: - Static methods
  static func applyMarkdown(
    markdown: MarkdownNode, with theme: Theme
  ) -> [NSAttributedString.Key: Any] {
    guard let attributes = theme.styles[markdown.type]?.attributes else { return [:] }
    return attributes
  }

  static func applyBody(with theme: Theme) -> [NSAttributedString.Key: Any] {
    guard let attributes = theme.styles[MarkdownNode.MarkdownType.body]?.attributes else {
      return [:]
    }
    return attributes
  }
}
