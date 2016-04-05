//
//  AKModalResonanceFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKModalResonanceFilterDSPKernel_hpp
#define AKModalResonanceFilterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    qualityFactorAddress = 1
};

class AKModalResonanceFilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKModalResonanceFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_mode_create(&mode);
        sp_mode_init(sp, mode);
        mode->freq = 500.0;
        mode->q = 50.0;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_mode_destroy(&mode);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.set(clamp(value, (float)12.0, (float)20000.0));
                break;

            case qualityFactorAddress:
                qualityFactorRamper.set(clamp(value, (float)0.0, (float)100.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.goal();

            case qualityFactorAddress:
                return qualityFactorRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case qualityFactorAddress:
                qualityFactorRamper.startRamp(clamp(value, (float)0.0, (float)100.0), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double frequency = double(frequencyRamper.getStep());
            double qualityFactor = double(qualityFactorRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            mode->freq = (float)frequency;
            mode->q = (float)qualityFactor;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_mode_compute(sp, mode, in, out);
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_mode *mode;

public:
    bool started = true;
    AKParameterRamper frequencyRamper = 500.0;
    AKParameterRamper qualityFactorRamper = 50.0;
};

#endif /* AKModalResonanceFilterDSPKernel_hpp */
