//
//  PaletteEditorViewController.swift
//  Sing N Sketch
//
//  Created by Grant Elliott on 2/5/16.
//  Copyright © 2016 BGSU. All rights reserved.
//

import Foundation
import UIKit

class PaletteEditorViewController: UIViewController {
    var paletteEditor: PaletteEditorView!
    var palette: Palette?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init?(coder: NSCoder, palette: Palette, audio: AudioInterface) {
        self.init(coder: coder)
        self.paletteEditor = PaletteEditorView(frame: CGRect(x: 0, y: 0, width: 250, height: 250), palette: palette, audio: audio)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first
        {
            let point = touch.locationInView(self.view.viewWithTag(200)?.viewWithTag(3000))
            if 0.0 <= point.x && point.x <= 250{
                if 39.0 <= point.y && point.y <= 200{
                    let color = paletteEditor.getPixelColorAtPoint(point) // colorAtPosition(point)
                    paletteEditor.updateColorPicker(color, view: paletteEditor.gradientView!, isGradient: false)
                }
                else if 200 <= point.y && point.y <= 219 + 30{
                    let color = paletteEditor.getPixelColorAtPoint(point) // colorAtPosition(point)
                    paletteEditor.updateColorPicker(color,view: paletteEditor.gradientView!, isGradient: true)
                }
            }
        }
        else {
            debugPrint("Couldn't find touch in touchesBegan")
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent? ) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first
        {
            let t = touch
            let point = t.locationInView(self.view.viewWithTag(200)?.viewWithTag(3000))
            if 0.0 <= point.x && point.x <= 250{
                if 39.0 <= point.y && point.y <= 200{
                    let color = paletteEditor.getPixelColorAtPoint(point) //colorAtPosition(point)
                    paletteEditor.updateColorPicker(color,view: paletteEditor.gradientView!, isGradient: false)
                }
                else if 200 <= point.y && point.y <= 219 + 30{
                    let color = paletteEditor.getPixelColorAtPoint(point) //colorAtPosition(point)
                    paletteEditor.updateColorPicker(color, view: paletteEditor.gradientView!, isGradient: true)
                }
            }
        }
        else {
            debugPrint("Couldn't find touch in touchesMoved")
        }
    }
    
}