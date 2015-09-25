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
    var frequency: Double = 0
    var amplitude: Double = 1
    var noiseFloor: Double = 0
    
    init() {
        AKSettings.shared().audioInputEnabled = true
        
        analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
    }
    
    func start() {
        input.start()
        analyzer.start()
        frequency = Double(analyzer.trackedFrequency.floatValue)
    }
    
    func stop() {
        input.stop()
        analyzer.stop()
    }
    
    func update() {
        amplitude = Double(analyzer.trackedAmplitude.floatValue)
        frequency = Double(analyzer.trackedFrequency.floatValue)
    }
}