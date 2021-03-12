//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 06..
//

import Foundation
import MediaPlayer


public class MusicPlayer {
    
    private let musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    public init() {}
    
    let query = MPMediaQuery()
    
    public func play(title: String) {
        
        query.addFilterPredicate(MPMediaPropertyPredicate(value: title,
                                                          forProperty: MPMediaItemPropertyTitle,
                                                          comparisonType: .contains))
        
        musicPlayer.setQueue(with: query)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    public func play() {
        musicPlayer.setQueue(with: .songs())
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    public func next() {
        musicPlayer.skipToNextItem()
    }
    
    public func previous() {
        musicPlayer.skipToPreviousItem()
    }

    public func stop() {
        musicPlayer.stop()
    }
    
}

