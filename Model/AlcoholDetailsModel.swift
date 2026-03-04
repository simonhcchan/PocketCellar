//
//  AlcoholDetailsModel.swift
//  PocketCellar
//
//  Created by IE15 on 14/03/24.
//

import Foundation
import UIKit
import FirebaseFirestoreInternal

struct AlcoholDetailsModel {
    let image: String?
    let category: String?
    let type: String?
    let name: String?
    let maker: String?
    let email: String?
    let origin: String?
    let price: Int?
    let currency: String?
    let age: Int?
    let shopFrom: String?
    let purchaseDate: String?
    let yourRating: Int?
    let doYouRecommended: Bool?
    let yourReview: String?
    let yourRemark: String?
    let timeStamp:Timestamp?
    let documentId:String?
}
