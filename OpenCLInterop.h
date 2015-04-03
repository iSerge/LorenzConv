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

+(void)shift_f:(const cl_ndrange*) ndRangePointer withInput: (void*) inBuf andOutput: (void*) outBuf
                 count: (const int) n shift: (const float) shift;

+(void)weight_f:(const cl_ndrange*) ndRangePointer withInput: (void*) inBuf andOutput: (void*) outBuf
                 count: (const int) n weight: (const float) weight;

+(void)calcConvolution_f:(const cl_ndrange*) ndRangePointer withInputX: (void*) inBufX
              inputY: (void*) inBufY andOutput: (void*) outBuf
                   count: (const int) n gamma: (const float) gamma;
@end
