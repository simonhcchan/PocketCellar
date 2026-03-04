//
//  UITextField+Extension.swift
//  PocketCellar
//
//  Created by IE12 on 01/04/24.
//
import UIKit

private var placeholderColorKey: UInt8 = 0
private var placeholderFontKey: UInt8 = 1
private var placeholderFontSizeKey: UInt8 = 2
private var placeholderOpacityKey: UInt8 = 3

extension UITextField {
    private var placeholderColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &placeholderColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &placeholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePlaceholder()
        }
    }

    private var placeholderFont: UIFont? {
        get {
            return objc_getAssociatedObject(self, &placeholderFontKey) as? UIFont
        }
        set {
            objc_setAssociatedObject(self, &placeholderFontKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePlaceholder()
        }
    }

    private var placeholderFontSize: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &placeholderFontSizeKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &placeholderFontSizeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePlaceholder()
        }
    }

    private var placeholderOpacity: CGFloat {
        get {
            return objc_getAssociatedObject(self, &placeholderOpacityKey) as? CGFloat ?? 1.0
        }
        set {
            objc_setAssociatedObject(self, &placeholderOpacityKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePlaceholder()
        }
    }

    private func updatePlaceholder() {
        if let placeholderText = self.placeholder {
            var attributes: [NSAttributedString.Key: Any] = [:]
            if let color = placeholderColor {
                attributes[.foregroundColor] = color.withAlphaComponent(placeholderOpacity)
            }
            if let font = placeholderFont {
                attributes[.font] = font
            }
            self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        }
    }

    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeholderColor
        }
        set {
            self.placeholderColor = newValue
        }
    }

    @IBInspectable var placeHolderFont: UIFont? {
        get {
            return self.placeholderFont
        }
        set {
            self.placeholderFont = newValue
        }
    }

    @IBInspectable var placeHolderFontSize: CGFloat {
        get {
            return self.placeholderFontSize ?? UIFont.systemFontSize
        }
        set {
            self.placeholderFontSize = newValue
            if let existingFont = self.font {
                self.font = UIFont(name: existingFont.fontName, size: newValue)
            } else {
                self.font = UIFont.systemFont(ofSize: newValue)
            }
        }
    }

    @IBInspectable var placeHolderOpacity: CGFloat {
        get {
            return self.placeholderOpacity
        }
        set {
            self.placeholderOpacity = max(0.0, min(newValue, 1.0))
        }
    }
}
