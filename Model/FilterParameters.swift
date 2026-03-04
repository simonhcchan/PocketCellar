//
//  FilterParameters.swift
//  PocketCellar
//
//  Created by IE15 on 03/05/24.
//

import Foundation
struct FilterParameters {
    var email: String?
    var category: String?
    var type: String?
    var minAge: Int?
    var maxAge: Int?
    var minPrice: Int?
    var maxPrice: Int?
    var yourRating: Int?

    init(email: String?, category: String?, type: String?, minAge: Int?, maxAge: Int?, minPrice: Int?, maxPrice: Int?, yourRating: Int?) {
        self.email = email
        self.category = category
        self.type = type
        self.minAge = minAge
        self.maxAge = maxAge
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.yourRating = yourRating
    }
}
