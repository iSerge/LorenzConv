//
//  OpenCLInterop.h
//  LorenzConv
//
//  Created by Serge on 22/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenCL/OpenCL.h>

@interface OpenCLInterop : NSObject
+(void)calcLorenzian_f:(const cl_ndrange*) ndRangePointer withXVec: (void*) xBuf andYVec: (void*) yBuf
    count: (const int) n center: (const float) x0 gamma: (const float) gamma;
@end
