//
//  ConvolutionParams.swift
//  LorenzConv
//
//  Created by Serge on 14/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import AppKit
import CoreData

@objc(ConvolutionParams)
class ConvolutionParams: NSManagedObject {
    
    @NSManaged dynamic var ghole: NSNumber
    @NSManaged dynamic var spectres: NSMutableSet
    
    var gholeO: Float = 2.0 {
        didSet {
            //update distribution curve
//            GraphixManager.sharedInstance.distrGraph.calcDistribution(ghole, x0: 0.0)
            
            //calculate convolution with new parameter
            
            //udate graphs
  //          distributionView.needsDisplay = true
    //        convolutionView.needsDisplay = true
        }
    }
}