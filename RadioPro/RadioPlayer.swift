//
//  RadioPlayer.swift
//  RadioPro
//
//  Created by Faizan Naseem on 18/04/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import Foundation
import AVFoundation

class RadioPlayer {
    
    static var player: iHAKAudioPlayer?
    
    var station: Audio? {
        didSet {
            print("Audio \(station!.audioId)")
        }
    }
    
    static func setup(url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        player = iHAKAudioPlayer(url: url)
        player?.setup()
    }
}
