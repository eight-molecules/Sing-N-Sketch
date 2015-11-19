//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
class MovingAverage {
    var samples: Array<Float>
    var sampleCount = 0
    var period = 5
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Float>()
    }
    
    var average: Float {
        let sum: Float = samples.reduce(0, combine: +)
        
        if period > samples.count {
            return sum / Float(samples.count)
        } else {
            return sum / Float(period)
        }
    }
    
    func addSample(value: Float) -> Float {
        var pos = Int(fmodf(Float(sampleCount++), Float(period)))
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        
        return average
    }
}
class AudioInterface {
    
    var input: AKMicrophone = AKMicrophone()
    var analyzer: AKAudioAnalyzer!
    var frequency: MovingAverage!
    var amplitude: MovingAverage!
    var noiseFloor: Float = 0.0005
    var freqBuffer: Int = 25
    let ampBuffer: Int = 3
    
    init() {
        AKSettings.shared().audioInputEnabled = true
        frequency = MovingAverage(period: freqBuffer)
        amplitude = MovingAverage(period: ampBuffer)
        analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
        
        for i in 1...freqBuffer {
            frequency.addSample(analyzer.trackedFrequency.floatValue)
            if (i <= ampBuffer) {
                amplitude.addSample(analyzer.trackedFrequency.floatValue)
            }
        }
        
        noiseFloor = amplitude.average
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
        frequency.addSample(analyzer.trackedFrequency.floatValue)
        amplitude.addSample(analyzer.trackedAmplitude.floatValue)
    }
}