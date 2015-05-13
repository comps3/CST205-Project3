//
//  SobelFilter.swift
//  iOS Filter App
//
//  Created by Brian Huynh on 4/15/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class SobelFilter: CIFilter {
    // MARK: - Properties
    var kernel: CIKernel?
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
    
    // MARK: - API
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
    
    // MARK: - Utility methods (Detects the edges changes their colors and darkens rest of image)
    private func createKernel() -> CIKernel {
        let kernelString =
        "kernel vec4 sobel (sampler image) {\n" +
            "  mat3 sobel_x = mat3( -1, -2, -1, 0, 0, 0, 1, 2, 1 );\n" +
            "  mat3 sobel_y = mat3( 1, 0, -1, 2, 0, -2, 1, 0, -1 );\n" +
            "  float s_x = 0.0;\n" +
            "  float s_y = 0.0;\n" +
            "  vec2 dc = destCoord();\n" +
            "  for (int i=-1; i <= 1; i++) {\n" +
            "    for (int j=-1; j <= 1; j++) {\n" +
            "      vec4 currentSample = sample(image, samplerTransform(image, dc + vec2(i,j)));" +
            "      s_x += sobel_x[j+1][i+1] * currentSample.g;\n" +
            "      s_y += sobel_y[j+1][i+1] * currentSample.g;\n" +
            "    }\n" +
            "  }\n" +
            "  return vec4(s_x, s_y, 0.0, 1.0);\n" +
        "}"
        return CIKernel(string: kernelString)
    }
    
}

