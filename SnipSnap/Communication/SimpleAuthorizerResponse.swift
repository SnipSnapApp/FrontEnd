/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

struct SimpleAuthorizerResponse: Codable {
    
    let isAuthorized: Bool
    let context: [String: String]
}
