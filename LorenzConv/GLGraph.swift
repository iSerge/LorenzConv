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
    
    override func prepareOpenGL() {
        openGLContext.makeCurrentContext()
            
        glClearColor(0, 0, 0, 0);
        glLineWidth(1.0);
        glEnable(GLenum(GL_LINE_SMOOTH));
        glHint(GLenum(GL_LINE_SMOOTH_HINT),  GLenum(GL_NICEST));
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    }
    
    override func drawRect(dirtyRect: NSRect) {
        openGLContext.makeCurrentContext()
        GraphixManager.sharedInstance.distrGraph?.draw()
        CGLFlushDrawable(openGLContext.CGLContextObj)
    }
}