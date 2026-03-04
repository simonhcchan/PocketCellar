//
//  FirestoreCollection.swift
//  Srila Prabhupada
//
//  Created by IE on 9/22/22.
//

import Foundation

enum FirestoreCollection {
    case alcohols
    case users
    case groupMembers(group: String)
    case messages(group: String)
    
    var path: String {
        
        switch self {
        case .alcohols:
            return "Alcohols"
        case .users:
            return "Users"
        case .groupMembers(group: let group):
            return "Groups/\(group)/Users"
        case .messages(group: let group):
            return "Groups/\(group)/Messages"
        }
    }
}

