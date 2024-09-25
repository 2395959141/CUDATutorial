#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

typedef float FLOAT;

/* CUDA kernel function */
__global__ void vec_add(FLOAT *x, FLOAT *y, FLOAT *z, int N)
{
    /* 2D grid */
    int idx = (blockDim.x * (blockIdx.x + blockIdx.y * gridDim.x) + threadIdx.x);
    /* 1D grid */
    // int idx = blockDim.x * blockIdx.x + threadIdx.x;
    if (idx < N) z[idx] = y[idx] + x[idx];
}

void vec_add_cpu(FLOAT *x, FLOAT *y, FLOAT *z, int N)
{
    for (int i = 0; i < N; i++) z[i] = y[i] + x[i];
}

int main()
{
    int N = 10000;
    int nbytes = N * sizeof(FLOAT);

    /* 1D block */
    int bs = 256;

    /* 2D grid */
    int s = ceil(sqrt((N + bs - 1.) / bs));  //用来向上取整的技巧，计算网络中需要多少块
    dim3 grid(s, s);   //使用 dim3 类型定义了一个二维网格，其大小为 s x s，
                       //这意味着这个网格有 s 行和 s 列，每个位置上都是一个 block。
    
    /* 1D grid */
    // int s = ceil((N + bs - 1.) / bs);
    // dim3 grid(s);

    // FLOAT *dx, *hx;
    // FLOAT *dy, *hy;
    // FLOAT *dz, *hz;

    FLOAT *hx, *hy, *hz;

    // /* allocate GPU mem */
    // cudaMalloc((void **)&dx, nbytes);
    // cudaMalloc((void **)&dy, nbytes);
    // cudaMalloc((void **)&dz, nbytes);
    
    // /* init time */
    // float milliseconds = 0;

    // /* alllocate CPU mem */
    // hx = (FLOAT *) malloc(nbytes);
    // hy = (FLOAT *) malloc(nbytes);
    // hz = (FLOAT *) malloc(nbytes);

    // /* init */
    // for (int i = 0; i < N; i++) {
    //     hx[i] = 1;
    //     hy[i] = 1;
    // }

    // /* copy data to GPU */
    // cudaMemcpy(dx, hx, nbytes, cudaMemcpyHostToDevice);
    // cudaMemcpy(dy, hy, nbytes, cudaMemcpyHostToDevice);

    /* 使用 cudaMallocManaged 进行统一内存分配 */
    cudaMallocManaged(&hx, nbytes);
    cudaMallocManaged(&hy, nbytes);
    cudaMallocManaged(&hz, nbytes);

     /* 初始化数据 */
    for (int i = 0; i < N; i++) {
        hx[i] = 1;
        hy[i] = 1;
    }

     /* init time */
    float milliseconds = 0;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    /* launch GPU kernel */
    vec_add<<<grid, bs>>>(hx, hy, hz, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);  
    
	// /* copy GPU result to CPU */
    // cudaMemcpy(hz, dz, nbytes, cudaMemcpyDeviceToHost);

    /* CPU compute */
    FLOAT* hz_cpu_res = (FLOAT *) malloc(nbytes);
    vec_add_cpu(hx, hy, hz_cpu_res, N);

    /* check GPU result with CPU*/
    for (int i = 0; i < N; ++i) {
        if (fabs(hz_cpu_res[i] - hz[i]) > 1e-6) {
            printf("Result verification failed at element index %d!\n", i);
        }
    }
    printf("Result right\n");
    printf("Mem BW= %f (GB/sec)\n", (float)N*4/milliseconds/1e6); ///
    // cudaFree(dx);
    // cudaFree(dy);
    // cudaFree(dz);

    cudaFree(hx);
    cudaFree(hy);
    cudaFree(hz);

    free(hz_cpu_res);

    return 0;
}