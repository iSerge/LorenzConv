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
            if nil != s.graph && nil != s.sgraph {
                ConvolutionUpdateController.shiftAndWeight(s.graph!, sgraph: s.sgraph!, shift: s.shift.floatValue, weight: s.weight.floatValue)
            }
            spectresUpdated()
        }
    }
    
    func spectresUpdated() {
        for s: Spectre in spectres {
            if nil == s.changeObserver {
                let observer = ChangeObserver(controller: self)
                s.changeObserver = observer
                observer.startObserving(s)
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
                ConvolutionUpdateController.calcConvolution(s.sgraph!, cgraph: s.cgraph!, gamma: self.gHole)
            }
        }
        
        distributionView.needsDisplay = true
    }
    
    class func calcDistribution(graph: GraphDescriptor, gamma: Float, x0: Float){
        dispatch_sync(GraphixManager.sharedInstance.queue){
            let r = [graph.ndrange]
            OpenCLInterop.calcLorenzian_f(r, withXVec: graph.xBuf, andYVec: graph.yBuf,
                count: graph.n, center: 0.0, gamma: gamma)
        }
    }
    
    class func shiftAndWeight(graph: GraphDescriptor, sgraph: GraphDescriptor, shift: Float, weight: Float){
        dispatch_sync(GraphixManager.sharedInstance.queue){
            let r = [graph.ndrange]
            OpenCLInterop.shift_f(r, withInput: graph.xBuf, andOutput: sgraph.xBuf,
                count: graph.n, shift: shift)
            OpenCLInterop.weight_f(r, withInput: graph.yBuf, andOutput: sgraph.yBuf,
                count: graph.n, weight: weight)
        }
    }

    class func calcConvolution(graph: GraphDescriptor, cgraph: GraphDescriptor, gamma: Float){
        dispatch_sync(GraphixManager.sharedInstance.queue){
            let r = [graph.ndrange]
            OpenCLInterop.calcConvolution_f(r, withInputX: graph.xBuf, inputY: graph.yBuf,
                andOutput: cgraph.yBuf, count: graph.n, gamma: gamma)
        }
    }
    
}