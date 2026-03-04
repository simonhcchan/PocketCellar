//
//  UiViewController+Extension.swift
//  PocketCellar
//
//  Created by IE MacBook Pro 2014 on 02/05/24.
//

import Foundation
import UIKit

extension UIViewController {
    func showLoader(loading :String = "Loading",inWindow:Bool = false)
    {
        JustHUD.shared.showInView(view: self.view,withHeader: nil, andFooter: loading)
    }

    func hideLoader()
    {
        JustHUD.shared.hide()
    }
}
