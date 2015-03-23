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

}
