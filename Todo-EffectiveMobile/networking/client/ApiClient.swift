//
//  ApiClient.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import Combine
import OSLog

protocol TodoClient {
    func execute<T:Decodable>(_ t : T.Type,request: URLRequest, type : ApiService.Requests) -> AnyPublisher<T,ApiError>
}

class ApiClient : TodoClient {
    func execute<T: Decodable>(
        _ t : T.Type,
        request : URLRequest,
        type : ApiService.Requests
    ) -> AnyPublisher<T, ApiError> {
         URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> T in
                guard let response = response as? HTTPURLResponse else {
                    throw ApiError.cannotDecodeRawData
                }
                switch response.statusCode {
                case 400...599:
                    throw ApiError.badServerResponse(code: response.statusCode)
                default:
                    break
                }
                let value = try JSONDecoder().decode(T.self, from: data)
                let url = request.url?.path ?? ""
                Logger.networking.trace("done: \(type.rawValue) \(url)")
                return value
            }
            .receive(on: DispatchQueue.main)
            .mapError{ error -> ApiError in
                let url = request.url?.path ?? ""
                Logger.networking.error("\(type.rawValue) \(url) \(error)")
                switch error {
                case let error as ApiError:
                    return error
                default:
                    return .generic(description: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

extension ApiService {
    func fetch<T: Decodable>(
        _ t : T.Type,
        type : Requests
    ) -> AnyPublisher<T, ApiError> {
        guard let url = ApiService.generateUrl(
            query: [],
            type: type
        ) else {
            return Future<T,ApiError> {
                return $0(.failure(.badUrl))
            }.eraseToAnyPublisher()
        }
        
        let request = type.getRequest(urlEndPoint: url)
        return self.client.execute(
            t.self,
            request: request,
            type: type
        )
    }
}
