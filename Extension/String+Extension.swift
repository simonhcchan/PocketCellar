//
//  String+Extension.swift
//  PocketCellar
//
//  Created by IE15 on 15/03/24.
//

import Foundation
import UIKit
extension String {
    func toImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: self) else {
            print("Invalid base64 string")
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            print("Failed to convert data to image")
            return nil
        }
        return image
    }
}

import Foundation
import CryptoKit

extension String {

    var sha256: String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if length == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}

//extension String {
//        func localized() -> String {
//            if let appLanguage = UserDefaults.standard.array(forKey: "AppleLanguages") {
//                let path: String = Bundle.main.path(forResource: appLanguage[0] as? String, ofType: "lproj") ?? ""
//                let bundle = Bundle(path: path)
//                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self)
//            }
//            else {
//                let path = Bundle.main.path(forResource: "en", ofType: "lproj") ?? ""
//                let bundle = Bundle(path: path)
//                return NSLocalizedString(self, tableName: "Localizable", bundle: bundle!, value: self, comment: self) }
//        }
//    }
extension String {
    func localized() -> String {
        if let appLanguages = UserDefaultsManager.getLanguages(),
           let appLanguage = appLanguages.first {
            let path: String = Bundle.main.path(forResource: appLanguage, ofType: "lproj") ?? ""
            let bundle = Bundle(path: path)
            return NSLocalizedString(self, tableName: "Localizable", bundle: bundle ?? .main, value: self, comment: self)
        } else {
            let path = Bundle.main.path(forResource: "en", ofType: "lproj") ?? ""
            let bundle = Bundle(path: path)
            return NSLocalizedString(self, tableName: "Localizable", bundle: bundle ?? .main, value: self, comment: self)
        }
    }
}
