//
//  AKStringResonatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKStringResonatorDSPKernel_hpp
#define AKStringResonatorDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    fundamentalFrequencyAddress = 0,
    feedbackAddress = 1
};

class AKStringResonatorDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKStringResonatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_streson_create(&streson);
        sp_streson_init(sp, streson);
        streson->freq = 100;
        streson->fdbgain = 0.95;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_streson_destroy(&streson);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case fundamentalFrequencyAddress:
                fundamentalFrequencyRamper.set(clamp(value, (float)12.0, (float)10000.0));
                break;

            case feedbackAddress:
                feedbackRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case fundamentalFrequencyAddress:
                return fundamentalFrequencyRamper.goal();

            case feedbackAddress:
                return feedbackRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case fundamentalFrequencyAddress:
                fundamentalFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)10000.0), duration);
                break;

            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
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
            double fundamentalFrequency = double(fundamentalFrequencyRamper.getStep());
            double feedback = double(feedbackRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            streson->freq = (float)fundamentalFrequency;
            streson->fdbgain = (float)feedback;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_streson_compute(sp, streson, in, out);
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
    sp_streson *streson;

public:
    bool started = true;
    AKParameterRamper fundamentalFrequencyRamper = 100;
    AKParameterRamper feedbackRamper = 0.95;
};

#endif /* AKStringResonatorDSPKernel_hpp */
