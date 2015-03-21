//
//  GraphDescriptor.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 18/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import OpenGL
import GLKit

struct GraphDescriptor {
    let vao:   GLuint
    let xVbo:  GLuint
    let yVbo:  GLuint
    let n:     GLsizei
    let color: [GLfloat]//GLuint
    
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
    }
    
    func draw(){
//        glEnableVertexAttribArray(vao);
//        GraphixManager.checkOpenGLerror("draw.glEnableVertexAttribArray")
        glBindVertexArray(vao)
        GraphixManager.checkOpenGLerror("draw.glBindVertexArray")
        glUniform4fv(GraphixManager.sharedInstance.cUnif, 1, color)
        GraphixManager.checkOpenGLerror("draw.glUniform4fv")
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, n)
        GraphixManager.checkOpenGLerror("draw.glDrawArrays")
        glBindVertexArray(0)
        GraphixManager.checkOpenGLerror("draw.glBindVertexArray")
    }
}