//
//  GraphDescriptor.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 18/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import OpenCL
import OpenGL
import GLKit

struct GraphDescriptor {
    let vao:    GLuint
    let xVbo:   GLuint
    let xBuf:   UnsafeMutablePointer<Void>
    let yVbo:   GLuint
    let yBuf:   UnsafeMutablePointer<Void>
    let n:      GLsizei
    var ndrange: cl_ndrange
    var color: [GLfloat]//GLuint
    
    init(xVbo: GLuint, yVbo: GLuint, n: GLsizei, color: [GLfloat]){ //GLuint){
        self.xVbo = xVbo
        self.yVbo = yVbo
        self.n = n
        self.color = color
        
        var VAO: GLuint = 0
        glGenVertexArrays(1, &VAO)
        
        vao = VAO
        glBindVertexArray(vao);
        
        let xAttr = (GLuint) (GraphixManager.sharedInstance.xAttr.value)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), xVbo);
        glEnableVertexAttribArray(xAttr);
        glVertexAttribPointer(xAttr, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil);

        let yAttr = (GLuint) (GraphixManager.sharedInstance.yAttr.value)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), yVbo);
        glEnableVertexAttribArray(yAttr);
        glVertexAttribPointer(yAttr, 1, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil);
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArray(0);
        
        xBuf = gcl_gl_create_ptr_from_buffer(xVbo)
        if(nil == xBuf){
            NSLog("Failed to create opencl distr X buffer")
        }
        
        yBuf = gcl_gl_create_ptr_from_buffer(yVbo)
        if(nil == yBuf){
            NSLog("Failed to create opencl distr Y buffer")
        }
        
        ndrange = cl_ndrange(work_dim: 1, global_work_offset: (0,0,0),
            global_work_size: (UInt(n),1,1), local_work_size: (UInt(n),1,1))

    }
    
    func draw(){
        glBindVertexArray(vao)
        GraphixManager.checkOpenGLerror("draw.glBindVertexArray")
        
        glUniform4fv(GraphixManager.sharedInstance.cUnif, 1, color)
        GraphixManager.checkOpenGLerror("draw.glUniform4fv")
        
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, n)
        GraphixManager.checkOpenGLerror("draw.glDrawArrays")
        
        glBindVertexArray(0)
        GraphixManager.checkOpenGLerror("draw.glBindVertexArray")
    }
    
    func dispose(){
        gcl_free(xBuf)
        gcl_free(yBuf)
        
        glDeleteVertexArrays(1, [vao])
        glDeleteBuffers(2, [xVbo,yVbo])
    }
}
