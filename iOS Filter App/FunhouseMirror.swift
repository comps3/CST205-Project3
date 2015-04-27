//
//  FunhouseMirror.swift
//  iOS Filter App
//
//  Created by David Cackette on 4/27/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class FunMirror: CIFilter {
    
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
"float mySmoothstep(float x) {\n"
    "return (x * -2.0 + 3.0) * x * x;\n"
"}\n"
"kernel vec4 funHouse(sampler src, float center_x, float inverse_radius,\n"
    "float radius, float scale) {\n" +
    "float distance;\n" +
    "vec2 myTransform1, adjRadius;\n" +
    "myTransform1 = destCoord();\n" +
    "adjRadius.x = (myTransform1.x - center_x) * inverse_radius;\n" +
    "distance = clamp(abs(adjRadius.x), 0.0, 1.0);\n" +
    "distance = mySmoothstep(1.0 - distance) * (scale - 1.0) + 1.0;\n" +
    "myTransform1.x = adjRadius.x * distance * radius + center_x;\n" +
    "return sample(src, samplerTransform(src, myTransform1));\n" +
"}"
return CIColorKernel(string: kernelString)
}
}
