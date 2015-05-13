//
//  GreenRedFilter.swift
//  iOS Filter App
//
//  Created by Brian Huynh on 4/27/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class GreenRedFilter: CIFilter {
    
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
                let args = [inputImage as AnyObject]
                let dod = inputImage.extent().rectByInsetting(dx: -1, dy: -1)
                return kernel.applyWithExtent(dod, roiCallback: {
                    (index, rect) in
                    return rect.rectByInsetting(dx: -1, dy: -1)
                    }, arguments: args)
        }
        return nil
    }
    
    // MARK: Color Kernel (Swaps red color values with green)
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 greenRed (sampler src) {\n" +
            "   float swap = 0.0; \n" +
            "   vec4 currentSource = sample(src, samplerCoord(src)); \n" +
            "   swap = currentSource.r; \n" +
            "   currentSource.r = currentSource.g; \n" +
            "   currentSource.g = swap; \n" +
            "   return currentSource; \n" +
        "}"
        return CIColorKernel(string: kernelString)
    }
}
