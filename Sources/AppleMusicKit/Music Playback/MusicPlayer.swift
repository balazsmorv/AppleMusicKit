//
//  File.swift
//  
//
//  Created by Balázs Morvay on 2021. 03. 06..
//

import Foundation
import MediaPlayer

class MusicPlayer {
    
    private let musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    public func play() {
        musicPlayer.setQueue(with: .songs())
        musicPlayer.play()
    }
    
    public func stop() {
        musicPlayer.stop()
    }
    
}
