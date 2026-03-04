//
//  UIFont+Extension.swift
//  PocketCellar
//
//  Created by IE12 on 01/04/24.
//

import Foundation
import UIKit

extension UIFont {
    enum RubikWeight: String {
        case regular = "Rubik-Regular"
        case italic = "Rubik-Italic"
        case medium = "Rubik-Medium"
        case mediumItalic = "Rubik-MediumItalic"
        case bold = "Rubik-Bold"
        case boldItalic = "Rubik-BoldItalic"
        case light = "Rubik-Light"
        case lightItalic = "Rubik-LightItalic"
        case thin = "Rubik-Thin"
        case thinItalic = "Rubik-ThinItalic"
    }

    static var currentFontSize: CGFloat {
        get {
            return CGFloat(UserDefaults.standard.float(forKey: "RubikFontSize"))
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "RubikFontSize")
            NotificationCenter.default.post(name: .UIFontSizeDidChange, object: nil)
        }
    }

    static func rubik(ofSize size: CGFloat, weight: RubikWeight) -> UIFont {
        guard let font = UIFont(name: weight.rawValue, size: size) else {
            fatalError("Font not found")
        }
        return font
    }

    static func changeFontSize(action: String) {
        var fontSize = currentFontSize
        switch action {
        case "small":
            fontSize = 14.0
        case "large":
            fontSize = 20.0
        case "veryLarge":
            fontSize = 24.0
        default:
            break
        }
        currentFontSize = fontSize
    }
}

extension Notification.Name {
    static let UIFontSizeDidChange = Notification.Name("UIFontSizeDidChange")
}
