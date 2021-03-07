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


/// API class for Apple music. All the networking is done within the Networking.swift file. The format of the returned JSON is specified here:
/// https://developer.apple.com/documentation/applemusicapi/responseroot
public class AppleMusicAPI {
    
    // MARK: - Private properties & init
    
    private let developerToken: String
    private var userToken: String? = nil
    
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
    
    
    /// Returns woth the appropriate search url for the specified parameters
    private func makeSearchURL(storefrontID: String, term: String, type: String, limit: Int = 20) -> URL {
        return URL(string: "https://api.music.apple.com/v1/catalog/\(storefrontID)/search?term=\(term.replacingOccurrences(of: " ", with: "+"))&types=\(type)&limit=\(limit)")!
    }

    
    /// The Apple Music API can get a user’s library and playlists. This is only possible if we receive a token that is identifiable to a particular user.
    @available(iOS 13, *)
    private func fetchUserToken() -> Future<String, Error> {
        return Future<String, Error> { promise in
            SKCloudServiceController().requestUserToken(forDeveloperToken: self.developerToken) { (token: String?, error: Error?) in
                if let error = error {
                    promise(.failure(error))
                } else if let token = token {
                    self.userToken = token
                    promise(.success(token))
                } else {
                    promise(.failure(APIError.noTokenNoError))
                }
            }
        }
    }
    
    // MARK: - Public api
    
    // TODO: Refresh the user token now and then...
    /// Returns the catched user token, or fetches it, if its nil.
    @available(iOS 13, *)
    public func getUserToken() -> AnyPublisher<String, Error> {
        if let token = self.userToken {
            return Just<String>(token).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return fetchUserToken().eraseToAnyPublisher()
        }
    }
    
    
    /// A storefront is an object that represents the iTunes Store territory that the content is available in. When we perform a search using the Apple Music API, we’d like to show results relevant to our user’s location.
    @available(iOS 13, *)
    public func getStoreFront() -> AnyPublisher<String, Error> {
        fetchUserToken()
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
    
    
    /// Searches for the term, amongst songs.
    @available(iOS 13, *)
    public func searchSongs(for term: String) -> AnyPublisher<[Song], Error> {
        getUserToken().zip(getStoreFront()).flatMap { (userToken, storeFront) in
            Networking()
                .json(for: self.makeGetRequest(for: self.makeSearchURL(storefrontID: storeFront, term: term, type: "songs"), userToken: userToken))
                .tryMap { json in
                    if let results = json["results"]["songs"]["data"].array {
                        return results.map { json -> Song in
                            let attributes = json["attributes"]
                            return Song(id: attributes["playParams"]["id"].string!,
                                 name: attributes["name"].string!,
                                 artistName: attributes["artistName"].string!,
                                 artworkURL: attributes["artwork"]["url"].string!)
                        }
                    } else {
                        throw APIError.searchError(message: "JSON not the right format")
                    }
                }
        }.eraseToAnyPublisher()
    }
    
    
}









extension AppleMusicAPI {
    
    /// The Apple Music API can get a user’s library and playlists. This is only possible if we receive a token that is identifiable to a particular user.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    private func fetchUserToken() -> Single<String> {
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
    
    
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func getUserToken() -> Observable<String> {
        if let token = self.userToken {
            return Observable.just(token)
        } else {
            return self.fetchUserToken().asObservable()
        }
    }
    
    
    
    
    /// A storefront is an object that represents the iTunes Store territory that the content is available in. When we perform a search using the Apple Music API, we’d like to show results relevant to our user’s location.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func getStoreFront() -> Single<String> {
        
        self.fetchUserToken().flatMap { (userToken) -> Single<String> in
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
    
    
    /// Searches for the term, amongst songs.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func searchSongs(for term: String) -> Observable<[Song]> {
        return Observable.zip(getUserToken(), getStoreFront().asObservable()).flatMap { (userToken, storeFront) in
            Networking()
                .json(for: self.makeGetRequest(for: self.makeSearchURL(storefrontID: storeFront, term: term, type: "songs"), userToken: userToken))
                .map { json in
                    if let results = json["results"]["songs"]["data"].array {
                        return results.map { json -> Song in
                            let attributes = json["attributes"]
                            return Song(id: attributes["playParams"]["id"].string!,
                                        name: attributes["name"].string!,
                                        artistName: attributes["artistName"].string!,
                                        artworkURL: attributes["artwork"]["url"].string!)
                        }
                    } else {
                        throw APIError.searchError(message: "JSON not the right format")
                    }
                }
        }
    }
    
    
}


public enum APIError: Error {
    case noTokenNoError
    case storefrontError(message: String)
    case searchError(message: String)
}
