//
//  BrightenFilter.swift
//  iOS Filter App
//
//  Created by Brian Huynh on 4/22/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class BrightenFilter: CIFilter {
    
    var kernel: CIColorKernel?
    var inputImage: CIImage?
    var threshold: CGFloat = 0.4
    
    // MARK: - Initialization
    override init() {
        super.init()
        kernel = createKernel()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        kernel = createKernel()
    }
    
    override var outputImage : CIImage! {
        if let inputImage = inputImage,
            let kernel = kernel {
                let dod = inputImage.extent()
                let args = [inputImage as AnyObject, threshold as AnyObject]
                
                return kernel.applyWithExtent(dod, arguments: args)
        }
        return nil
    }
    
    // MARK: Create Kernel
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 brightenEffect (sampler src, float threshold) {\n" +
        "   vec4 currentSource = sample(src, samplerCoord(src)); \n" +
        "   currentSource.rgb = currentSource.rgb + threshold * currentSource.a; \n" +
        "   return currentSource; \n" +
        "}"
        return CIColorKernel(string: kernelString)
    }
}

