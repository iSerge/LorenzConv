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

    @NSManaged dynamic var n: Int
    @NSManaged dynamic var name: String
    @NSManaged dynamic var reference: Bool
    @NSManaged dynamic var shift: Float
    @NSManaged dynamic var weight: Float
    @NSManaged dynamic var x: NSData
    @NSManaged dynamic var y: NSData
    @NSManaged dynamic var convolution: ConvolutionParams
    
    @NSManaged dynamic var colorIndex: Int

    var changeObserver: AnyObject?
    
    var graph: GraphDescriptor?
    var sgraph: GraphDescriptor?
    var cgraph: GraphDescriptor?
    
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
        let xVBO = GraphixManager.genBuffer(data.0, count: n)
        let yVBO = GraphixManager.genBuffer(data.1, count: n)
        
        self.xLimits = Spectre.minMax(data.0)
        self.yLimits = Spectre.minMax(data.1)
        
        if let g = self.graph {
            g.dispose()
        }
        
        self.graph = GraphDescriptor(xVbo: xVBO, yVbo: yVBO, n: GLsizei(n),
            color: GraphixManager.sharedInstance.Red.components)

        if let g = self.sgraph {
            g.dispose()
        }

        let sxVBO = GraphixManager.genBufferForCL(n)
        let syVBO = GraphixManager.genBufferForCL(n)

        self.sgraph = GraphDescriptor(xVbo: sxVBO, yVbo: syVBO, n: GLsizei(n),
            color: GraphixManager.sharedInstance.LightRed.components)

        if let g = self.cgraph {
            g.dispose()
        }

        shiftAndWeight()

        let cxVBO = GraphixManager.genBufferCopy(sxVBO)
        let cyVBO = GraphixManager.genBufferCopy(syVBO)
        
        self.cgraph = GraphDescriptor(xVbo: cxVBO, yVbo: cyVBO, n: GLsizei(n),
            color: GraphixManager.sharedInstance.Red.components)
    }
    
    func setData(data:([Float],[Float])){
        let n = data.0.count
        self.n = n
        self.x = NSData(bytes: data.0, length: n*sizeof(Float))
        self.y = NSData(bytes: data.1, length: n*sizeof(Float))
        
        updateInternalState(data)
    }
    
    func shiftAndWeight(){
        ConvolutionUpdateController.shiftAndWeight(self)
    }
}
