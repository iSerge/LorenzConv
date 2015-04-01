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

    dynamic var gHole: Float = 0.0 { didSet { convolutionParamsUpdated() } }
    dynamic var spectres: [Spectre] = [] { didSet { spectresUpdated() } }

    override func awakeFromNib() {
        self.bind("gHole", toObject: convParamsController, withKeyPath: "selection.ghole", options: nil)
        self.bind("spectres", toObject: spectresController, withKeyPath: "arrangedObjects", options: nil)
    }
    
    private class ChangeObserver: NSObject {
        weak var controller: ConvolutionUpdateController?
        
        dynamic var reference: Bool = false { didSet { self.controller?.spectresUpdated() } }
        dynamic var shift: Float = 0.0 { didSet { self.controller?.spectresUpdated() } }
        dynamic var weight: Float = 1.0 { didSet { self.controller?.spectresUpdated() } }
        
        init(controller: ConvolutionUpdateController) {
            self.controller = controller
        }
        func startObserving(spectre: Spectre){
            self.bind("reference", toObject: spectre, withKeyPath: "reference", options: nil)
            self.bind("shift", toObject: spectre, withKeyPath: "shift", options: nil)
            self.bind("weight", toObject: spectre, withKeyPath: "weight", options: nil)
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
        if nil == GraphixManager.sharedInstance.distrGraph {
            return
        }
        
        GraphixManager.sharedInstance.distrGraph.calcDistribution(gHole, x0: 0.0)
        distributionView.needsDisplay = true
    }
}