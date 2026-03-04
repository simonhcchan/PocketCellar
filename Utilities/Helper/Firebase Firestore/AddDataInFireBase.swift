//
//  AddDataInFireBase.swift
//  PocketCellar
//
//  Created by IE15 on 16/03/24.
//

import Foundation
import Firebase

class AddDataInFireBase {
    static let shared = AddDataInFireBase()
    init(){}
    
    public func addUserInDataBase(firstName: String, lastName: String, email: String, password: String, age: String, alcohol: String , gender: String , completion: @escaping (Bool, Error?) -> Void) {
        
        guard let userID = UserDefaultsManager.getUserEmail() else {
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let document = document, document.exists {
                print("User document exists, performing update if needed")
                // Handle document update if needed (not implemented in this example)
                // For now, just call completion with success
                completion(true, nil)
            } else {
                print("User document does not exist, adding new document")
                let userData: [String: Any] = [
                    "userFirstName": firstName,
                    "userLastName": lastName,
                    "email": email,
                    "password": password,
                    "age": age,
                    "gender": gender,
                    "alcohol": alcohol,
                    "fcmToken" : UserDefaultsManager.getFcmToken() ?? ""
                ]
                
                // Add new document
                userRef.setData(userData) { error in
                    if let error = error {
                        print("Error adding user data: \(error.localizedDescription)")
                        completion(false, error) // Call completion with failure
                    } else {
                        print("User data added successfully!")
                        completion(true, nil) // Call completion with success
                    }
                }
            }
        }
    }
    func addNewPost(details: AlcoholDetailsModel, completion: @escaping (Error?) -> Void) {
        var data = toDictionary(alcoholDetails: details)
        let collectionRef = Firestore.firestore().collection("Posts")
        
        if let documentId = details.documentId {
            // Document ID exists, update the document
            let documentRef = collectionRef.document(documentId)
            documentRef.updateData(data) { error in
                if let error = error {
                    print("Error updating post: \(error.localizedDescription)")
                    completion(error) // Call completion handler with error
                } else {
                    print("Post updated successfully!")
                    completion(nil) // Call completion handler with nil error indicating success
                }
            }
        } else {
            // Document ID does not exist, create a new document
            collectionRef.addDocument(data: data) { error in
                if let error = error {
                    print("Error adding post: \(error.localizedDescription)")
                    completion(error) 
                } else {
                    print("Post added successfully!")
                    completion(nil)
                }
            }
        }
    }



        func toDictionary(alcoholDetails:AlcoholDetailsModel)->[String:Any]{
                let dict: [String: Any] = [
                    "category": alcoholDetails.category ?? "",
                    "type": alcoholDetails.type ?? "",
                    "name": alcoholDetails.name ?? "",
                    "image": alcoholDetails.image ?? "",
                    "email": alcoholDetails.email ?? "",
                    "origin": alcoholDetails.origin ?? "",
                    "price": alcoholDetails.price ?? 0,
                    "currency": alcoholDetails.currency ?? "$",
                    "age": alcoholDetails.age ?? 0,
                    "shopFrom": alcoholDetails.shopFrom ?? "",
                    "maker": alcoholDetails.maker ?? "",
                    "purchaseDate":alcoholDetails.purchaseDate ?? "" ,
                    "yourRating": alcoholDetails.yourRating ?? 0,
                    "doYouRecommended": alcoholDetails.doYouRecommended ?? false,
                    "yourReview": alcoholDetails.yourReview ?? "",
                    "yourRemark": alcoholDetails.yourRemark ?? "",
                    "timestamp": alcoholDetails.timeStamp 
                ]
            return dict
        }
    func updateUserDetails(forEmail email: String, withData userData: [String: Any], completion: @escaping (Error?) -> Void) {
        let collectionRef = Firestore.firestore().collection("users")
        let documentRef = collectionRef.document(email)
        
        documentRef.updateData(userData) { error in
            if let error = error {
                print("Error updating user details: \(error.localizedDescription)")
                completion(error)
            } else {
                print("User details updated successfully!")
                completion(nil)
            }
        }
    }
    }
   
