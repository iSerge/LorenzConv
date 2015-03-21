//
//  DistributionGraph.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 21/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit
import OpenGL
import GLKit

class DistributionGraph: NSOpenGLView {
    var initialized = false
    
    override func awakeFromNib() {
        pixelFormat = GraphixManager.sharedInstance.pixelFormat
        openGLContext = GraphixManager.sharedInstance.glContext
    }
    
    override func prepareOpenGL() {
        openGLContext.makeCurrentContext()
        openGLContext.view = self
        
        let viewPortZise = convertRectToBacking(frame)
        glViewport(0, 0, GLsizei(viewPortZise.width) , GLsizei(viewPortZise.height))
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        openGLContext.flushBuffer()
    }

    override func drawRect(dirtyRect: NSRect) {
        openGLContext.makeCurrentContext()
        openGLContext.view = self
        
        let viewPortZise = convertRectToBacking(frame)
        glViewport(0, 0, GLsizei(viewPortZise.width) , GLsizei(viewPortZise.height))
        
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        
        GraphixManager.sharedInstance.distrGraph.draw()
        
        openGLContext.flushBuffer()
    }
}