//
//  ConvolutionParams.swift
//  LorenzConv
//
//  Created by Serge on 14/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit

@objc(ConvolutionParams)
class ConvolutionParams: NSObject {
    @IBOutlet weak var distributionView: NSOpenGLView!
    @IBOutlet weak var convolutionView: NSOpenGLView!
    
    var ghole: Float = 2.0 {
        didSet {
            //update distribution curve
            GraphixManager.sharedInstance.distrGraph.calcDistribution(ghole, x0: 0.0)
            
            //calculate convolution with new parameter
            
            //udate graphs
            distributionView.needsDisplay = true
            convolutionView.needsDisplay = true
        }
    }
}