

template <int blockSize>
__global__ void reduce_v0(float *d_in, float *d_out){
    __shared__ float smem[blockSize];
    int tid = threadIdx.x;
    int gtid = blockIdx.x * blockSize + threadIdx.x;

    smem[tid] = d_in[gtid];
    __syncthreads();

    for(int index = 1; index < blockSize; index *= 2){
        if(tid % (2 * index) == 0){
            smem[tid] += smem[tid + index];
        }
        __syncthreads();
    }

    if(tid == 0){
         d_out[blockIdx.x] = smem[0];
    }

}