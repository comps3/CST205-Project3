//
//  Blur.swift
//  iOS Filter App
//
//  Created by David Cackette on 4/22/15.
//  Copyright (c) 2015 Brian Huynh. All rights reserved.
//

import CoreImage

class Blur: CIFilter {
    
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
    private func createKernel() -> CIKernel {
        let kernelString = "kernel vec4 blur (sampler src) {\n" +
            "attribute vec4 a_position;\n" +
            "attribute vec2 a_texCoord;\n" +
            "uniform mat4 u_contentTransform;\n" +
            "uniform mat2 u_texCoordTransform;\n" +
            "uniform mat2 u_rawTexCoordTransform;\n" +
            "uniform float u_radius;\n" +
            "varying vec2 v_texCoord;\n" +
            "varying vec2 v_blurTexCoords[14];\n" +
            "varying vec2 v_rawTexCoord;\n" +
            "gl_Position = u_contentTransform * a_position\n" +
            "v_texCoord = u_texCoordTransform * a_texCoord;\n" +
            "for (int i = 0; i < 7; ++i) {\n" +
                "vec2 c = vec2(u_radius/7.0*(7.0 - float(i)), 0.0);\n" +
                "v_blurTexCoords[i] = v_texCoord - c;\n" +
                "v_blurTexCoords[13-i] = v_texCoord + c;\n" +
            "}\n" +
            "v_rawTexCoord = u_rawTexCoordTransform * gl_Position.xy * 0.5 + vec2(0.5);\n" +
        "}"
        return CIKernel(string: kernelString)
    }
}

