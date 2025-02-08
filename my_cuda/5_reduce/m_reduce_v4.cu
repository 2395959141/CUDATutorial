
__device__ void WarpSharedMemReduce(volatile float* smem, int tid) {
    float x = smem[tid];
    if(blockDim.x >= 64){
        x += smem[tid + 32]; __syncwarp();
        smem[tid] = x; __syncwarp();
    }
    x += smem[tid + 16];
    smem[tid] = x;
    x += smem[tid + 8];
    smem[tid] = x;
    x += smem[tid + 4];
    smem[tid] = x;
    x += smem[tid + 2];
    smem[tid] = x;
    x += smem[tid + 1];
    smem[tid] = x;
}





template <int blockSize>
__global__ void reduce_v4(float *d_in, float *d_out){
    __shared__ float smem[blockSize];
    int tid = threadIdx.x;
    int gtid = blockIdx.x * blockSize + threadIdx.x;
    smem[tid] = d_in[gtid] + d_in[gtid + blockSize];
    __syncthreads();

    for(int index = blockDim.x / 2; index > 0; index >>= 1){
        if(tid < index){
            smem[tid] += smem[tid + index];
        }
        __syncthreads();
    }
    if (tid < 32){
        WarpSharedMemReduce(smem, tid);
    }
    if(tid == 0){
        d_out[blockIdx.x] = smem[0];
    }
}