//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class AudioInterface {
    var input: AKMicrophone = AKMicrophone()
    var analyzer: AKAudioAnalyzer!
    var frequency: Float = 0
    var amplitude: Float = 1
    var noiseFloor: Float = 0
    var bufferSize: Int = 200
    init() {
        AKSettings.shared().audioInputEnabled = true
        
        analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
    }
    
    func start() {
        input.start()
        analyzer.start()
        frequency = analyzer.trackedFrequency.floatValue
    }
    
    func stop() {
        input.stop()
        analyzer.stop()
    }
    
    func update() {
        for(var i = 0; i < bufferSize; i++) {
            amplitude += analyzer.trackedAmplitude.floatValue
            frequency += analyzer.trackedFrequency.floatValue
        }
        amplitude /= Float(bufferSize)
        frequency /= Float(bufferSize)
    }
        
}