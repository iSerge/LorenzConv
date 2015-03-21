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
    let Gold: [GLfloat] = [1.0, 0.85, 0.35, 1.0]
    let vertexes: [GLfloat] = [
        0.0,  0.6, 0.0,
        -0.2, -0.3, 0.0,
        0.2, -0.3 ,0.0
    ]
    
    var initialized = false
    
    var pr: GLuint = 0
    var vAttr: GLint = GLint()
    var cUnif: GLint = GLint()
    
    var VBO: GLuint = 0;
    var VAO: GLuint = 0
    
    let vsSource =
    "#version 150 core\n" +
        "in vec3 vertex;\n" +
        "void main() {\n" +
        "  gl_Position = vec4(vertex, 1.0);\n" +
    "}\n"
    
    let fsSource =
    "#version 150 core\n" +
        "uniform vec4 solidColor;\n" +
        "out vec4 color;\n" +
        "void main() {\n" +
        "  color = solidColor;\n" +
    "}\n"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func awakeFromNib() {
        let graphix = GraphixManager.sharedInstance
        
        pixelFormat = graphix.pixelFormat
        if let ctx = graphix.glContext {
            NSLog("GLGraph shared context %@", ctx)
        } else {
            NSLog("GLGraph empty shared context")
        }
        openGLContext = NSOpenGLContext(format: graphix.pixelFormat, shareContext: nil)
        
        if let context = openGLContext {
            CGLEnable(context.CGLContextObj, kCGLCECrashOnRemovedFunctions)
        }
    }
    
    override func prepareOpenGL() {
        openGLContext.makeCurrentContext()

        var swapInt: GLint = 1;
        
        openGLContext.setValues(&swapInt, forParameter: NSOpenGLContextParameter.GLCPSwapInterval)
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glLineWidth(1.0);
        glEnable(GLenum(GL_LINE_SMOOTH));
        glHint(GLenum(GL_LINE_SMOOTH_HINT),  GLenum(GL_NICEST));
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    }
    
    func prepareData() {
        var vShader: GLuint = 0
        var fShader: GLuint = 0
        
        //        openGLContext.makeCurrentContext()
        
        vShader = glCreateShader(GLenum(GL_VERTEX_SHADER));
        fShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER));
        
        var cstringv = (vsSource as NSString).UTF8String
        var cstringvLen: GLint = GLint( (vsSource as NSString).length)
        glShaderSource(vShader, 1, &cstringv, &cstringvLen)
        
        var cstringf = (fsSource as NSString).UTF8String
        var cstringfLen: GLint = GLint( (fsSource as NSString).length)
        glShaderSource(fShader, 1, &cstringf, &cstringfLen);
        
        glCompileShader(vShader);
        GraphixManager.ShaderStatus(vShader, param: GLenum(GL_COMPILE_STATUS))
        glCompileShader(fShader);
        GraphixManager.ShaderStatus(fShader, param: GLenum(GL_COMPILE_STATUS))
        
        pr = glCreateProgram();
        glAttachShader(pr, vShader);
        glAttachShader(pr, fShader);
        
        glLinkProgram(pr);
        GraphixManager.ProgramStatus(pr, param: GLenum(GL_LINK_STATUS))
        
        vAttr = glGetAttribLocation(pr, "vertex")
        
        cUnif = glGetUniformLocation(pr, "solidColor");
        
        glGenBuffers(1, &VBO);
        GraphixManager.checkOpenGLerror("awakeFromNib.glGenBuffers")
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO);
        GraphixManager.checkOpenGLerror("awakeFromNib.glBindBuffer")
        
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertexes.count*sizeof(Float), vertexes, GLenum(GL_STATIC_DRAW));
        GraphixManager.checkOpenGLerror("awakeFromNib.glBufferData")
        
        glGenVertexArrays(1, &VAO)
        GraphixManager.checkOpenGLerror("awakeFromNib.glGenVertexArrays")
        
        glBindVertexArray(VAO);
        GraphixManager.checkOpenGLerror("awakeFromNib.glBindVertexArray")
        
        let va = (GLuint)(vAttr.value)
        glEnableVertexAttribArray(va);
        GraphixManager.checkOpenGLerror("awakeFromNib.glEnableVertexAttribArray")
        
        glVertexAttribPointer(va, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil);
        GraphixManager.checkOpenGLerror("awakeFromNib.glVertexAttribPointer")
        
        glUseProgram(pr);
        glValidateProgram(pr)
        GraphixManager.ProgramStatus(pr, param: GLenum(GL_VALIDATE_STATUS))
        
        glUseProgram(0)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        glBindVertexArray(0);
        
        initialized = true
    }
    
    override func drawRect(dirtyRect: NSRect) {
        
        openGLContext.makeCurrentContext()
        
        if (!initialized){
            prepareData()
        }
        
        glClear(GLenum(GL_COLOR_BUFFER_BIT) | GLenum(GL_DEPTH_BUFFER_BIT))
        GraphixManager.checkOpenGLerror("drawRect.glClear")

        drawAnObject()
        
//        GraphixManager.sharedInstance.distrGraph?.draw()

        openGLContext.flushBuffer()
        GraphixManager.checkOpenGLerror("drawRect.flushBuffer")
    }

    func drawAnObject() {
        glUseProgram(pr)
        GraphixManager.checkOpenGLerror("drawAnObject.glUseProgram")
        
        glBindVertexArray(VAO)
        GraphixManager.checkOpenGLerror("drawAnObject.glBindVertexArray")
        
        glUniform4fv(cUnif, 1, Gold)
        GraphixManager.checkOpenGLerror("drawAnObject.glUniform4fv")
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        GraphixManager.checkOpenGLerror("drawAnObject.glDrawArrays")
        
        glBindVertexArray(0)
        GraphixManager.checkOpenGLerror("drawAnObject.glBindVertexArray(0)")
        
        glUseProgram(0)
        GraphixManager.checkOpenGLerror("drawAnObject.glUseProgram(0)")
    }

}