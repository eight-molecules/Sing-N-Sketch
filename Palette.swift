//
//  Palette.swift
//  Sing N Sketch
//
//  Created by Grant D Elliott on 10/7/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation

extension UIColor {
    var components:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r,g,b,a)
    }
}

class Palette {
    class Channel {
        // Dictionary storage of the frequency mappings
        // and their associated
        var values = [Float: CGFloat]()
        
        // Init the channel and add a Zero Hertz
        // mapping and a 20,000 Hertz mapping
        //
        // This handles a wider than average
        // human hearing range
        required init() {
            addMapping(0, value: CGFloat(0))
            addMapping(20000, value: CGFloat(0))
        }
        
        // Map a frequency to a color
        func addMapping(frequency: Float, value: CGFloat) {
            values[frequency] = value
        }
        
        // Remap a frequency to a new color
        func modifyMapping(frequency: Float, value: CGFloat) {
            values.updateValue(value, forKey: frequency)
        }
        
        func deleteMapping(frequency: Float) {
            values.removeValueForKey(frequency)
        }
        
        // Return a value unique to the given frequency
        func getValue(frequency: Float) -> CGFloat {
            var val: CGFloat = 0
            var lastFrequency: Float = 0
            var lastValue: CGFloat = 0
            
            // Return zero if the
            // dictionary is somehow empty
            // or only has a single value
            if values.count > 1 {
                
                // Find the matching target value, or interpolate the value from
                // the surrounding frequencies.
                let sortedKeys = Array(values.keys).sort(<)
                for f in sortedKeys {
                    if f < frequency {
                        
                        // Store the last frequency and
                        // the last color value checked
                        // then continue
                        lastFrequency = f
                        lastValue = values[f]!
                        continue
                    }
                        // Generate the next frequency
                        // then break to return
                    else {
                        
                        // Interpolate the value of the channel
                        let ratio: CGFloat = CGFloat((frequency - lastFrequency) / (f - lastFrequency))
                        val = lastValue + ((values[f]! - lastValue) * ratio)
                        break
                    }
                }
            }
            
            return val
        }
        
        
        // Return the frequencies mapped to the channel
        func getFrequencies() -> [Float] {
            let frequencies = Array(values.keys)
            return frequencies
        }
        
        // Return the channel values mapped to the channel
        func getValues() -> [CGFloat] {
            let channelValues = Array(values.values)
            return channelValues
        }
        
    }
    
    var red: Channel = Channel()
    var green: Channel  = Channel()
    var blue: Channel  = Channel()
    
    required init() {
    }
    
    // Return a mapped UIColor
    func getColor(frequency: Float) -> UIColor {
        
        let r = red.getValue(frequency)
        let g = green.getValue(frequency)
        let b = blue.getValue(frequency)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
        return color
    }
    
    // Private function to handle individual color channels
    private func addColor(frequency: Float, r: CGFloat, g: CGFloat, b: CGFloat) {
        var mappedFrequencies = red.getFrequencies()
        mappedFrequencies.sortInPlace(<)
        var newFreq: Bool = true
        // If the frequency is +/- 2% of a frequency
        // already added, modify that frequency instead.
        // Magic number 50 is the divisor for 2% of a number.
        //
        // TODO: This comparison could use some more logic
        //  to scale exponentially like octaves do.
        //
        // Seriously, 2% of 1000hz is a very wide range to call for a remap
        if mappedFrequencies.count > 1 {
            for f in mappedFrequencies {
                let diff = fabs(f - frequency)
                if diff < (f / 50) {
                    newFreq = false
                    
                    red.modifyMapping(f, value: r)
                    green.modifyMapping(f, value: g)
                    blue.modifyMapping(f, value: b)
                    break
                }
            }
        }
        
        // If the frequency wasn't found, add it as a new one.
        if newFreq != false {
            red.addMapping(frequency, value: r)
            green.addMapping(frequency, value: g)
            blue.addMapping(frequency, value: b)
        }
    }
    
    // Function to add color from a UIColor
    func addColor(frequency: Float, color: UIColor) {

        let colorComponents = color.components
        let r = colorComponents.red
        let g = colorComponents.green
        let b = colorComponents.blue

        addColor(frequency, r: r, g: g, b: b)
    }
    
    func getMappings() -> Dictionary<Float, UIColor> {
        
        // We only need one set of the frequencies
        // since the keys are the same per channel
        let frequencies = red.getFrequencies()
        
        var mappings = Dictionary<Float, UIColor>()
        
        // Generate all the mapped colors and add them to our Dictionary
        for f in frequencies {
            mappings[f] = UIColor(red: red.getValue(f), green: green.getValue(f), blue: blue.getValue(f), alpha: 1)
        }
        
        return mappings
    }
    
    func deleteColor(frequency: Float) {
        var mappedFrequencies = red.getFrequencies()
        mappedFrequencies.sortInPlace(<)
        
        // If the frequency is +/- 2% of a frequency
        // already added, modify that frequency instead.
        // Magic number 50 is the divisor for 2% of a number.
        //
        // TODO: This comparison could use some more logic
        //  to scale exponentially like octaves do.
        //
        // Seriously, 2% of 1000hz is a very wide range to call for a remap
        if mappedFrequencies.count > 0 {
            for f in mappedFrequencies {
                let diff = fabs(f - frequency)
                if diff < (f / 50) {
                    red.deleteMapping(f)
                    green.deleteMapping(f)
                    blue.deleteMapping(f)
                    
                    break
                }
            }
        }
    }
}