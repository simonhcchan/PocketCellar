//
//  Userdefault-extension.swift
//  PocketCellar
//
//  Created by IE12 on 31/03/24.
//

import Foundation
let kUserDefault = UserDefaults.standard

class UserDefaultKeys {
    static let appTheme = "AppTheme"
    static let appFontSize = "AppFontSize"
    static let appFontType = "AppFontType"
    static let appFontSizeLabel = "AppFontSizeLabel"
    static let appFontSizeTextField = "AppFontSizeTextField"
}

extension UserDefaults{

    func setAppTheme(value: Bool) {
         self.set(value,forKey: UserDefaultKeys.appTheme)
    }

    func getAppTheme() -> Bool {
        return self.bool(forKey: UserDefaultKeys.appTheme)
    }

    func setAppFontType(value: String) {
         self.set(value,forKey: UserDefaultKeys.appFontType)
    }

    func getAppFontType() -> String? {
        return self.string(forKey: UserDefaultKeys.appFontType)
    }
    
}
