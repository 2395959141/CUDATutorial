cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

# 设置CUDA编译器路径
set(CMAKE_CUDA_COMPILER /usr/local/cuda-12.6/bin/nvcc)
set(CUDA_TOOLKIT_ROOT_DIR /usr/local/cuda-12.6)
set(CUDA_BIN_PATH /usr/local/cuda-12.6/bin)

project(reduce_examples LANGUAGES CXX CUDA)

# 添加调试选项设置
set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_CUDA_FLAGS_DEBUG "${CMAKE_CUDA_FLAGS_DEBUG} -G -g -O0")
set(CMAKE_CUDA_FLAGS_RELEASE "${CMAKE_CUDA_FLAGS_RELEASE} -O3")

find_package(CUDA 12.6 REQUIRED)
set(CUDA_PATH ${CUDA_TOOLKIT_ROOT_DIR})

# 设置编译器标志
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -Wall")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -G -g")
endif()

# 设置CUDA架构
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS}  \
    -gencode=arch=compute_70,code=\\\"sm_70,compute_70\\\" \
    -gencode=arch=compute_75,code=\\\"sm_75,compute_75\\\" \
    -gencode=arch=compute_80,code=\\\"sm_80,compute_80\\\" \
    -gencode=arch=compute_86,code=\\\"sm_86,compute_86\\\" \
    -gencode=arch=compute_89,code=\\\"sm_89,compute_89\\\" \
")
set(CMAKE_CUDA_ARCHITECTURES 70 75 80 86 89)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 设置头文件和库文件路径
include_directories(
    ${CUDA_PATH}/include
)

link_directories(
    ${CUDA_PATH}/lib64
)

# 添加可执行文件
add_executable(reduce_v5
    5_reduce/reduce_v5.cu
)

# 链接CUDA库
target_link_libraries(
    reduce_v2_64bank
    PUBLIC
    -lcudart
    -lcudadevrt
) 