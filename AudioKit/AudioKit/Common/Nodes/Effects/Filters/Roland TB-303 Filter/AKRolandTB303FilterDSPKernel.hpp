//
//  AKRolandTB303FilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKRolandTB303FilterDSPKernel_hpp
#define AKRolandTB303FilterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    cutoffFrequencyAddress = 0,
    resonanceAddress = 1,
    distortionAddress = 2,
    resonanceAsymmetryAddress = 3
};

class AKRolandTB303FilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKRolandTB303FilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_tbvcf_create(&tbvcf);
        sp_tbvcf_init(sp, tbvcf);
        tbvcf->fco = 500;
        tbvcf->res = 0.5;
        tbvcf->dist = 2.0;
        tbvcf->asym = 0.5;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_tbvcf_destroy(&tbvcf);
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

            case distortionAddress:
                distortionRamper.set(clamp(value, (float)0.0, (float)4.0));
                break;

            case resonanceAsymmetryAddress:
                resonanceAsymmetryRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.goal();

            case resonanceAddress:
                return resonanceRamper.goal();

            case distortionAddress:
                return distortionRamper.goal();

            case resonanceAsymmetryAddress:
                return resonanceAsymmetryRamper.goal();

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

            case distortionAddress:
                distortionRamper.startRamp(clamp(value, (float)0.0, (float)4.0), duration);
                break;

            case resonanceAsymmetryAddress:
                resonanceAsymmetryRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
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
            double distortion = double(distortionRamper.getStep());
            double resonanceAsymmetry = double(resonanceAsymmetryRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            tbvcf->fco = (float)cutoffFrequency;
            tbvcf->res = (float)resonance;
            tbvcf->dist = (float)distortion;
            tbvcf->asym = (float)resonanceAsymmetry;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_tbvcf_compute(sp, tbvcf, in, out);
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
    sp_tbvcf *tbvcf;

public:
    bool started = true;
    AKParameterRamper cutoffFrequencyRamper = 500;
    AKParameterRamper resonanceRamper = 0.5;
    AKParameterRamper distortionRamper = 2.0;
    AKParameterRamper resonanceAsymmetryRamper = 0.5;
};

#endif /* AKRolandTB303FilterDSPKernel_hpp */
