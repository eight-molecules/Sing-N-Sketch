//
//  AudioInterface.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 9/23/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
import AudioKit

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
        let pos = sampleCount % period
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        
        sampleCount += 1
        
        return average
    }
}
class AudioInterface {
    let mic = AKMicrophone()
    var trackedFrequency: AKFrequencyTracker!
    var frequency: MovingAverage!
    var amplitude: MovingAverage!
    var noiseFloor: Double = 0.0005
    var freqBuffer: Int = 25
    let ampBuffer: Int = 3
    var minFreq: Double = 100
    var maxFreq: Double = 400
    
    required init() {
        trackedFrequency = AKFrequencyTracker(mic, minimumFrequency: minFreq, maximumFrequency: maxFreq)
        AKSettings.audioInputEnabled = true
        let silence = AKMixer(trackedFrequency)
        silence.volume = 0
        AudioKit.output = silence
        AudioKit.start()
        mic.start()
        trackedFrequency.start()
        
        frequency = MovingAverage(period: freqBuffer)
        amplitude = MovingAverage(period: ampBuffer)
        
        for i in 1...freqBuffer {
            frequency.addSample(trackedFrequency.frequency)
            if (i <= ampBuffer) {
                amplitude.addSample(trackedFrequency.amplitude)
            }
        }
        
        noiseFloor = amplitude.average
    }
    
    func update() {
        frequency.addSample(trackedFrequency.frequency)
        amplitude.addSample(trackedFrequency.amplitude)
    }
    
    func clearFrequency() -> Double {
        var i = 0
        repeat {
            frequency.addSample(trackedFrequency.frequency)
            i += 1
        }
        while i < freqBuffer
        return frequency.average
    }
}