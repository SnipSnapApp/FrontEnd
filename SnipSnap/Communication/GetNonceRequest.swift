/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

import Foundation

struct NonceRequest: Codable {
    
    let deviceId: String
    
    func getNonce() async throws -> NonceResponse {
    
        print("Making get nonce url request")
    
        var request = URLRequest(url: APIEndpoint.getNonce.url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        print("Made get nonce url request")
    
        let encoded = try JSONEncoder().encode(self)
    
        do {
            print("Trying await get nonce URLSession")
            let (data, r) = try await URLSession.shared.upload(for: request, from: encoded)
            print("Got response get nonce URLSession")
            guard let response = r as? HTTPURLResponse else {
                throw APIError.unknownResponse
            }
            print("Converted get nonce response to HTTPURLResponse")
            guard (200...299).contains(response.statusCode) else {
                print("Got a non 2xx get nonce response")
                print(String(decoding: data, as: UTF8.self))
                throw APIError.nonOkStatus(status: response.statusCode, response: try? JSONDecoder().decode(APIErrorResponse.self, from: data))
            }
            print("Got a 2xx code get nonce response - returning decoded")
            return try JSONDecoder().decode(NonceResponse.self, from: data)
        }
    }
}

struct NonceResponse: Codable {
    let nonce: String
}
