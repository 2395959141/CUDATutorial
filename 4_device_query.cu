#include <cuda_runtime.h>
#include <cuda.h>
#include <iostream>
#include <string>

int main() {
  int deviceCount = 0;
  // 获取当前机器的GPU数量
  cudaError_t error_id = cudaGetDeviceCount(&deviceCount);
  if (deviceCount == 0) {
    printf("There are no available device(s) that support CUDA\n");
  } else {
    printf("Detected %d CUDA Capable device(s)\n", deviceCount);
  }
  for (int dev = 0; dev < deviceCount; ++dev) {
    cudaSetDevice(dev);
    // 初始化当前device的属性获取对象
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, dev);

    printf("\nDevice %d: \"%s\"\n", dev, deviceProp.name);
    // 显存容量
    printf("  Total amount of global memory:                 %.0f MBytes "
             "(%llu bytes)\n",
             static_cast<float>(deviceProp.totalGlobalMem / 1048576.0f),
             (unsigned long long)deviceProp.totalGlobalMem);
    // 时钟频率
    printf( "  GPU Max Clock rate:                            %.0f MHz (%0.2f "
        "GHz)\n",
        deviceProp.clockRate * 1e-3f, deviceProp.clockRate * 1e-6f);
    // L2 cache大小
    printf("  L2 Cache Size:                                 %d bytes\n",
             deviceProp.l2CacheSize);
    // high-frequent used
    // 注释见每个printf内的字符串
    printf("  Total amount of shared memory per block:       %zu bytes\n",
           deviceProp.sharedMemPerBlock);
    printf("  Total shared memory per multiprocessor:        %zu bytes\n",
           deviceProp.sharedMemPerMultiprocessor);
    printf("  Total number of registers available per block: %d\n",
           deviceProp.regsPerBlock);
    printf("  Warp size:                                     %d\n",
           deviceProp.warpSize);
    printf("  Maximum number of threads per multiprocessor:  %d\n",
           deviceProp.maxThreadsPerMultiProcessor);
    printf("  Maximum number of threads per block:           %d\n",
           deviceProp.maxThreadsPerBlock);
    printf("  Max dimension size of a block size (x,y,z): (%d, %d, %d)\n",
           deviceProp.maxThreadsDim[0], deviceProp.maxThreadsDim[1],
           deviceProp.maxThreadsDim[2]);
    printf("  Max dimension size of a grid size    (x,y,z): (%d, %d, %d)\n",
           deviceProp.maxGridSize[0], deviceProp.maxGridSize[1],
           deviceProp.maxGridSize[2]);
    
    // 添加GPU核心数量信息
    printf("  Number of multiprocessors:                    %d\n",
           deviceProp.multiProcessorCount);
    
    // 根据计算能力计算每个SM的CUDA核心数
    int cudaCores = 0;
    int major = deviceProp.major;
    int minor = deviceProp.minor;
    
    // 根据计算能力确定每个SM的CUDA核心数
    switch (major) {
        case 2: // Fermi
            if (minor == 0) cudaCores = 32;
            else cudaCores = 48;
            break;
        case 3: // Kepler
            cudaCores = 192;
            break;
        case 5: // Maxwell
            cudaCores = 128;
            break;
        case 6: // Pascal
            if ((minor == 0) || (minor == 1)) cudaCores = 64;
            else if (minor == 2) cudaCores = 128;
            break;
        case 7: // Volta and Turing
            if ((minor == 0) || (minor == 5)) cudaCores = 64;
            else cudaCores = 128;
            break;
        case 8: // Ampere
            if (minor == 0) cudaCores = 64;
            else if (minor == 6) cudaCores = 128;
            else cudaCores = 128;
            break;
        case 9: // Hopper
            cudaCores = 128;
            break;
        default:
            cudaCores = 0;
            printf("  Unknown device type\n");
            break;
    }
    
    printf("  Compute capability:                           %d.%d\n", 
           major, minor);
    printf("  CUDA Cores per multiprocessor:               %d\n", 
           cudaCores);
    printf("  Total CUDA Cores:                            %d\n",
           cudaCores * deviceProp.multiProcessorCount);
    
    // 添加内存带宽信息
    printf("  Memory Clock rate:                            %.0f Mhz\n",
           deviceProp.memoryClockRate * 1e-3f);
    printf("  Memory Bus Width:                             %d-bit\n",
           deviceProp.memoryBusWidth);
    
    // 计算理论带宽
    float theoretical_bandwidth = (deviceProp.memoryClockRate * 1e-3f) * 
                                (deviceProp.memoryBusWidth / 8) * 2 / 1024.0f;
    printf("  Theoretical Memory Bandwidth:                 %.1f GB/s\n", 
           theoretical_bandwidth);
    
    // 如果启用了ECC，实际带宽会略低
    if (deviceProp.ECCEnabled) {
        printf("  ECC is enabled - Actual Bandwidth reduced\n");
        theoretical_bandwidth *= 0.93f; // 大约损失7%的带宽
        printf("  Estimated Actual Memory Bandwidth:            %.1f GB/s\n",
               theoretical_bandwidth);
    }
  }
  return 0;
}