//
//  AppConstant.swift
//  PocketCellar
//
//  Created by IE12 on 26/03/24.
//

import Foundation
import UIKit

extension UIViewController {
    static func instantiate(from storyboard: StoryboardName) -> Self {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing:self)) as! Self
    }
}

enum StoryboardName: String {
    case main    = "Main"
    case common   = "Common"
}

