//
//  AKTanhDistortionDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTanhDistortionDSPKernel_hpp
#define AKTanhDistortionDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    pregainAddress = 0,
    postgainAddress = 1,
    postiveShapeParameterAddress = 2,
    negativeShapeParameterAddress = 3
};

class AKTanhDistortionDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKTanhDistortionDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_dist_create(&dist);
        sp_dist_init(sp, dist);
        dist->pregain = 2.0;
        dist->postgain = 0.5;
        dist->shape1 = 0.0;
        dist->shape2 = 0.0;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_dist_destroy(&dist);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case pregainAddress:
                pregainRamper.set(clamp(value, (float)0.0, (float)10.0));
                break;

            case postgainAddress:
                postgainRamper.set(clamp(value, (float)0.0, (float)10.0));
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.set(clamp(value, (float)-10.0, (float)10.0));
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.set(clamp(value, (float)-10.0, (float)10.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case pregainAddress:
                return pregainRamper.goal();

            case postgainAddress:
                return postgainRamper.goal();

            case postiveShapeParameterAddress:
                return postiveShapeParameterRamper.goal();

            case negativeShapeParameterAddress:
                return negativeShapeParameterRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case pregainAddress:
                pregainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case postgainAddress:
                postgainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.startRamp(clamp(value, (float)-10.0, (float)10.0), duration);
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.startRamp(clamp(value, (float)-10.0, (float)10.0), duration);
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
            double pregain = double(pregainRamper.getStep());
            double postgain = double(postgainRamper.getStep());
            double postiveShapeParameter = double(postiveShapeParameterRamper.getStep());
            double negativeShapeParameter = double(negativeShapeParameterRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            dist->pregain = (float)pregain;
            dist->postgain = (float)postgain;
            dist->shape1 = (float)postiveShapeParameter;
            dist->shape2 = (float)negativeShapeParameter;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_dist_compute(sp, dist, in, out);
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
    sp_dist *dist;

public:
    bool started = true;
    AKParameterRamper pregainRamper = 2.0;
    AKParameterRamper postgainRamper = 0.5;
    AKParameterRamper postiveShapeParameterRamper = 0.0;
    AKParameterRamper negativeShapeParameterRamper = 0.0;
};

#endif /* AKTanhDistortionDSPKernel_hpp */
