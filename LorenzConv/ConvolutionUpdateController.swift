//
//  ConvolutionUpdateController.swift
//  LorenzConv
//
//  Created by Serge on 30/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit

class ConvolutionUpdateController: NSObject{
    @IBOutlet weak var distributionView: NSOpenGLView!
    @IBOutlet weak var convolutionView: GLGraph!
    
    @IBOutlet weak var convParamsController: NSObjectController!
    @IBOutlet weak var spectresController: NSArrayController!

    dynamic var gHole: Float = 1.0 { didSet { convolutionParamsUpdated() } }
    dynamic var spectres: [Spectre] = [] { didSet { spectresUpdated() } }
    
    var currColor: Int = 0

    override func awakeFromNib() {
        self.bind("gHole", toObject: convParamsController, withKeyPath: "selection.ghole", options: nil)
        self.bind("spectres", toObject: spectresController, withKeyPath: "arrangedObjects", options: nil)
    }
    
    private class ChangeObserver: NSObject {
        weak var controller: ConvolutionUpdateController?
        weak var spectre: Spectre?
        
        dynamic var reference: Bool = false { didSet { self.controller?.spectreUpdated(spectre) } }
        dynamic var shift: Float = 0.0 { didSet { self.controller?.spectreUpdated(spectre) } }
        dynamic var weight: Float = 1.0 { didSet { self.controller?.spectreUpdated(spectre) } }
        
        init(controller: ConvolutionUpdateController) {
            self.controller = controller
        }
        func startObserving(spectre: Spectre){
            self.spectre = spectre
            self.bind("reference", toObject: spectre, withKeyPath: "reference", options: nil)
            self.bind("shift", toObject: spectre, withKeyPath: "shift", options: nil)
            self.bind("weight", toObject: spectre, withKeyPath: "weight", options: nil)
        }
    }
    
    func spectreUpdated(spectre: Spectre?){
        if let s = spectre {
            ConvolutionUpdateController.shiftAndWeight(s)
            if nil != s.sgraph && nil != s.cgraph {
                ConvolutionUpdateController.calcConvolution(s.sgraph!, cgraph: s.cgraph!, gamma: gHole)
            }

            convolutionView.needsDisplay = true
        }
    }
    
    func spectresUpdated() {
        for s: Spectre in spectres {
            if nil == s.changeObserver {
                let observer = ChangeObserver(controller: self)
                s.changeObserver = observer
                observer.startObserving(s)
                
                s.colorIndex = currColor++
                
                let x = s.xValues
                let y = s.yValues
                s.updateInternalState((x,y))
                
                ConvolutionUpdateController.shiftAndWeight(s)
                ConvolutionUpdateController.calcConvolution(s.sgraph!, cgraph: s.cgraph!, gamma: gHole)
            }
        }
        
        if nil != convolutionView{
            convolutionView.graphs = spectres
        }
    }
    
    func convolutionParamsUpdated() {
        if nil != GraphixManager.sharedInstance.distrGraph {
            ConvolutionUpdateController.calcDistribution(GraphixManager.sharedInstance.distrGraph, gamma: gHole, x0: 0.0)
        }
        
        for s: Spectre in spectres {
            if nil != s.sgraph && nil != s.cgraph {
                ConvolutionUpdateController.calcConvolution(s.sgraph!, cgraph: s.cgraph!, gamma: gHole)
            }
        }
        
        distributionView.needsDisplay = true
        convolutionView.needsDisplay = true
    }
    
    class func calcDistribution(graph: GraphDescriptor, gamma: Float, x0: Float){
        dispatch_sync(GraphixManager.sharedInstance.queue){
            let r = [graph.ndrange]
            OpenCLInterop.calcLorenzian_f(r, withXVec: graph.xBuf, andYVec: graph.yBuf,
                count: graph.n, center: 0.0, gamma: gamma)
        }
    }
    
    class func shiftAndWeight(s: Spectre){
        if nil != s.graph && nil != s.sgraph {
            dispatch_sync(GraphixManager.sharedInstance.queue){
                let r = [s.graph!.ndrange]
                OpenCLInterop.shift_f(r, withInput: s.graph!.xBuf, andOutput: s.sgraph!.xBuf,
                    count: s.graph!.n, shift: s.shift)
                OpenCLInterop.weight_f(r, withInput: s.graph!.yBuf, andOutput: s.sgraph!.yBuf,
                    count: s.graph!.n, weight: s.weight)
            }
        }

        if nil != s.sgraph && nil != s.cgraph {
            glBindBuffer(GLenum(GL_COPY_READ_BUFFER), s.sgraph!.xVbo);
            glBindBuffer(GLenum(GL_COPY_WRITE_BUFFER), s.cgraph!.xVbo);
            
            var size: GLint = 0
            glGetBufferParameteriv(GLenum(GL_COPY_READ_BUFFER), GLenum(GL_BUFFER_SIZE), &size);
            
            glCopyBufferSubData(GLenum(GL_COPY_READ_BUFFER), GLenum(GL_COPY_WRITE_BUFFER), 0, 0, GLsizeiptr(size))
            
            glBindBuffer(GLenum(GL_COPY_WRITE_BUFFER), 0);
            glBindBuffer(GLenum(GL_COPY_READ_BUFFER), 0);
        }
    }

    class func calcConvolution(sgraph: GraphDescriptor, cgraph: GraphDescriptor, gamma: Float){
        dispatch_sync(GraphixManager.sharedInstance.queue){
            let r = [sgraph.ndrange]
            OpenCLInterop.calcConvolution_f(r, withInputX: sgraph.xBuf, inputY: sgraph.yBuf,
                andOutput: cgraph.yBuf, count: sgraph.n, gamma: gamma)
        }
    }
    
}