//
//  Spectre.swift
//  LorenzConv
//
//  Created by Serge on 23/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Foundation
import CoreData

@objc(Spectre)
class Spectre: NSManagedObject {

    @NSManaged dynamic var n: NSNumber
    @NSManaged dynamic var name: String
    @NSManaged dynamic var reference: NSNumber
    @NSManaged dynamic var shift: NSNumber
    @NSManaged dynamic var weight: NSNumber
    @NSManaged dynamic var x: NSData
    @NSManaged dynamic var y: NSData
    @NSManaged dynamic var convolution: ConvolutionParams

    var changeObserver: AnyObject?
    
    var graph: GraphDescriptor?
    var sgraph: GraphDescriptor?
    
    var xLimits: (Float, Float) = (-1, 1)
    var yLimits: (Float, Float) = (-1, 1)
    
    var xValues: [Float]{
        get{
            let n = x.length / sizeof(Float)
            var arr = [Float](count: n, repeatedValue: 0.0)
            x.getBytes(&arr, length: self.x.length)
            return arr;
        }
    }

    var yValues: [Float]{
        get{
            let n = y.length / sizeof(Float)
            var arr = [Float](count: n, repeatedValue: 0.0)
            y.getBytes(&arr, length: self.x.length)
            return arr;
        }
    }

    class func minMax(values: [Float]) -> (Float, Float) {
        var ma = -Float.infinity
        var mi = Float.infinity
        
        for v: Float in values {
            mi = min(mi, v)
            ma = max(ma, v)
        }
        
        return (mi, ma)
    }
    
    func updateInternalState(data:([Float],[Float])){
        let xVBO = GraphixManager.genBuffer(data.0, count: n.integerValue)
        let yVBO = GraphixManager.genBuffer(data.1, count: n.integerValue)
        
        if let g = self.graph {
            g.dispose()
        }
        
        self.graph = GraphDescriptor(xVbo: xVBO, yVbo: yVBO, n: GLsizei(n.integerValue),
            color: GraphixManager.sharedInstance.Red.components)

        if let g = self.sgraph {
            g.dispose()
//            self.sgraph = nil
        }

        let sxVBO = GraphixManager.genBufferForCL(n.integerValue)
        let syVBO = GraphixManager.genBufferForCL(n.integerValue)

        self.sgraph = GraphDescriptor(xVbo: sxVBO, yVbo: syVBO, n: GLsizei(n.integerValue),
            color: GraphixManager.sharedInstance.Red.components)
        
        shiftAndWeight()
        
        self.xLimits = Spectre.minMax(data.0)
        self.yLimits = Spectre.minMax(data.1)
    }
    
    func setData(data:([Float],[Float])){
        let n = data.0.count
        self.n = n
        self.x = NSData(bytes: data.0, length: n*sizeof(Float))
        self.y = NSData(bytes: data.1, length: n*sizeof(Float))
        
        updateInternalState(data)
    }
    
    func shiftAndWeight(){
        ConvolutionUpdateController.shiftAndWeight(self.graph!, sgraph: self.sgraph!, shift: self.shift.floatValue, weight: self.weight.floatValue)
    }
}
