import matplotlib.pyplot as plt
import numpy as np
import os

# 1. Real Hardware Specifications
# Source: Intel Core i5-7360U Ark Spec Sheet (Base 2.3 GHz, Dual Core)
cpu_peak_compute = 147.2  # GFLOP/s (Theoretical Peak FP32)
cpu_bandwidth = 34.1      # GB/s (Max Memory Bandwidth)
cpu_ridge = cpu_peak_compute / cpu_bandwidth

# Custom HDC Chiplet (Hypothetical HW)
hw_peak_compute = 2000.0  # GFLOP/s equivalent
hw_bandwidth = 1000.0     # GB/s (On-chip SRAM)
hw_ridge = hw_peak_compute / hw_bandwidth

# HDC Kernel AI 
kernel_ai = 0.0833        # FLOP/Byte

# 2. Generate Data Points
ai_axis = np.logspace(-2, 2, 500)
cpu_performance = np.minimum(cpu_peak_compute, ai_axis * cpu_bandwidth)
hw_performance = np.minimum(hw_peak_compute, ai_axis * hw_bandwidth)

cpu_kernel_perf = min(cpu_peak_compute, kernel_ai * cpu_bandwidth)
hw_kernel_perf = min(hw_peak_compute, kernel_ai * hw_bandwidth)

# 3. Create the Plot
plt.figure(figsize=(12, 8))

# Plot Rooflines
plt.plot(ai_axis, cpu_performance, label='Host CPU (Intel i5-7360U)', color='blue', linewidth=2)
plt.plot(ai_axis, hw_performance, label='Target HW (HDC Chiplet + SRAM)', color='green', linewidth=2)

# Plot & Label Ridge Points (Checklist Requirement)
plt.plot(cpu_ridge, cpu_peak_compute, 'b*', markersize=12)
plt.annotate(f'CPU Ridge Point\n({cpu_ridge:.2f} FLOP/B)', xy=(cpu_ridge, cpu_peak_compute), xytext=(cpu_ridge*1.2, cpu_peak_compute*0.5), color='blue')

plt.plot(hw_ridge, hw_peak_compute, 'g*', markersize=12)
plt.annotate(f'HW Ridge Point\n({hw_ridge:.2f} FLOP/B)', xy=(hw_ridge, hw_peak_compute), xytext=(hw_ridge*1.2, hw_peak_compute*0.5), color='green')

# Plot & Label Kernel Points (Checklist Requirement)
plt.plot(kernel_ai, cpu_kernel_perf, 'bo', markersize=10)
plt.annotate(f'SW Kernel Baseline\n({cpu_kernel_perf:.2f} GFLOP/s)', xy=(kernel_ai, cpu_kernel_perf), xytext=(kernel_ai*0.3, cpu_kernel_perf*1.5), color='blue')

plt.plot(kernel_ai, hw_kernel_perf, 'go', markersize=10)
plt.annotate(f'HW Kernel Target\n({hw_kernel_perf:.2f} GFLOP/s)', xy=(kernel_ai, hw_kernel_perf), xytext=(kernel_ai*0.3, hw_kernel_perf*1.5), color='green')

# 4. Formatting (Checklist Requirements)
plt.xscale('log')
plt.yscale('log')
plt.xlabel('Arithmetic Intensity (FLOP/byte)', fontsize=12)
plt.ylabel('Performance (GFLOP/s)', fontsize=12)
plt.title('Roofline Model: HDC Binding Kernel', fontsize=14, fontweight='bold')

# Source Citation (Checklist Requirement)
plt.figtext(0.15, 0.02, "Source: Intel Core i5-7360U Processor Specifications (ark.intel.com)", fontsize=10, style='italic')

plt.grid(True, which="both", ls="--", alpha=0.5)
plt.legend(loc='upper left', fontsize=10)

# 5. Save the Image
output_path = '../codefest/cf02/profiling/roofline_project.png'
os.makedirs(os.path.dirname(output_path), exist_ok=True)
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"Updated Roofline successfully generated and saved to {output_path}")