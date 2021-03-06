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
                // Input arguments for the filter
                let args = [inputImage as AnyObject]
                // Domain of definition
                let dod = inputImage.extent().rectByInsetting(dx: -1, dy: -1)
                return kernel.applyWithExtent(dod, roiCallback: {
                    (index, rect) in
                    return rect.rectByInsetting(dx: -1, dy: -1)
                    }, arguments: args)
        }
        return nil
    }
    
    // MARK: Create Kernel (Increases brightness by 20%)
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 brightenEffect (sampler src) {\n" +
            "   vec4 currentSource = sample(src, samplerCoord(src)); \n" +
            "   currentSource.rgb = currentSource.rgb + 0.2 * currentSource.a; \n" +
            "   return currentSource; \n" +
        "}"
        return CIColorKernel(string: kernelString)
    }
}
