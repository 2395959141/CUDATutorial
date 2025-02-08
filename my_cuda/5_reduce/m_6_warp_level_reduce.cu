
template <int blockSize>
__device__ float WarpShuffle(float sum) {
    sum += __shfl_down_sync(0xffffffff, sum, 16);
    sum += __shfl_down_sync(0xffffffff, sum, 8);
    sum += __shfl_down_sync(0xffffffff, sum, 4);
    sum += __shfl_down_sync(0xffffffff, sum, 2);
    sum += __shfl_down_sync(0xffffffff, sum, 1);
    return sum;
}


template <int blockSize>
__global__ void reduce_warp_level(float *d_in, float *d_out, unsigned int n){

    float sum = 0;
    unsigned int tid = threadIdx.x;
    unsigned int gtid = blockIdx.x * blockSize + threadIdx.x;

    unsigned int total_thread_num = blockSize * gridDim;

    for(int i = gtid; i < n; i += total_thread_num) {
        sum += d_in[i];
    }

    __shared__ float WarpSums[blockSize / WarpSize];
    const int laneId = tid % WarpSize;
    const int warpId = tid / WarpSize;
    sum = WarpShuffle<blockSize>(sum);

    if(laneId == 0) {
        WarpSums[warpId] = sum;
    }
    __syncthreads();

    sum = (tid < blockSize / WarpSize) ? WarpSums[laneId] : 0;

    if(warpId == 0) {
        sum = WarpShuffle<blockSize / WarpSize>(sum);
    }

    if(tid == 0) {
        d_out[blockIdx.x] = sum;
    }

    
}
