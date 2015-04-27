//
//  Invert.swift
//  iOS Filter App
//
//  Created by David Cackette on 4/27/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class Invert: CIFilter {
    
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
                let args = [inputImage as AnyObject]
                let dod = inputImage.extent().rectByInsetting(dx: -1, dy: -1)
                return kernel.applyWithExtent(dod, roiCallback: {
                    (index, rect) in
                    return rect.rectByInsetting(dx: -1, dy: -1)
                    }, arguments: args)
        }
        return nil
    }
    
    // MARK: Create Kernel
    private func createKernel() -> CIColorKernel {
        let kernelString =
        "kernel vec4 _invertColor(sampler source_image) {\n" +
            "vec4 pixValue;\n" +
            "pixValue = sample(source_image, samplerCoord(source_image));\n" +
            "pixValue.rgb = pixValue.aaa - pixValue.rgb;\n" +
            "return pixValue;\n" +
        "}"
        return CIColorKernel(string: kernelString)
    }
}


