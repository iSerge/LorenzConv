//
//  PendingOperations.swift
//  LorenzConv
//
//  Created by Ksenia Kozlovskaya on 18/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Foundation

class PendingOperations {
    lazy var dataUpdatesInProgress = [NSIndexPath:NSOperation]()
    lazy var dataUpdatesQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Data updates queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}