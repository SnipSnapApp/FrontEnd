/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

import Foundation

enum APIEndpoint: String {

    private var baseURL: String {
        "https://7osxrt1c19.execute-api.us-west-2.amazonaws.com/"
    }

    case login = "login"
    case getNonce = "get-nonce"

    private var fullPath: String {
        baseURL + self.rawValue
    }

    var url: URL {
        guard let url = URL(string: fullPath) else {
            preconditionFailure("The url used in \(APIEndpoint.self) is not valid")
        }
        return url
    }
}

enum APIHeader: String {

    case userId = "X-UserId"
    case authorization = "Authorization"
    case deviceId = "X-DeviceId"
    case authorizationPrefix = "Bearer "
}
