import time
import statistics
import numpy as np
import platform
import resource

DIMENSIONS = 10000
VECTORS_PER_BATCH = 50000
RUNS = 10

def run_benchmark():
    base_vector = np.random.randint(0, 2, DIMENSIONS, dtype=np.int32)
    stream_vector = np.random.randint(0, 2, DIMENSIONS, dtype=np.int32)
    
    # Warmup
    for _ in range(1000):
        _ = np.bitwise_xor(base_vector, stream_vector)
        
    times = []
    for _ in range(RUNS):
        start_time = time.perf_counter()
        for _ in range(VECTORS_PER_BATCH):
            _ = np.bitwise_xor(base_vector, stream_vector)
        end_time = time.perf_counter()
        times.append(end_time - start_time)
        
    median_time = statistics.median(times)
    throughput = VECTORS_PER_BATCH / median_time
    
    # Get peak memory usage (macOS returns bytes)
    mem_usage_mb = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss / (1024 * 1024)
    
    print("\n--- COPY AND PASTE THIS INTO sw_baseline.md ---")
    print(f"**Platform & Configuration:**")
    print(f"* OS: {platform.system()} {platform.release()}")
    print(f"* Hardware: Apple Mac (Dual-Core)")
    print(f"* Python Version: {platform.python_version()}")
    print(f"* Batch Size: {VECTORS_PER_BATCH} vectors (Dimension: {DIMENSIONS})")
    print(f"\n**Execution Time:**")
    print(f"* Median over 10 runs: {median_time:.4f} seconds")
    print(f"\n**Throughput:**")
    print(f"* {throughput:,.2f} samples/sec (vector bindings per second)")
    print(f"\n**Memory Usage:**")
    print(f"* Peak RSS: {mem_usage_mb:.2f} MB")

if __name__ == "__main__":
    run_benchmark()