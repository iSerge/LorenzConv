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

+(void)shift_f:(const cl_ndrange*) ndRangePointer withInput: (void*) inBuf andOutput: (void*) outBuf
         count: (const int) n shift: (const float) shift
{
    shift_f_kernel(ndRangePointer, inBuf, outBuf, n, shift);
}

+(void)weight_f:(const cl_ndrange*) ndRangePointer withInput: (void*) inBuf andOutput: (void*) outBuf
          count: (const int) n weight: (const float) weight
{
    weight_f_kernel(ndRangePointer, inBuf, outBuf, n, weight);
}

+(void)calcConvolution_f:(const cl_ndrange*) ndRangePointer withInputX: (void*) inBufX
              inputY: (void*) inBufY andOutput: (void*) outBuf
              count: (const int) n gamma: (const float) gamma
{
    calcConvolution_f_kernel(ndRangePointer, inBufX, inBufY, outBuf, n, gamma);
}

@end
