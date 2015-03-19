//
//  GLGraph.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 19/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit
import OpenGL

class GLGraph: NSOpenGLView {
    override func awakeFromNib() {
        let graphix = GraphixManager.sharedInstance
        
        pixelFormat = graphix.pixelFormat
        
        openGLContext = NSOpenGLContext(format: pixelFormat, shareContext: graphix.glContext)
        
        if let context = openGLContext {
            CGLEnable(context.CGLContextObj, kCGLCECrashOnRemovedFunctions)
        }
    }
}