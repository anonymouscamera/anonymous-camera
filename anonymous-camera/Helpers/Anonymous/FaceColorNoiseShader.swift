//
//  FaceColorNoiseShader.swift
//  anonymous-camera
//
//  Created by Alisdair Mills on 03/06/2020.
//  Copyright © 2020 Aaron Abentheuer. All rights reserved.
//

import Foundation
import Metal
import MetalPerformanceShaders
import MetalKit

class FaceColorNoiseShader: FaceShader {
    
    override func generate(device: MTLDevice) {
        generateFrom(device: device, vertex: "oneInputVertex", fragment: "colorNoiseFragment")
    }
    
    override func needsSourceAspect() -> Bool {
        return true
    }
    
}
