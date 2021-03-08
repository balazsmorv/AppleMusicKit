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
    
    public func play() {
        musicPlayer.setQueue(with: .songs())
        musicPlayer.play()
    }
    
    public func playLast() {
        musicPlayer.play()
    }
    
    public func stop() {
        musicPlayer.stop()
    }
    
}
#endif
