//
//  OpenCLInterop.m
//  LorenzConv
//
//  Created by Serge on 22/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

#import "OpenCLInterop.h"
#import "lorenz.cl.h"

@implementation OpenCLInterop
+(void)calcLorenzian_f:(const cl_ndrange*) ndRangePointer withXVec: (void*) xBuf andYVec: (void*) yBuf
                 count: (const int) n center: (const float) x0 gamma: (const float) gamma
{
    calcLorenzian_f_kernel(ndRangePointer, xBuf, yBuf, n, x0, gamma);
}
@end
