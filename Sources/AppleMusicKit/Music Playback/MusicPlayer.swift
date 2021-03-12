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
    
    public func play(title: String) {
        
        query.addFilterPredicate(MPMediaPropertyPredicate(value: title,
                                                          forProperty: MPMediaItemPropertyTitle,
                                                          comparisonType: .equalTo))
        
        musicPlayer.setQueue(with: query)
        musicPlayer.play()
    }

    public func stop() {
        musicPlayer.stop()
    }
    
}
#endif
