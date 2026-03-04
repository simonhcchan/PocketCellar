//
//  FirestoreManager.swift
//  Srila Prabhupada
//
//  Created by Iftekhar on 9/23/22.
//

//import Foundation
//import FirebaseFirestore
////import FirebaseFirestoreSwift
//
//class FirestoreManager: NSObject {
//    
//    static let shared = FirestoreManager()
//    
//    var alcohols: CollectionReference {
//        return firestore.collection(FirestoreCollection.alcohols.path)
//    }
//    
//    var users: CollectionReference {
//        return firestore.collection(FirestoreCollection.users.path)
//    }
//    
//    let firestore: Firestore = {
//        let firestore: Firestore = Firestore.firestore()
//        let settings = firestore.settings
//        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
//        firestore.settings = settings
//        return firestore
//    }()
//        
//    override private init() {
//        super.init()
//    }
//    
//    func getRawDocuments(query: Query, source: FirestoreSource = .default, completion: @escaping ((Swift.Result<[QueryDocumentSnapshot], Error>) -> Void)) {
//        query.dGetRawDocuments(source: source, completion: completion)
//    }
//    
//    func getDocuments<T: Decodable>(query: Query, source: FirestoreSource = .default, completion: @escaping ((Swift.Result<[T], Error>) -> Void)) {
//        query.dGetDocuments(source: source, completion: completion)
//    }
//    
//    func getDocument<T: Decodable>(documentReference: DocumentReference, source: FirestoreSource = .default, completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
//        documentReference.dGetDocument(source: source, completion: completion)
//    }
//    
//    func getRawDocument(documentReference: DocumentReference, source: FirestoreSource = .default, completion: @escaping ((Swift.Result<DocumentSnapshot, Error>) -> Void)) {
//        documentReference.dGetRawDocument(source: source, completion: completion)
//    }
//    
//    func updateDocument<T: Decodable>(documentData: [String: Any], documentReference: DocumentReference, completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
//        documentReference.updateDocument(documentData: documentData, completion: completion)
//    }
//}
//
//extension Query {
//    
//    fileprivate func dGetRawDocuments(source: FirestoreSource, completion: @escaping ((Swift.Result<[QueryDocumentSnapshot], Error>) -> Void)) {
//        //        DispatchQueue.global().async {
//        self.getDocuments(completion: { snapshot, error in
//            
//            if let error = error {
//                completion(.failure(error))
//            } else if let documents: [QueryDocumentSnapshot] = snapshot?.documents {
//                completion(.success(documents))
//            } else {
//                let error = NSError(domain: "Firestore Database", code: 0, userInfo: [NSLocalizedDescriptionKey: "Documents are not available"])
//                completion(.failure(error))
//            }
//        })
//        //        }
//    }
//    
//    fileprivate func dGetDocuments<T: Decodable>(source: FirestoreSource, completion: @escaping ((Swift.Result<[T], Error>) -> Void)) {
//        
//        dGetRawDocuments(source: source, completion: { result in
//            switch result {
//            case .success(let documents):
//                DispatchQueue.global().async {
//                    do {
//                        let objects = try documents.map({ try $0.data(as: T.self) })
//                        DispatchQueue.main.async {
//                            completion(.success(objects))
//                        }
//                    } catch let error {
//                        DispatchQueue.main.async {
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            case .failure(let error):
//                mainThreadSafe {
//                    completion(.failure(error))
//                }
//            }
//        })
//    }
//}
//
//extension DocumentReference {
//    
//    fileprivate func dGetRawDocument(source: FirestoreSource, completion: @escaping ((Swift.Result<DocumentSnapshot, Error>) -> Void)) {
//        //        DispatchQueue.global().async {
//        self.getDocument(source: source, completion: { snapshot, error in
//            if let error = error {
//                completion(.failure(error))
//            } else if let document: DocumentSnapshot = snapshot {
//                completion(.success(document))
//            } else {
//                let error = NSError(domain: "Firestore Database", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document is not available"])
//                completion(.failure(error))
//            }
//        })
//        //        }
//    }
//    
//    fileprivate func dGetDocument<T: Decodable>(source: FirestoreSource, completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
//        dGetRawDocument(source: source, completion: { result in
//            switch result {
//            case .success(let document):
//                
//                DispatchQueue.global().async {
//                    do {
//                        let object = try document.data(as: T.self)
//                        DispatchQueue.main.async {
//                            completion(.success(object))
//                        }
//                    } catch let error {
//                        DispatchQueue.main.async {
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            case .failure(let error):
//                mainThreadSafe {
//                    completion(.failure(error))
//                }
//            }
//        })
//    }
//    
//    func updateDocument<T: Decodable>(documentData: [String: Any], completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
//        //        DispatchQueue.global().async {
//        self.setData(documentData, merge: true, completion: { error in
//            if let error = error {
//                mainThreadSafe {
//                    completion(.failure(error))
//                }
//            } else {
//                self.dGetDocument(source: .default, completion: completion)
//            }
//        })
//        //        }
//    }
//}
