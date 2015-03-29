//
//  GLGraph.swift
//  LorenzConv
//
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Cocoa
import OpenGL
import GLKit

class GLGraph: NSOpenGLView {
    var graphs: [Spectre]? {
        didSet {
            self.needsDisplay = true
        }
    }
    
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
        if nil == graphs {
            return
        }
        
        openGLContext.makeCurrentContext()
        openGLContext.view = self
        
        let viewPortZise = convertRectToBacking(frame)
        glViewport(0, 0, GLsizei(viewPortZise.width) , GLsizei(viewPortZise.height))

        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        
        let limits = graphs?.map({s in (s.xLimits, s.yLimits)}).reduce(
            ((Float.infinity, -Float.infinity), (Float.infinity, -Float.infinity)),
            {a,b in (
                (min(a.0.0,b.0.0), max(a.0.1,b.0.1)),
                (min(a.1.0,b.1.0), max(a.1.1,b.1.1))
                )
            })
        
        glUseProgram(GraphixManager.sharedInstance.program)
        GraphixManager.checkOpenGLerror("DistributionGraph.drawRect.glUseProgram")
        
        let projMatrix = GraphixManager.orthoMatrix(limits!.0, yLims: limits!.1)
        
        glUniformMatrix4fv(GraphixManager.sharedInstance.pmUnif, 1, GLboolean(GL_TRUE), projMatrix)
        GraphixManager.checkOpenGLerror("DistributionGraph.drawRect.glUniformMatrix4fv")
        
        
        for spectre: Spectre in graphs! {
            spectre.graph?.draw()
        }
        
        glUseProgram(0)
        
        openGLContext.flushBuffer()
    }
}