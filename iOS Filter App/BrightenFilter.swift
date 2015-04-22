//
//  BrightenFilter.swift
//  iOS Filter App
//
//  Created by Brian Huynh on 4/22/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

private func createKernel() -> CIKernel {
    let kernelString = "kernel vec4 brightenEffect (sampler src, float k) {\n" +
                          "vec4 currentSource = sample(src, sampleCoord(src)); \n" +
                          "currentSource.rgb = currentSource.rgb + k * currentSource.a; \n" +
                          "return currentSource; \n"
    return CIKernel(string: kernelString)
}
