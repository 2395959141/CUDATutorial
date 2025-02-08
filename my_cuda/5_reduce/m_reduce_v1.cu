

template <int blockSize>
__global__ void reduce_v1(float *d_in, float *d_out){
    int tid = threadIdx.x;
    int gtid = blockIdx.x * blockSize + threadIdx.x;

    __shared__ float smem[blockSize];
    smem[tid] = d_in[gtid];
    __syncthreads();

    for(int index = 1; index < blockDim.x; index *= 2){
        if((tid & (2 * index - 1)) == 0){
            smem[tid] += smem[tid + index];
        }
        __syncthreads();
    }

    if(tid == 0){
        d_out[blockIdx.x] = smem[0];
    }
}