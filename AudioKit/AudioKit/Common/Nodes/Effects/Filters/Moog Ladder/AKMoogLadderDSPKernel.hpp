//
//  AKMoogLadderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMoogLadderDSPKernel_hpp
#define AKMoogLadderDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    cutoffFrequencyAddress = 0,
    resonanceAddress = 1
};

class AKMoogLadderDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKMoogLadderDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_moogladder_create(&moogladder);
        sp_moogladder_init(sp, moogladder);
        moogladder->freq = 1000;
        moogladder->res = 0.5;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_moogladder_destroy(&moogladder);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.set(clamp(value, (float)12.0, (float)20000.0));
                break;

            case resonanceAddress:
                resonanceRamper.set(clamp(value, (float)0.0, (float)2.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.goal();

            case resonanceAddress:
                return resonanceRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
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
            double cutoffFrequency = double(cutoffFrequencyRamper.getStep());
            double resonance = double(resonanceRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            moogladder->freq = (float)cutoffFrequency;
            moogladder->res = (float)resonance;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_moogladder_compute(sp, moogladder, in, out);
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
    sp_moogladder *moogladder;

public:
    bool started = true;
    AKParameterRamper cutoffFrequencyRamper = 1000;
    AKParameterRamper resonanceRamper = 0.5;
};

#endif /* AKMoogLadderDSPKernel_hpp */
