import numpy as np
import cProfile
import pstats

# Simulate HDC vectors (10,000 dimensions, using 32-bit integers)
DIMENSIONS = 10000
VECTORS = 50000  # Run it many times to get a measurable profile

def hdc_bind_kernel(a, b):
    # In HDC, binding is typically a bitwise XOR across the vectors
    return np.bitwise_xor(a, b)

def run_workload():
    # Initialize random vectors
    base_vector = np.random.randint(0, 2, DIMENSIONS, dtype=np.int32)
    stream_vector = np.random.randint(0, 2, DIMENSIONS, dtype=np.int32)
    
    # Loop to simulate processing a continuous stream of sensor data
    for _ in range(VECTORS):
        _ = hdc_bind_kernel(base_vector, stream_vector)

if __name__ == "__main__":
    print("Profiling HDC Binding Kernel...")
    profiler = cProfile.Profile()
    profiler.enable()
    run_workload()
    profiler.disable()
    
    # Save the output exactly where the professor requested
    with open('../codefest/cf02/profiling/project_profile.txt', 'w') as f:
        stats = pstats.Stats(profiler, stream=f)
        stats.sort_stats('cumtime').print_stats(30)
    print("Profile saved to codefest/cf02/profiling/project_profile.txt")