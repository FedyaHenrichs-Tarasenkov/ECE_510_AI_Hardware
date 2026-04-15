#include <iostream>
#include <cuda_runtime.h>

#define TILE_SIZE 8

// Task 1b: Shared-memory tiled kernel with tile size 8
__global__ void gemm_tiled(const float *A, const float *B, float *C, int N) {
    // Allocate shared memory for the tiles
    __shared__ float As[TILE_SIZE][TILE_SIZE];
    __shared__ float Bs[TILE_SIZE][TILE_SIZE];

    int bx = blockIdx.x;  int by = blockIdx.y;
    int tx = threadIdx.x; int ty = threadIdx.y;

    int row = by * TILE_SIZE + ty;
    int col = bx * TILE_SIZE + tx;

    float sum = 0.0f;
    int numTiles = N / TILE_SIZE;

    // Loop over the tiles required to compute the output
    for (int t = 0; t < numTiles; ++t) {
        // Load data from global DRAM into fast shared memory
        As[ty][tx] = A[row * N + (t * TILE_SIZE + tx)];
        Bs[ty][tx] = B[(t * TILE_SIZE + ty) * N + col];
        __syncthreads(); // Wait for all threads to finish loading the tile

        // Compute partial sum for this tile
        for (int k = 0; k < TILE_SIZE; ++k) {
            sum += As[ty][k] * Bs[k][tx];
        }
        __syncthreads(); // Wait for all threads to finish computing before loading the next tile
    }
    
    // Write the final sum back to DRAM
    C[row * N + col] = sum;
}

int main() {
    int N = 1024;
    size_t size = N * N * sizeof(float);

    float *h_A = (float*)malloc(size);
    float *h_B = (float*)malloc(size);
    float *h_C = (float*)malloc(size);

    for(int i = 0; i < N * N; i++) { h_A[i] = 1.0f; h_B[i] = 1.0f; }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_C, size);
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // Block dimensions perfectly match the TILE_SIZE
    dim3 threadsPerBlock(TILE_SIZE, TILE_SIZE);
    dim3 blocksPerGrid(N / TILE_SIZE, N / TILE_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);

    gemm_tiled<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaEventRecord(start);
    gemm_tiled<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);
    cudaEventRecord(stop);
    
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    double flops = 2.0 * N * N * N; 
    double seconds = milliseconds / 1000.0;
    double gflops = (flops / seconds) / 1e9;

    std::cout << "--- Tiled GEMM (N=1024, T=8) ---" << std::endl;
    std::cout << "Execution Time: " << milliseconds << " ms" << std::endl;
    std::cout << "Performance: " << gflops << " GFLOP/s" << std::endl;

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);
    return 0;
}
