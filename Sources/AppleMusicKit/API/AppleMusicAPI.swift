//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 07..
//

import Foundation
import SwiftyJSON
import StoreKit
import Combine
import RxSwift



public class AppleMusicAPI {
    
    // MARK: - Private properties & init
    
    private let developerToken: String
    
    private let storefrontURL = URL(string: "https://api.music.apple.com/v1/me/storefront")!
    
    public init(developerToken: String) {
        self.developerToken = developerToken
    }
    
    
    // MARK: - Private funcs
    
    private func makeGetRequest(for url: URL, userToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        return request
    }
    
    
    // MARK: - Public api
    
    /// The Apple Music API can get a user’s library and playlists. This is only possible if we receive a token that is identifiable to a particular user.
    @available(iOS 13, *)
    public func getUserToken() -> Future<String, Error> {
        return Future<String, Error> { promise in
            SKCloudServiceController().requestUserToken(forDeveloperToken: self.developerToken) { (token: String?, error: Error?) in
                if let error = error {
                    promise(.failure(error))
                } else if let token = token {
                    promise(.success(token))
                } else {
                    promise(.failure(APIError.noTokenNoError))
                }
            }
        }
    }
    
    /// A storefront is an object that represents the iTunes Store territory that the content is available in. When we perform a search using the Apple Music API, we’d like to show results relevant to our user’s location.
    @available(iOS 13, *)
    public func getStoreFront() -> AnyPublisher<String, Error> {
        getUserToken()
            .flatMap { (userToken) in
                
                Networking()
                    .json(for: self.makeGetRequest(for: self.storefrontURL, userToken: userToken))
                    .tryMap { json -> String in
                        if let result = (json["data"]).array, let first = result.first, let id = (first.dictionaryValue)["id"] {
                            return id.stringValue
                        } else {
                            throw APIError.storefrontError(message: "ID data cannot be retriebed from the json object")
                        }
                    }
                
            }.eraseToAnyPublisher()
        
    }
    
    
}


extension AppleMusicAPI {
    
    /// The Apple Music API can get a user’s library and playlists. This is only possible if we receive a token that is identifiable to a particular user.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func getUserToken() -> Single<String> {
        return Single<String>.create { (single) -> Disposable in
            
            SKCloudServiceController().requestUserToken(forDeveloperToken: self.developerToken) { (token: String?, error: Error?) in
                if let error = error {
                    single(.error(error))
                } else if let token = token {
                    single(.success(token))
                } else {
                    single(.error(APIError.noTokenNoError))
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    /// A storefront is an object that represents the iTunes Store territory that the content is available in. When we perform a search using the Apple Music API, we’d like to show results relevant to our user’s location.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func getStoreFront() -> Single<String> {
        
        self.getUserToken().flatMap { (userToken) -> Single<String> in
            Networking().json(for: self.makeGetRequest(for: self.storefrontURL,
                                                       userToken: userToken))
                .map { (json) -> String in
                    if let result = (json["data"]).array, let first = result.first, let id = (first.dictionaryValue)["id"] {
                        return id.stringValue
                    } else {
                        throw APIError.storefrontError(message: "ID data cannot be retrieved from the json object")
                    }
                }
        }
        
    }
    
    
}


public enum APIError: Error {
    case noTokenNoError
    case storefrontError(message: String)
}
