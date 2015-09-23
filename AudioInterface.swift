//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class AudioInterface {
    var input: AKMicrophone!
    var analyzer: AKAudioAnalyzer!
    var frequency: Float! = 0
    
    init() {
        let input = AKMicrophone()
        let analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
        
        input.start()
        analyzer.start()
        
    }
    
    func start() {
        input.start()
        analyzer.start()
    }
    
    func stop() {
        analyzer.stop()
        input.stop()
    }
    
    func update() {
        println(analyzer.trackedFrequency.floatValue)
    }
}