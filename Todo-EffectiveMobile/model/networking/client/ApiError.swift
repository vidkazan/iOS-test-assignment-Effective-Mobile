//
//  ApiError.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

enum ApiError : Error {
    static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case badUrl
    case cannotConnectToHost(String)
    case badServerResponse(code : Int)
    case cannotDecodeRawData
    case cannotDecodeContentData
    case badRequest
    case requestRateExceeded
    case generic(description : String)
    
    var localizedDescription : String  {
        switch self {
        case .generic(let description):
            return description
        case .badUrl:
            return NSLocalizedString(
                "Bad url",
                comment: "ApiError"
            )
        case .cannotConnectToHost(let string):
            return string
        case .badServerResponse(let code):
            return NSLocalizedString(
                "Bad server response \(code)",
                comment: "ApiError"
            )
        case .cannotDecodeRawData:
            return NSLocalizedString(
                "Server response data nil",
                comment: "ApiError"
            )
        case .cannotDecodeContentData:
            return NSLocalizedString(
                "Server response data decoding",
                comment: "ApiError"
            )
        case .badRequest:
            return NSLocalizedString(
                "Bad search request",
                comment: "ApiError"
            )
        case .requestRateExceeded:
            return NSLocalizedString(
                "Request rate exceeded",
                comment: "ApiError"
            )
        }
    }
}
