/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

import Foundation

struct LoginRequest: Codable {
        
    func login(userId: String, appleToken: String, deviceId: String) async throws -> LoginResponse {
        
        var request = URLRequest(url: APIEndpoint.login.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userId, forHTTPHeaderField: APIHeader.userId.rawValue)
        request.setValue(APIHeader.authorizationPrefix.rawValue + appleToken, forHTTPHeaderField: APIHeader.authorization.rawValue)
        request.setValue(deviceId, forHTTPHeaderField: APIHeader.deviceId.rawValue)
    
        let encoded = try JSONEncoder().encode(self)
    
        do {
            let (data, r) = try await URLSession.shared.upload(for: request, from: encoded)
            guard let response = r as? HTTPURLResponse else {
                throw APIError.unknownResponse
            }
            guard (200...299).contains(response.statusCode) else {
                print("Got a non 2xx get nonce response")
                print(String(decoding: data, as: UTF8.self))
                throw APIError.nonOkStatus(status: response.statusCode, response: try? JSONDecoder().decode(APIErrorResponse.self, from: data))
            }
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        }
    }
}

struct LoginResponse: Codable {
    
    let serverMessage: String
}
