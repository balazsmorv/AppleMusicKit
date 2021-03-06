//
//  Authorization.swift
//  AppleMusicHelper
//
//  Created by Balázs Morvay on 2021. 03. 06..
//

import Foundation
import StoreKit
import Combine
import RxSwift


/// Manages authorizations
public class Authorization {
    
    // MARK: - Private funcs
    
    /// Fetches the Apple musi capabilities
    @available(iOS 13, *)
    private func getCapabilities() -> Future<SKCloudServiceCapability, Error> {
        return Future<SKCloudServiceCapability, Error> { promise in
            let controller = SKCloudServiceController()
            controller.requestCapabilities { (capabilities: SKCloudServiceCapability, error: Error?) in
                guard error == nil else { promise(.failure(error!)); return }
                promise(.success(capabilities))
            }
        }
    }
    
    
    // MARK: - Public API
    
    public init() {}
    
    /// Returns if the user has granted authorization to the music library
    public func authorizationGranted() -> AppleMusicAuthorizationStatus {
        switch SKCloudServiceController.authorizationStatus() {
        case .authorized: return .autorized
        case .denied: return .denied
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        @unknown default: return .notDetermined
        }
    }
    
    
    /// Prompts the user for access, and returns the `Bool` value, wheter the permission was granted or not.
    @available(iOS 13, *)
    public func requestAuthorization() -> Future<Bool, Never> {
        return Future<Bool, Never> { promise in
            SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
                switch status {
                case .denied, .restricted, .notDetermined: promise(.success(false))
                case .authorized: promise(.success(true))
                @unknown default: break
                }
            }
        }
    }
    
    
    /// Tells if we can show the apple music subscription page. The return type is `AnyPublisher`, but it wraps a `Future`, so it fires only once.
    @available(iOS 13, *)
    public func eligibleForSubscriptionOffer() -> AnyPublisher<Bool, Error> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.musicCatalogPlayback) && capabilities.contains(.musicCatalogSubscriptionEligible)
        }.eraseToAnyPublisher()
    }
    
    
    /// Tells if the user can play back apple music content. This doesnt mean they have a subscription tho.
    @available(iOS 13, *)
    public func canPlayAppleMusicContent() -> AnyPublisher<Bool, Error> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.musicCatalogPlayback)
        }.eraseToAnyPublisher()
    }
    
    
    /// Tells if we can add to the users cloud music library
    @available(iOS 13, *)
    public func canAddToMusicLibrary() -> AnyPublisher<Bool, Error> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.addToCloudMusicLibrary)
        }.eraseToAnyPublisher()
    }
    
}





// MARK: -  RxSwift implementations

extension Authorization {
    
    /// Fetches the Apple music capabilities
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    private func getCapabilities() -> Single<SKCloudServiceCapability> {
        return Single<SKCloudServiceCapability>.create { (single) -> Disposable in
            let disposable = Disposables.create()
            
            let controller = SKCloudServiceController()
            controller.requestCapabilities { (capabilities: SKCloudServiceCapability, error: Error?) in
                if let error = error {
                    single(.error(error))
                } else {
                    single(.success(capabilities))
                }
            }
            
            return disposable
        }
    }
    
    /// Prompts the user for access, and returns the `Bool` value, wheter the permission was granted or not.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func requestAuthorization() -> Single<Bool> {
        return Single<Bool>.create { (single) -> Disposable in
            SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
                switch status {
                case .denied, .restricted, .notDetermined: single(.success(false))
                case .authorized: single(.success(true))
                @unknown default: break
                }
            }
            return Disposables.create()
        }
    }
    
    
    /// Tells whether we can show the apple music subscription page.
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func eligibleForSubscriptionOffer() -> Single<Bool> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.musicCatalogPlayback) && capabilities.contains(.musicCatalogSubscriptionEligible)
        }
    }
    
    
    /// Tells if the user can play back apple music content. This doesnt mean they have a subscription tho!
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func canPlayAppleMusicContent() -> Single<Bool> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.musicCatalogPlayback)
        }
    }
    
    
    /// Tells if we can add to the users cloud music library
    @available(iOS, deprecated: 13, message: "Use the Combine version in iOS 13+")
    public func canAddToMusicLibrary() -> Single<Bool> {
        return getCapabilities().map { (capabilities: SKCloudServiceCapability) -> Bool in
            capabilities.contains(.addToCloudMusicLibrary)
        }
    }

}
