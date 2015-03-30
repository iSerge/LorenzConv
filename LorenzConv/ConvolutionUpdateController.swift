//
//  ConvolutionUpdateController.swift
//  LorenzConv
//
//  Created by Serge on 30/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit

class ConvolutionUpdateController: NSObject {
    @IBOutlet weak var distributionView: NSOpenGLView!
    
    @IBOutlet weak var convParamsController: NSObjectController!

    dynamic var gHole: Float = 0.0 { didSet { convolutionParamsUpdated() } }

    override func awakeFromNib() {
        self.bind("gHole", toObject: convParamsController, withKeyPath: "selection.ghole", options: nil)
    }
    
    func convolutionParamsUpdated() {
        if nil == GraphixManager.sharedInstance.distrGraph {
            return
        }
        
        GraphixManager.sharedInstance.distrGraph.calcDistribution(gHole, x0: 0.0)
        distributionView.needsDisplay = true
    }
}