//
//  Palette.swift
//  Sing N Sketch
//
//  Created by Grant D Elliott on 10/7/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

class Palette {
    class Channel {
        var values = [Float: CGFloat]()
        
        func addMapping(frequency: Float, color: CGFloat) {
            
        }
        
        func generateValue(freq: Float) -> CGFloat {
            var val: CGFloat! = 0
            
            var lastFrequency: Float = 0
            var lastValue: CGFloat = 0
            for (frequency, value) in values {
                if freq > frequency {
                    lastFrequency = frequency
                    lastValue = value
                    continue;
                }
                if freq < frequency {
                    var ratio: CGFloat = CGFloat((freq - lastFrequency) / (frequency - lastFrequency))
                
                    val = lastValue + ((value - lastValue) * ratio)
                }
            }
            
            return val
        }
    }
    
    required init() {

        
    }
    
    
}