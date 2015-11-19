//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
class MovingAverage {
    var samples: Array<Double>
    var sampleCount = 0
    var period = 5
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Double>()
    }
    
    var average: Double {
        let sum: Double = samples.reduce(0, combine: +)
        
        if period > samples.count {
            return sum / Double(samples.count)
        } else {
            return sum / Double(period)
        }
    }
    
    func addSample(value: Double) -> Double {
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
    var amplitude: Float = 1
    var noiseFloor: Float = 0.0005
    var bufferSize: Int = 100
    
    init() {
        AKSettings.shared().audioInputEnabled = true
        frequency = MovingAverage(period: bufferSize)
        analyzer = AKAudioAnalyzer(input: input.output)
        
        AKOrchestra.addInstrument(input)
        AKOrchestra.addInstrument(analyzer)
        
        for(var i = 0; i < bufferSize; i++) {
            amplitude += analyzer.trackedAmplitude.floatValue
        }
        
        amplitude /= Float(bufferSize)
        noiseFloor = amplitude
        amplitude = 0
    }
    
    func start() {
        input.start()
        analyzer.start()
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
    }
    
    func stop() {
        input.stop()
        analyzer.stop()
    }
    
    func update() {
        let root = Float(frequency.average)
        let deltaFrequency = abs(root - analyzer.trackedFrequency.floatValue)
        if deltaFrequency > (root / 2) {
            for i in 1...5 {
                frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
            }
        }
        else {
            frequency.addSample(Double(analyzer.trackedFrequency.floatValue))
        }
        
        amplitude = analyzer.trackedAmplitude.floatValue
    }
}