//
//  lorenz.cl
//  LorenzConv
//
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#define M_PI        3.14159265358979323846264338327950288   /* pi */
#define M_PI_2      1.57079632679489661923132169163975144   /* pi/2 */
#define M_PI_4      0.785398163397448309615660845819875721  /* pi/4 */
#define M_1_PI      0.318309886183790671537767526745028724  /* 1/pi */
#define M_2_PI      0.636619772367581343075535053490057448  /* 2/pi */

//double lorenz(double x, double x0, double gamma){
//    const double dx = x - x0;
//    return gamma * M_1_PI / (dx*dx + gamma*gamma);
//}

//double lorenzCDF(double x, double x0, double gamma){
//    return atan2pi(x-x0, gamma) + 0.5;
//}

float lorenz_f(float x, float x0, float gamma){
    const float dx = x - x0;
    return gamma * M_1_PI_F / (dx*dx + gamma*gamma);
}

float lorenzCDF_f(float x, float x0, float gamma){
    return atan2pi(x-x0, gamma) + 0.5f;
}

//kernel void calcLorenzian(global read_only double* x, global write_only double* y, const int n, double x0, double gamma){
//    const size_t i = get_global_id(0);
//    if(i<n){
//        y[i] = lorenz(x[i], x0, gamma);
//    }
//}

__kernel void calcLorenzian_f(__global __read_only float* x, __global __write_only float* y,
                            const int n, const float x0, const float gamma)
{
    const size_t i = get_global_id(0);
    if(i<n){
        y[i] = lorenz_f(x[i], x0, gamma);
    }
}
