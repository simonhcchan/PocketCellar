//
//  UIImage+Extension.swift
//  PocketCellar
//
//  Created by IE15 on 15/03/24.
//

import Foundation
import UIKit


extension UIImage {
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        if let imageData = self.jpegData(compressionQuality: cq) {
            return imageData.base64EncodedString()
        }
        return nil
    }
}
