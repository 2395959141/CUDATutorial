


template <int blockSize>
__global__ void reduce_v3(float *d_in, float *d_out){
    __shared__ float smem[blockSize];
    int tid = threadIdx.x;
    int gtid = blockIdx.x * blockSize + threadIdx.x;

    __shared__ float smem[blockSize];
    smem[tid] = d_in[gtid] + d_in[gtid + blockSize];
    __syncthreads();

    for(int index = blockDim.x / 2; index > 0; index >>= 1){
        if(tid < index){
            smem[tid] += smem[tid + index];
        }
        __syncthreads();
    }

    if(tid == 0){
        d_out[blockIdx.x] = smem[0];
    }
}