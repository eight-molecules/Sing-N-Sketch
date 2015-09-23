//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class AudioInterface {
    var input: AKAudioInput!
    var analyzer: AKAudioAnalyzer!
    var frequency: Double! = 0
    
    init() {
        let input = AKAudioInput()
        let analyzer = AKAudioAnalyzer(input: input)
        update()
    }
    
    func update() {
        let frequency = analyzer.trackedFrequency.value
    }
}