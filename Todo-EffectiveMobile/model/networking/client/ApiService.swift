//
//  ApiService.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

class ApiService  {
    let client : TodoClient
    
    init(client : TodoClient = ApiClient()) {
        self.client = client
    }
    
    enum Requests : String,Equatable {
        case todoList
        
        var method : String {
            switch self {
            default:
                "GET"
            }
        }
        
        var headers : [(value : String, key : String)] {
            switch self {
            default:
                return []
            }
        }
        
        var path : String {
            switch self {
                case .todoList:
                    return "/todos"
            }
        }
        
        func getRequest(urlEndPoint : URL) -> URLRequest {
            switch self {
            default:
                var req = URLRequest(url : urlEndPoint)
                req.httpMethod = self.method
                for header in self.headers {
                    req.addValue(header.value, forHTTPHeaderField: header.key)
                }
                return req
            }
        }
    }

    static func generateUrl(query : [URLQueryItem], type : Requests) -> URL? {
        let url : URL? = {
            switch type {
            default:
                var components = URLComponents()
                components.path = type.path
                components.host = Constants.ApiData.urlBase
                components.scheme = "https"
                components.queryItems = query
                return components.url
            }
        }()
        return url
    }
}

