//
//  lorenz.cl
//  LorenzConv
//
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#define BLOCK_SIZE 512

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

float lorenz_1_CDF_f(float x, float x0, float gamma){
    return 0.5f - atan2pi(x-x0, gamma);
}


//kernel void calcLorenzian(global read_only double* x, global write_only double* y, const int n, double x0, double gamma){
//    const size_t i = get_global_id(0);
//    if(i<n){
//        y[i] = lorenz(x[i], x0, gamma);
//    }
//}

kernel void calcLorenzian_f(global read_only float* x, global write_only float* y,
                            const int n, const float x0, const float gamma)
{
    const size_t i = get_global_id(0);
    if(i<n){
        y[i] = lorenz_f(x[i], x0, gamma);
    }
}

kernel void shift_f(global read_only float* input, global write_only float* output,
                    const int n, const float shift)
{
    const size_t i = get_global_id(0);
    if(i<n){
        output[i] = input[i]+shift;
    }
}

kernel void weight_f(global read_only float* input, global write_only float* output,
                    const int n, const float weight)
{
    const size_t i = get_global_id(0);
    if(i<n){
        output[i] = input[i]*weight;
    }
}

kernel void calcConvolution_f(global read_only float* inX, global read_only float* inY,
                              global read_only float* outY, const int n, const float gamma)
{
    const size_t i = get_global_id(0);
    const size_t bs = get_local_size(0);
    
    const float x0 = inX[i];
    
    local float xbuf[BLOCK_SIZE];
    local float ybuf[BLOCK_SIZE];
    
    float val = 0.0f;
    
    if(i<n){
        val += inY[0]*lorenzCDF_f(inX[0], x0, gamma);
    }
    
        const int li = get_local_id(0);
        if(li < n){
            xbuf[li] = inX[li];
            ybuf[li] = inY[li];
        } else {
            xbuf[li] = inX[n-1];
            ybuf[li] = inY[n-1];
        }
        
        barrier(CLK_LOCAL_MEM_FENCE);
    
        for(int ii = 0; ii < n; ++ii){
            if(0 != ii){
                const float dx = (xbuf[ii] - xbuf[ii-1]) * 0.5f;
                const float dy = (ybuf[ii] - ybuf[ii-1]) * 0.5f;
                val += dx * (ybuf[ii] * lorenz_f(xbuf[ii], x0, gamma)
                             + (ybuf[ii]-dy) * lorenz_f(xbuf[ii]-dx, x0, gamma)) * 0.5f;
            }
            if(ii != n-1){
                const float dx = (xbuf[ii+1] - xbuf[ii]) * 0.5f;
                const float dy = (ybuf[ii+1] - ybuf[ii]) * 0.5f;
                val += dx * (ybuf[ii] * lorenz_f(xbuf[ii], x0, gamma)
                             + (ybuf[ii]+dy) * lorenz_f(xbuf[ii]+dx, x0, gamma)) * 0.5f;
            }
        }
    
    if (i < n){
        val += inY[n-1]*lorenz_1_CDF_f(inX[n-1], x0, gamma);
        outY[i] = val;
    }
}


/*
kernel void calcConvolution_f(global read_only float* inX, global read_only float* inY,
                              global read_only float* outY, const int n, const float gamma)
{
    const size_t i = get_global_id(0);
    const size_t bs = get_local_size(0);
    
    const float x0 = inX[i];
    
    local float xbuf[BLOCK_SIZE];
    local float ybuf[BLOCK_SIZE];
    
    float val = 0.0f;

    if(i<n){
        val += inY[0]*lorenzCDF_f(inX[0], x0, gamma);
    }

    for(int bi = 0; bi*bs < get_global_size(0); ++bi){
        const int li = get_local_id(0);
        if(bi*bs+li < n){
            xbuf[li] = inX[bi*bs+li];
            ybuf[li] = inY[bi*bs+li];
        } else {
            xbuf[li] = inX[n-1];
            ybuf[li] = inY[n-1];
        }
        
        barrier(CLK_LOCAL_MEM_FENCE);
        
        for(int ii = 0; ii < bs-1; ++ii){
            const float dx = (xbuf[ii+1] - xbuf[ii])/10.0f;
            const float dy = (ybuf[ii+1] - ybuf[ii])/10.0f;
            for(float x = xbuf[ii], y = ybuf[ii]; x < xbuf[ii+1]; x += dx, y += dy){
                val += (y + (dy*0.5f)) * dx * lorenz_f(x + (0.5f*dx), x0, gamma);
            }
        }
    }
    
    if (i < n){
        val += inY[n-1]*lorenz_1_CDF_f(inX[n-1], x0, gamma);
        outY[i] = val;
    }
}
*/