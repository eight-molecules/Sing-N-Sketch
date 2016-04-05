//
//  AKCostelloReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCostelloReverbDSPKernel_hpp
#define AKCostelloReverbDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    feedbackAddress = 0,
    cutoffFrequencyAddress = 1
};

class AKCostelloReverbDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKCostelloReverbDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
        revsc->feedback = 0.6;
        revsc->lpfreq = 4000;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_revsc_destroy(&revsc);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.set(clamp(value, (float)12.0, (float)20000.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case feedbackAddress:
                return feedbackRamper.goal();

            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
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

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            double feedback = double(feedbackRamper.getStep());
            double cutoffFrequency = double(cutoffFrequencyRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            revsc->feedback = (float)feedback;
            revsc->lpfreq = (float)cutoffFrequency;
            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            sp_revsc_compute(sp, revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);

        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_revsc *revsc;

public:
    bool started = true;
    AKParameterRamper feedbackRamper = 0.6;
    AKParameterRamper cutoffFrequencyRamper = 4000;
};

#endif /* AKCostelloReverbDSPKernel_hpp */
