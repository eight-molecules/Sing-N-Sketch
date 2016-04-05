//
//  AKOutputWaveformPlot
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Wrapper class for plotting audio from the final mix in a waveform plot
@IBDesignable
public class AKOutputWaveformPlot: EZAudioPlot {
    internal func setupNode() {
        AudioKit.engine.outputNode.installTapOnBus(0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData[0];
                strongSelf.updateBuffer(&tail[offset],
                    withBufferSize: strongSelf.bufferSize);
            }
        }
    }

    internal let bufferSize: UInt32 = 512
    
    deinit {
        AudioKit.engine.outputNode.removeTapOnBus(0)
    }

    /// Initialize the plot in a frame
    ///
    /// - parameter frame: CGRect in which to draw the plot
    ///
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupNode()
    }
    
    /// Required coder-based initialization (for use with Interface Builder)
    ///
    /// - parameter coder: NSCoder
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode()
    }
    
    /// Create a View with the plot (usually for playgrounds)
    ///
    /// - returns: AKView
    /// - parameter width: Width of the view
    /// - parameter height: Height of the view
    ///
    public static func createView(width: CGFloat = 1000.0, height: CGFloat = 500.0) -> AKView {

        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let plot = AKOutputWaveformPlot(frame: frame)
        
        plot.plotType = .Buffer
        plot.backgroundColor = AKColor.whiteColor()
        plot.shouldCenterYAxis = true
        
        let containerView = AKView(frame: frame)
        containerView.addSubview(plot)
        return containerView
    }
}
