import matplotlib.pyplot as plt
import numpy as np
import os

# 1. Define Hardware Specifications
# Laptop CPU (Software Baseline)
cpu_peak_compute = 100.0  # GOPS
cpu_bandwidth = 30.0      # GB/s

# Custom HDC Chiplet (Hypothetical HW)
hw_peak_compute = 2000.0  # GOPS
hw_bandwidth = 1000.0     # GB/s

# HDC Kernel AI (Calculated in Task 6)
kernel_ai = 0.0833        # OPs/Byte

# 2. Generate Data Points for the Lines
# Create an array of AI values from 0.01 to 100 for the X-axis
ai_axis = np.logspace(-2, 2, 500)

# Calculate the roofline y-values: min(Peak Compute, AI * Bandwidth)
cpu_performance = np.minimum(cpu_peak_compute, ai_axis * cpu_bandwidth)
hw_performance = np.minimum(hw_peak_compute, ai_axis * hw_bandwidth)

# Calculate exact performance limits for our specific kernel
cpu_kernel_perf = min(cpu_peak_compute, kernel_ai * cpu_bandwidth)
hw_kernel_perf = min(hw_peak_compute, kernel_ai * hw_bandwidth)

# 3. Create the Plot
plt.figure(figsize=(10, 6))

# Plot Rooflines
plt.plot(ai_axis, cpu_performance, label='Host CPU (2017 Mac)', color='blue', linewidth=2)
plt.plot(ai_axis, hw_performance, label='HDC Chiplet (SRAM)', color='green', linewidth=2)

# Plot Kernel Points
plt.plot(kernel_ai, cpu_kernel_perf, 'bo', markersize=10, label=f'SW Baseline ({cpu_kernel_perf:.2f} GOPS)')
plt.plot(kernel_ai, hw_kernel_perf, 'go', markersize=10, label=f'HW Accelerator ({hw_kernel_perf:.2f} GOPS)')

# 4. Formatting (Log-Log Scale, Labels, Grid)
plt.xscale('log')
plt.yscale('log')
plt.xlabel('Arithmetic Intensity (OPs/Byte)', fontsize=12)
plt.ylabel('Performance (GOPS)', fontsize=12)
plt.title('Roofline Model: HDC Binding Kernel (SW vs. Custom HW)', fontsize=14)
plt.grid(True, which="both", ls="--", alpha=0.5)
plt.legend(loc='upper left', fontsize=10)

# 5. Save the Image
output_path = '../codefest/cf02/profiling/roofline_project.png'
os.makedirs(os.path.dirname(output_path), exist_ok=True)
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"Roofline successfully generated and saved to {output_path}")