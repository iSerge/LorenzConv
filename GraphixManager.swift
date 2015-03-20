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
    let Red:   [GLfloat] = [1.0, 0.0, 0.0, 1.0]
    let Green: [GLfloat] = [0.0, 1.0, 0.0, 1.0]
    let Blue:  [GLfloat] = [0.0, 0.0, 1.0, 1.0]
    
    let distributionPM: [GLfloat] = [ 0.2, 0.0, 0.0,  0.0,
                                      0.0, 2.0, 0.0, -1.0,
                                      0.0, 0.0, 1.0,  0.0,
                                      0.0, 0.0, 0.0,  1.0
                                    ];

    
    let pixelFormat: NSOpenGLPixelFormat?
    let glContext: NSOpenGLContext?

    var program: GLuint = GLuint()
    var xAttr: GLint = GLint()
    var yAttr: GLint = GLint()
    var pmUnif: GLint = GLint()
    var cUnif: GLint = GLint()
    
    var distrGraph: GraphDescriptor!

    let vsSource =
      "#version 320 core\n" +
      "uniform mat4 projectionMatrix;\n" +
      "in float coordx;\n" +
      "in float coordy;\n" +
      "void main() {\n" +
      "  gl_Position = projectionMatrix * vec4(coordx, coordy, 0.0, 1.0);\n" +
      "}\n"

    let fsSource =
      "#version 320 core\n" +
//      "uniform uint pattern;\n" +
//      "uniform float factor;\n" +
      "uniform vec4 solidColor;\n" +
      "out vec4 color;\n" +
      "void main() {\n" +
//      "  uint bit = uint(round(linePos/factor)) & 31U;\n" +
//      "  if((pattern & (1U<<bit)) == 0U)\n" +
//      "    discard;\n" +
      "  color = solidColor;\n" +
      "}\n"

    class func M_PI() -> Float {return 3.14159265359}
    let nPoints: Int = 151
    let G: Float = 0.3
    let x1: Float = -5
    let x2: Float =  5
    let dx: Float
    
    class func f(x: Float, g: Float) -> Float
    {
        return g/(GraphixManager.M_PI()*(x*x+g*g));
    }

    class func genBuffer(v: [Float], count: Int) -> GLuint
    {
        var VBO: GLuint = 0;
    
        glGenBuffers(1, &VBO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO);
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*sizeof(Float), v, GLenum(GL_STATIC_DRAW));
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
    
//        vbo_list.push_back(VBO);
    
        return VBO;
    }
    
    private init(){
        dx = (x2-x1)/Float(nPoints)
        
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
    }
    
    func setupData(){
        var vShader: GLuint = 0
        var fShader: GLuint = 0
        
        vShader = glCreateShader(GLenum(GL_VERTEX_SHADER));
        fShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER));
        
        let cstringv = vsSource.cStringUsingEncoding(NSUTF8StringEncoding)
        glShaderSource(vShader, 1, UnsafePointer(cstringv!), nil);
        let cstringf = fsSource.cStringUsingEncoding(NSUTF8StringEncoding)
        glShaderSource(fShader, 1, UnsafePointer(cstringf!), nil);
        
        glCompileShader(vShader);
        glCompileShader(fShader);
        
        //ShaderStatus(vShader, GL_COMPILE_STATUS)
        //ShaderStatus(fShader, GL_COMPILE_STATUS)
        
        var pr: GLuint = 0
        
        pr = glCreateProgram();
        glAttachShader(pr, vShader);
        glAttachShader(pr, fShader);
        
        glLinkProgram(pr);
        
        //ShaderProgramStatus(pr, GL_LINK_STATUS)
        
        glUseProgram(pr);
        
        //ShaderProgramStatus(pr, GL_VALIDATE_STATUS)
 
        xAttr = glGetAttribLocation(pr, "coordx")
        yAttr = glGetAttribLocation(pr, "coordy")
        
        cUnif = glGetUniformLocation(pr, "solidColor");
        
        pmUnif = glGetUniformLocation(pr, "projectionMatrix");
        
        glUniformMatrix4fv(pmUnif, 1, GLboolean(GL_TRUE), distributionPM);
        
        glUseProgram(0)
        program = pr
        
        var x: [Float] = [Float]()
        x.reserveCapacity(nPoints)
        
        var y: [Float] = [Float]()
        y.reserveCapacity(nPoints)
        
        //var y1: [Float] = [Float]()
        //y1.reserveCapacity(nPoints)
        
        for i:Int in (0...nPoints){
            let xi = x1 + (dx * Float(i))
            x.append(xi)
            y.append(GraphixManager.f(x[i], g: G))
          //  y1.append(f(x[i], 0.5));
        }
        
        let xVBO = GraphixManager.genBuffer(x, count: nPoints);
        let yVBO = GraphixManager.genBuffer(y, count: nPoints);
        
        distrGraph = GraphDescriptor(xVbo: xVBO, yVbo: yVBO, n: GLsizei(nPoints), color: Black)
        //graph_list.push_back(graph(xVBO,y1,nPoints, red, 0xF0F0));
    }
}