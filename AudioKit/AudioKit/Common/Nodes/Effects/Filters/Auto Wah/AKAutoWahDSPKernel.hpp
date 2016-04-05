//
//  AKAutoWahDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAutoWahDSPKernel_hpp
#define AKAutoWahDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    wahAddress = 0,
    mixAddress = 1,
    amplitudeAddress = 2
};

class AKAutoWahDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKAutoWahDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_autowah_create(&autowah);
        sp_autowah_init(sp, autowah);
        *autowah->wah = 0;
        *autowah->mix = 100;
        *autowah->level = 0.1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_autowah_destroy(&autowah);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case wahAddress:
                wahRamper.set(clamp(value, (float)0, (float)1));
                break;

            case mixAddress:
                mixRamper.set(clamp(value, (float)0, (float)100));
                break;

            case amplitudeAddress:
                amplitudeRamper.set(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case wahAddress:
                return wahRamper.goal();

            case mixAddress:
                return mixRamper.goal();

            case amplitudeAddress:
                return amplitudeRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case wahAddress:
                wahRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

            case mixAddress:
                mixRamper.startRamp(clamp(value, (float)0, (float)100), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
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
            double wah = double(wahRamper.getStep());
            double mix = double(mixRamper.getStep());
            double amplitude = double(amplitudeRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            *autowah->wah = (float)wah;
            *autowah->mix = (float)mix;
            *autowah->level = (float)amplitude;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_autowah_compute(sp, autowah, in, out);
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
    sp_autowah *autowah;

public:
    bool started = true;
    AKParameterRamper wahRamper = 0;
    AKParameterRamper mixRamper = 100;
    AKParameterRamper amplitudeRamper = 0.1;
};

#endif /* AKAutoWahDSPKernel_hpp */
