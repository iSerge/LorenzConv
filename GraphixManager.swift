//
//  GraphixManager.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 18/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Foundation
import OpenCL
import OpenGL
import GLKit
import GLUT

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

    let queue: dispatch_queue_t!
    let cl_gl_semaphore: dispatch_semaphore_t!

    var program: GLuint = GLuint()
    var xAttr: GLint = GLint()
    var yAttr: GLint = GLint()
    var pmUnif: GLint = GLint()
    var cUnif: GLint = GLint()
    
    var distrGraph: GraphDescriptor!

    let vsSource =
      "#version 150 core\n" +
      "uniform mat4 projectionMatrix;\n" +
      "in float coordx;\n" +
      "in float coordy;\n" +
      "void main() {\n" +
      "  gl_Position = projectionMatrix * vec4(coordx, coordy, 0.0, 1.0);\n" +
      "}\n"

    let fsSource =
      "#version 150 core\n" +
      "uniform vec4 solidColor;\n" +
      "out vec4 color;\n" +
      "void main() {\n" +
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

    class func genBufferForCL(count: Int) -> GLuint
    {
        var VBO: GLuint = 0;
        glGenBuffers(1, &VBO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO);
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*sizeof(Float), nil, GLenum(GL_DYNAMIC_COPY));
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0);
        
        //        vbo_list.push_back(VBO);
        
        return VBO;
    }

    class func GetGLErrorString(error: GLenum) -> String {
        switch(Int(error)){
            case Int(GL_NO_ERROR):
                return "GL_NO_ERROR"
            case Int(GL_INVALID_ENUM):
                return "GL_INVALID_ENUM"
            case Int(GL_INVALID_VALUE):
                return "GL_INVALID_VALUE"
            case Int(GL_INVALID_OPERATION):
                return "GL_INVALID_OPERATION"
            case Int(GL_OUT_OF_MEMORY):
                return "GL_OUT_OF_MEMORY"
            case Int(GL_INVALID_FRAMEBUFFER_OPERATION):
                return "GL_INVALID_FRAMEBUFFER_OPERATION"
            case Int(GL_STACK_OVERFLOW):
                return "GL_STACK_OVERFLOW"
            case Int(GL_STACK_UNDERFLOW):
                return "GL_STACK_UNDERFLOW"
            case Int(GL_TABLE_TOO_LARGE):
                return "GL_TABLE_TOO_LARGE"
            default:
                return String(format: "(ERROR: Unknown Error Enum - )", Int(error));
        }
    }
    
    class func ShaderStatus(shader: GLuint, param: GLenum) -> GLint
    {
        var status: GLint = GL_TRUE
    
        glGetShaderiv(shader, param, &status)
        GraphixManager.checkOpenGLerror("ShaderStatus.glGetProgramiv")
    
        if (status != GL_TRUE){
            var infologLen: GLint = 0;
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infologLen)
            GraphixManager.checkOpenGLerror("ShaderStatus.glGetProgramiv")
            if(infologLen > 1){
                var infoLog: [GLchar] = [GLchar](count: Int(infologLen), repeatedValue: 0)
                var charsWritten: GLint = 0;
                glGetShaderInfoLog(shader, infologLen, &charsWritten, &infoLog);
                GraphixManager.checkOpenGLerror("ShaderStatus.glGetShaderInfoLog");
                NSLog("ShaderStatus::glGetShaderInfoLog")
                NSLog("Shader program: %@", NSString(bytes: infoLog, length: Int(charsWritten), encoding: NSASCIIStringEncoding)!)
            }
        }
    
        return status;
    }

    class func ProgramStatus(program: GLuint, param: GLenum) -> GLint
    {
        var status: GLint = GL_TRUE
        
        glGetProgramiv(program, param, &status)
        GraphixManager.checkOpenGLerror("ProgramStatus.glGetProgramiv")
        
        if (status != GL_TRUE){
            var infologLen: GLint = 0;
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infologLen)
            GraphixManager.checkOpenGLerror("ProgramStatus.glGetProgramiv")
            if(infologLen > 1){
                var infoLog: [GLchar] = [GLchar](count: Int(infologLen), repeatedValue: 0)
                var charsWritten: GLint = 0;
                glGetProgramInfoLog(program, infologLen, &charsWritten, &infoLog);
                GraphixManager.checkOpenGLerror("ProgramStatus.glGetProgramInfoLog");
                NSLog("ProgramStatus::glGetShaderInfoLog")
                NSLog("Program: %@", NSString(bytes: infoLog, length: Int(charsWritten), encoding: NSASCIIStringEncoding)!)
            }
        }
        
        return status;
    }

    
    class func checkOpenGLerror(loc: String) {
        let errCode = glGetError()
        if(errCode != GLenum(GL_NO_ERROR)){
            NSLog("%@: OpenGl error! - %@\n",loc, GraphixManager.GetGLErrorString(errCode))
        }
    }

    private init(){
        dx = (x2-x1)/Float(nPoints)
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(NSOpenGLPFAColorSize), 24,
            UInt32(NSOpenGLPFAAlphaSize), 8,
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAAccelerated),
            0 ]

        pixelFormat = NSOpenGLPixelFormat(attributes: attrs)

        if (nil == pixelFormat){
            NSLog("No OpenGL pixel format");
        }

        glContext = NSOpenGLContext(format:pixelFormat, shareContext:nil)

        if let context = glContext {
            CGLEnable(context.CGLContextObj, kCGLCECrashOnRemovedFunctions)
        }
        
        var swapInt: GLint = 1;
        glContext?.setValues(&swapInt, forParameter: NSOpenGLContextParameter.GLCPSwapInterval)

        glContext?.makeCurrentContext()
        
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glLineWidth(1.0);
        glEnable(GLenum(GL_LINE_SMOOTH));
        glHint(GLenum(GL_LINE_SMOOTH_HINT),  GLenum(GL_NICEST));
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        
        var kCGLShareGroup = CGLGetShareGroup(glContext!.CGLContextObj)

//        OGLWrapper.my_gl_set_sharegroup(kCGLShareGroup)
        gcl_gl_set_sharegroup(UnsafeMutablePointer(kCGLShareGroup))
        
        queue = gcl_create_dispatch_queue(cl_queue_flags(CL_DEVICE_TYPE_GPU), nil)
        if(nil == queue){
            NSLog("Error: Failed to create a dispatch queue!")
        }
        
        cl_gl_semaphore = dispatch_semaphore_create(0)
        
        if (nil == cl_gl_semaphore){
            NSLog("Error: Failed to create a dispatch semaphore!");
        }
        
        var ComputeDeviceId = gcl_get_device_id_with_dispatch_queue(queue);
        
        var vendor_name: [CChar] = [CChar](count: 1024, repeatedValue: 0)
        var device_name: [CChar] = [CChar](count: 1024, repeatedValue: 0)
        var returned_size: size_t = 0
        
        let err = clGetDeviceInfo( ComputeDeviceId, cl_device_info(CL_DEVICE_VENDOR), 1024, &vendor_name, &returned_size);
        
        let err2 = clGetDeviceInfo(ComputeDeviceId, cl_device_info(CL_DEVICE_NAME), 1024, &device_name, &returned_size);
        
        if (err != CL_SUCCESS || err2 != CL_SUCCESS){
            
            NSLog("Error: Failed to retrieve device info!")
        }
        
        NSLog("Connecting to %@ %@...", String.fromCString(vendor_name)!, String.fromCString(device_name)!);
    }
    
    func setupData(){
        var vShader: GLuint = 0
        var fShader: GLuint = 0
        
        glContext?.makeCurrentContext()
        
        vShader = glCreateShader(GLenum(GL_VERTEX_SHADER));
        fShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER));
        
        var cstringv = (vsSource as NSString).UTF8String
        var cstringvLen: GLint = GLint( (vsSource as NSString).length)
        glShaderSource(vShader, 1, &cstringv, &cstringvLen)

        
        var cstringf = (fsSource as NSString).UTF8String
        var cstringfLen: GLint = GLint( (fsSource as NSString).length)
        glShaderSource(fShader, 1, &cstringf, &cstringfLen)
        
        glCompileShader(vShader)
        GraphixManager.ShaderStatus(vShader, param: GLenum(GL_COMPILE_STATUS))
        glCompileShader(fShader)
        GraphixManager.ShaderStatus(vShader, param: GLenum(GL_COMPILE_STATUS))
        
        var pr: GLuint = 0
        
        pr = glCreateProgram();
        glAttachShader(pr, vShader);
        glAttachShader(pr, fShader);
        
        glLinkProgram(pr);
        
        GraphixManager.ProgramStatus(pr, param: GLenum(GL_LINK_STATUS))
        
        //glUseProgram(pr);
        //glValidateProgram(pr)
        //GraphixManager.ProgramStatus(pr, param: GLenum(GL_VALIDATE_STATUS))
 
        xAttr = glGetAttribLocation(pr, "coordx")
        yAttr = glGetAttribLocation(pr, "coordy")
        
        cUnif = glGetUniformLocation(pr, "solidColor")
        
        pmUnif = glGetUniformLocation(pr, "projectionMatrix")
        
        glUniformMatrix4fv(pmUnif, 1, GLboolean(GL_TRUE), distributionPM)
        
        glUseProgram(0)
        program = pr
        
        var x: [Float] = [Float](count: nPoints, repeatedValue: 0.0)
        
        let xVBO = GraphixManager.genBuffer(x, count: nPoints)
        let yVBO = GraphixManager.genBufferForCL(nPoints)

        let xBuf = gcl_gl_create_ptr_from_buffer(xVBO)
        if(nil == xBuf){
            NSLog("Failed to create opecl distr X buffer")
        }

        let yBuf = gcl_gl_create_ptr_from_buffer(yVBO)
        if(nil == yBuf){
            NSLog("Failed to create opecl distr Y buffer")
        }
        
        var ndrange = cl_ndrange(work_dim: 1, global_work_offset: (0,0,0), global_work_size: (1,1,1), local_work_size: (UInt(nPoints),1,1))
        
        distrGraph = GraphDescriptor(xVbo: xVBO, yVbo: yVBO, n: GLsizei(nPoints), color: Black)
    }
}