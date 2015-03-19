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
    
    var ghole: Double = 2.0 {
        didSet {
            //update distribution curve

            
            //calculate convolution with new parameter
            
            //udate graphs
        }
    }
}