//
//  PushNotificationAPI.swift
//  PocketCellar
//
//  Created by Muhammad Haris on 24/10/2024.
//

import Foundation


class PushNotificationAPI {

    static let shared = PushNotificationAPI() // Singleton instance

    private init() {}

    func sendPushNotification(deviceTokens: [String], title: String, body: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // API URL
        guard let url = URL(string: "https://appcratesoperations.com/push_notification/public/api/sendMobPushNotification") else {
            return
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the parameters
        let parameters: [String: Any] = [
            "deviceToken": deviceTokens,
            "title": title,
            "body": body
        ]

        // Convert parameters to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // Create URL session
        let session = URLSession.shared

        // Start the data task
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check for valid HTTP response
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                let statusError = NSError(domain: "PushNotificationAPI", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
                completion(.failure(statusError))
            }
        }

        task.resume()
    }
}
