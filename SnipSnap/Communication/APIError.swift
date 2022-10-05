/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

enum APIError: Error {
    
    case nonOkStatus(status: Int, response: APIErrorResponse?)
    case unknownResponse
}
