//
//  GraphixManager.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 18/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Foundation
import OpenGL
import GLKit

private let _GraphixManagerSharedInstance = GraphixManager()

class GraphixManager {
    class var sharedInstance: GraphixManager { return _GraphixManagerSharedInstance }

    let Black: [GLfloat] = [0.0, 0.0, 0.0, 1.0]
    let Red: [GLfloat] =   [1.0, 0.0, 0.0, 1.0]
    let Green: [GLfloat] = [0.0, 1.0, 0.0, 1.0]
    let Blue:[ GLfloat] =  [0.0, 0.0, 1.0, 1.0]
    
    let distributionPM: [GLfloat] = [ 0.2, 0.0, 0.0,  0.0,
                                      0.0, 2.0, 0.0, -1.0,
                                      0.0, 0.0, 1.0,  0.0,
                                      0.0, 0.0, 0.0,  1.0
                                    ];

    
    let pixelFormat: NSOpenGLPixelFormat?
    let glContext: NSOpenGLContext?

//    let program: GLuint
//    let xAttr: GLuint
//    let yAttr: GLuint
//    let pmUnif: GLuint
//    let cUnif: GLuint
    
    private init(){
        let attrs: [NSOpenGLPixelFormatAttribute] = [ UInt32(NSOpenGLPFADoubleBuffer), UInt32(NSOpenGLPFADepthSize), 16,
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core), UInt32(NSOpenGLPFAColorSize), 32, 0 ]

        pixelFormat = NSOpenGLPixelFormat(attributes: attrs)

        if (nil == pixelFormat){
            NSLog("No OpenGL pixel format");
        }

        glContext = NSOpenGLContext(format:pixelFormat, shareContext:nil)

        if let context = glContext {
            CGLEnable(context.CGLContextObj, kCGLCECrashOnRemovedFunctions)
        }

        
        
        var pr: GLuint = 0
        
    }
}