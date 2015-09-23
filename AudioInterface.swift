//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class AudioInterface {
    var input: Microphone
    var analyzer: AKAudioAnalyzer
    var frequency: Double
    
    init() {
        let input = Microphone()
        let analyzer = AKAudioAnalyzer(audioSource: microphone.auxilliaryOutput)
        update()
    }
    
    func update() {
        let frequency = analyzer.trackedFrequency.value
    }
}