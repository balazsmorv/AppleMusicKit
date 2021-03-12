//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 06..
//

import Foundation
import MediaPlayer

#if !os(macOS)
public class MusicPlayer {
    
    private let musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    public init() {}
    
    let query = MPMediaQuery()
    
    public func play() {
        
        query.addFilterPredicate(MPMediaPropertyPredicate(value: "love",
                                                          forProperty: MPMediaItemPropertyTitle,
                                                          comparisonType: .contains))
        musicPlayer.setQueue(with: query)
        musicPlayer.play()
    }

    public func stop() {
        musicPlayer.stop()
    }
    
}
#endif
