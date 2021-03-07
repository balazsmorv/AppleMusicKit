//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 07..
//

import Foundation
import Combine
import RxSwift
import SwiftyJSON





public class Networking {
    
    
    /// Returns a JSON publisher for the given request
    @available(iOS 13, *)
    public func json(for request: URLRequest) -> AnyPublisher<JSON, Error> {
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200, httpResponse.statusCode < 300 else {
                    throw APIError.storefrontError(message: "HTTP response code not OK")
                }
                return data
            }
            .tryMap { (data: Data) -> JSON in
                if let json = try? JSON(data: data) {
                    return json
                } else {
                    throw APIError.storefrontError(message: "No JSON object found")
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    /// Returns a JSON publisher for the given request
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func json(for request: URLRequest) -> Single<JSON> {
        return Single<JSON>.create { (single) -> Disposable in
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 300, statusCode >= 200 else {
                    single(.error(APIError.storefrontError(message: "HTTP response code not in the 200-300 range")))
                    return
                }
                
                if let data = data, let json = try? JSON(data: data) {
                    single(.success(json))
                } else {
                    single(.error(APIError.storefrontError(message: "No JSON object found")))
                }
            }
            
            return Disposables.create()
        }
    }
    
    
}
