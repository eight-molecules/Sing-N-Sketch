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
    
    init() {
        AKSettings.shared().audioInputEnabled = true
        
        analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
    }
    
    func start() {
        input.start()
        analyzer.start()
    }
    
    func stop() {
        input.stop()
        analyzer.stop()
    }
    
    func update() {
        frequency = analyzer.trackedFrequency.floatValue
        println(analyzer.trackedFrequency.floatValue)
    }
}