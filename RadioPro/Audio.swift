//
//  Audio.swift
//  RadioPro
//
//  Created by Faizan Naseem on 18/04/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import Foundation

class Audio {
    var audioId: Int
    let audioUrl : String
    
    init(audioId: Int, audioUrl: String) {
        self.audioId = audioId
        self.audioUrl = audioUrl
    }
}

extension Audio: Equatable {
    
    static func ==(lhs: Audio, rhs: Audio) -> Bool {
        return true
    }
}
