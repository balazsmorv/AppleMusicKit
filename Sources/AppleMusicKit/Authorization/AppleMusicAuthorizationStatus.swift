//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 06..
//

import Foundation

public enum AppleMusicAuthorizationStatus {
    
    /// The user has given authorization to access their library
    case autorized
    
    /// The permission was not granted
    case denied
    
    /// Apple music is restricted, for example in education accounts
    case restricted
    
    /// We havent asked yet
    case notDetermined
    
}
