//
//  AKOscillatorTester.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKOscillatorTester : AKInstrument {
    
    override init() {
        super.init()
        
        let frequency = 1000 * AKPhasor(frequency: 10.ak, phase: 0)
        
        let amplitude = 0.8 - 0.5 * AKPhasor(frequency: 7.ak, phase: 0.5)
        
        let oscillator = AKOscillator(waveform: AKTable.standardSineWave(), frequency: frequency, amplitude: amplitude, phase: 0)

        output = AKAudioOutput(oscillator)
    }
}
