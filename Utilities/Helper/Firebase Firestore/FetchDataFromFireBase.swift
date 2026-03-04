//
//  FetchDataFromFireBase.swift
//  PocketCellar
//
//  Created by IE15 on 16/03/24.
//

import Foundation
import Firebase

class FetchDataFromFireBase {
    static let shared = FetchDataFromFireBase()
    static var isLoading: Bool = true
    init () {
        
    }
    func deleteUser(UserEmail documentID: String, completion: @escaping (Error?) -> Void) {
        let docRef = Firestore.firestore().collection("users").document(documentID)
        docRef.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Document successfully deleted")
                completion(nil)
            }
        }
    }
    public func checkUserVerification(email: String, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email.lowercased())
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                }
                if let _ = querySnapshot?.documents.first {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    public func checkCredentials(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: password)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    completion(false) // Indicate an error occurred
                    return
                }
                if let _ = querySnapshot?.documents.first {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
    public func fetchSubCategoryOFAlcohols(name: String, completion: @escaping ([AlcoholSubGroup]) -> Void) {
        var alcohols: [AlcoholSubGroup] = []
        Firestore.firestore().collection("Alcohols").document(name).collection(name).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let documentRef = Firestore.firestore().collection("Alcohols").document(name).collection(name).document(document.documentID)
                documentRef.getDocument(completion: { (document, error) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let document = document, document.exists {
                        if let doc = document.data() {
                            if let name = doc["name"] as? String, let image = doc["image"] as? String, let sequence = doc["sequence"] as? Int {
                                let alcohol = AlcoholSubGroup(name: name, image: image, sequence: sequence)
                                alcohols.append(alcohol)
                            }
                        }
                    }
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(alcohols)
            }
        }
    }
    
    public func fetchSubCategoryNames(name: String, completion: @escaping ([String]) -> Void) {
        var documentIDs: [String] = []
        Firestore.firestore().collection("Alcohols").document(name).collection(name).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            for document in documents {
                documentIDs.append(document.documentID.localized()) // Add document ID to the array
            }
            completion(documentIDs) // Complete with the array of document IDs
        }
    }
    
    func fetchCategoryOFAlcohols(completion: @escaping ([AlcoholGroup]) -> Void) {
        var alcohols: [AlcoholGroup] = []
        
        Firestore.firestore().collection("Alcohols").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let documentRef = Firestore.firestore().collection("Alcohols").document(document.documentID)
                documentRef.getDocument(completion: { (document, error) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let document = document, document.exists {
                        if let doc = document.data() {
                            if let name = doc["name"] as? String, let image = doc["image"] as? String,let age = doc["age"] as? String ,let sequence = doc["sequence"] as? Int {
                                let alcohol = AlcoholGroup(name: name, image: image, age: age,
                                                           sequence: sequence)
                                alcohols.append(alcohol)
                            }
                        }
                    }
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(alcohols)
            }
        }
    }
    
    func fetchCategoryNames(completion: @escaping ([String]) -> Void) {
        var documentIDs: [String] = [] // Array to store document IDs
        Firestore.firestore().collection("Alcohols").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            for document in documents {
                documentIDs.append(document.documentID.localized())
            }
            
            completion(documentIDs)
        }
    }
    
    
    func fetchAllPosts(completion: @escaping ([AlcoholDetailsModel]) -> Void) {
        var alcoholDetailsArray = [AlcoholDetailsModel]()
        
        Firestore.firestore().collection("Posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let documentRef = Firestore.firestore().collection("Posts").document(document.documentID)
                documentRef.getDocument(completion: { (document, error) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let document = document, document.exists {
                        if let doc = document.data() {
                            if let image = doc["image"] as? String ,
                               let category = doc["category"] as? String,
                               let type = doc["type"] as? String,
                               let name = doc["name"] as? String,
                               let maker = doc["maker"] as? String,
                               let email = doc["email"] as? String,
                               let origin = doc["origin"] as? String,
                               let price = doc["price"] as? Int,
                               let currency = doc["currency"] as? String,
                               let age = doc["age"] as? Int,
                               let shopFrom = doc["shopFrom"] as? String,
                               let purchaseDate = doc["purchaseDate"] as? String,
                               let yourRating = doc["yourRating"] as? Int,
                               let doYouRecommended = doc["doYouRecommended"] as? Bool,
                               let yourReview = doc["yourReview"] as? String,
                               let yourRemark = doc["yourRemark"] as? String,
                               let timeStamp = doc["timestamp"] as? Timestamp {
                                
                                let alcoholDetails = AlcoholDetailsModel(
                                    image: image,
                                    category: category,
                                    type: type,
                                    name: name,
                                    maker: maker,
                                    email: email,
                                    origin: origin,
                                    price: price,
                                    currency: currency,
                                    age: age,
                                    shopFrom: shopFrom,
                                    purchaseDate: purchaseDate,
                                    yourRating: yourRating,
                                    doYouRecommended: doYouRecommended,
                                    yourReview: yourReview,
                                    yourRemark: yourRemark, timeStamp: timeStamp, documentId: document.documentID
                                )
                                alcoholDetailsArray.append(alcoholDetails)
                            } else {
                                print("Error: Document data is nil")
                            }
                        }
                    } else {
                        print("Error: Document does not exist")
                    }
                })
            }
            
            dispatchGroup.notify(queue: .main) {
                let sortedArray = alcoholDetailsArray.sorted { (first, second) -> Bool in
                    if let firstDate = first.timeStamp?.dateValue(), let secondDate = second.timeStamp?.dateValue() {
                        return firstDate > secondDate
                    } else {
                        completion(alcoholDetailsArray)
                        return false
                    }
                }
                completion(sortedArray)
            }
        }
    }
    func fetchUserPosts(forEmail email: String, completion: @escaping ([AlcoholDetailsModel]) -> Void) {
        var alcoholDetailsArray = [AlcoholDetailsModel]()
        
        Firestore.firestore().collection("Posts")
            .whereField("email", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    completion([])
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                
                for document in documents {
                    dispatchGroup.enter()
                    let documentRef = Firestore.firestore().collection("Posts").document(document.documentID)
                    documentRef.getDocument(completion: { (document, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        if let document = document, document.exists {
                            if let doc = document.data() {
                                if let image = doc["image"] as? String,
                                   let category = doc["category"] as? String,
                                   let type = doc["type"] as? String,
                                   let name = doc["name"] as? String,
                                   let maker = doc["maker"] as? String,
                                   let email = doc["email"] as? String,
                                   let origin = doc["origin"] as? String,
                                   let price = doc["price"] as? Int,
                                   let currency = doc["currency"] as? String,
                                   let age = doc["age"] as? Int,
                                   let shopFrom = doc["shopFrom"] as? String,
                                   let purchaseDate = doc["purchaseDate"] as? String,
                                   let yourRating = doc["yourRating"] as? Int,
                                   let doYouRecommended = doc["doYouRecommended"] as? Bool,
                                   let yourReview = doc["yourReview"] as? String,
                                   let yourRemark = doc["yourRemark"] as? String,
                                   let timeStamp = doc["timestamp"] as? Timestamp {
                                    
                                    let alcoholDetails = AlcoholDetailsModel(
                                        image: image,
                                        category: category,
                                        type: type,
                                        name: name,
                                        maker: maker,
                                        email: email,
                                        origin: origin,
                                        price: price,
                                        currency: currency,
                                        age: age,
                                        shopFrom: shopFrom,
                                        purchaseDate: purchaseDate,
                                        yourRating: yourRating,
                                        doYouRecommended: doYouRecommended,
                                        yourReview: yourReview,
                                        yourRemark: yourRemark, timeStamp: timeStamp, documentId: document.documentID
                                    )
                                    alcoholDetailsArray.append(alcoholDetails)
                                } else {
                                    print("Error: Document data is nil")
                                }
                            }
                        } else {
                            print("Error: Document does not exist")
                        }
                    })
                }
                
                dispatchGroup.notify(queue: .main) {
                    let sortedArray = alcoholDetailsArray.sorted { (first, second) -> Bool in
                        if let firstDate = first.timeStamp?.dateValue(), let secondDate = second.timeStamp?.dateValue() {
                            return firstDate > secondDate
                        } else {
                            completion(alcoholDetailsArray)
                            return false
                        }
                    }
                    completion(sortedArray)
                }
            }
    }
    
    func deletePost(withDocumentID documentID: String, completion: @escaping (Error?) -> Void) {
        let docRef = Firestore.firestore().collection("Posts").document(documentID)
        docRef.delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Document successfully deleted")
                completion(nil)
            }
        }
    }
    
    func fetchDataBasedOnFilter(forEmail email: String?, category: String?, type: String?, minAge: Int?, maxAge: Int?,minPrice: Int?, maxPrice: Int?, yourRating: Int?, completion: @escaping ([AlcoholDetailsModel]) -> Void) {
        FetchDataFromFireBase.isLoading = false
        var alcoholDetailsArray = [AlcoholDetailsModel]()
        
        var query: Query = Firestore.firestore().collection("Posts")
        
        if let email = email, !email.isEmpty {
            query = query.whereField("email", isEqualTo: email)
            print(email)
        }
        
        if let category = category, !category.isEmpty {
            query = query.whereField("category", isEqualTo: category)
            print(category)
        }
        
        if let type = type, !type.isEmpty {
            query = query.whereField("type", isEqualTo: type)
            print(type)
        }
        //
        if let yourRating = yourRating , yourRating > 0 {
            query = query.whereField("yourRating", isEqualTo: yourRating)
            print(yourRating)
        }
        
        if let minAge = minAge, let maxAge = maxAge {
            query = query.whereField("age", isGreaterThanOrEqualTo: minAge)
                .whereField("age", isLessThanOrEqualTo: maxAge)
            print(minAge ,maxAge)
        }
        //
        if let min = minPrice, let max = maxPrice {
            query = query.whereField("price", isGreaterThanOrEqualTo: min)
                .whereField("price", isLessThanOrEqualTo: max)
            print(min ,max)
        }
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([])
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let documentRef = Firestore.firestore().collection("Posts").document(document.documentID)
                documentRef.getDocument { (document, error) in
                    defer {
                        dispatchGroup.leave()
                    }
                    
                    if let document = document, document.exists {
                        if let doc = document.data(),
                           let image = doc["image"] as? String,
                           let category = doc["category"] as? String,
                           let type = doc["type"] as? String,
                           let name = doc["name"] as? String,
                           let maker = doc["maker"] as? String,
                           let email = doc["email"] as? String,
                           let origin = doc["origin"] as? String,
                           let price = doc["price"] as? Int,
                           let currency = doc["currency"] as? String,
                           let age = doc["age"] as? Int,
                           let shopFrom = doc["shopFrom"] as? String,
                           let purchaseDate = doc["purchaseDate"] as? String,
                           let yourRating = doc["yourRating"] as? Int,
                           let doYouRecommended = doc["doYouRecommended"] as? Bool,
                           let yourReview = doc["yourReview"] as? String,
                           let yourRemark = doc["yourRemark"] as? String,
                           let timeStamp = doc["timestamp"] as? Timestamp {
                            
                            let alcoholDetails = AlcoholDetailsModel(
                                image: image,
                                category: category,
                                type: type,
                                name: name,
                                maker: maker,
                                email: email,
                                origin: origin,
                                price: price,
                                currency: currency,
                                age: age,
                                shopFrom: shopFrom,
                                purchaseDate: purchaseDate,
                                yourRating: yourRating,
                                doYouRecommended: doYouRecommended,
                                yourReview: yourReview,
                                yourRemark: yourRemark, timeStamp: timeStamp, documentId: document.documentID
                            )
                            alcoholDetailsArray.append(alcoholDetails)
                        } else {
                            print("Error: Document data is nil")
                        }
                    } else {
                        print("Error: Document does not exist")
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                FetchDataFromFireBase.isLoading = true
                completion(alcoholDetailsArray)
            }
        }
    }
    
    public func fetchUserData(forUserID userID: String, completion: @escaping (Result<[String: Any]?, Error>) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let document = document, document.exists {
                let userData = document.data()
                completion(.success(userData))
            } else {
                completion(.success(nil))
            }
        }
    }

    public func fetchAllUserTokens(excludingUserID userID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let usersRef = Firestore.firestore().collection("users")

        usersRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            var fcmTokens: [String] = []

            for document in snapshot?.documents ?? [] {
                let data = document.data()
                if let email = data["email"] as? String, email != userID, let fcmToken = data["fcmToken"] as? String {
                    fcmTokens.append(fcmToken)
                }
            }

            completion(.success(fcmTokens))
        }
    }

}
