#!/usr/bin/env python3
"""Generate the M4 Roofline Plot for the HDC Accelerator vs M1 Software Baseline."""

from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

OUT = Path(__file__).parent / 'roofline_final.png'

fig, ax = plt.subplots(figsize=(10, 6), dpi=150)

# Roofline Parameters
peak_gops = 100.0  # Assumed theoretical peak compute for graph bounds
mem_bw = 12.5      # Assumed memory bandwidth GB/s (giving an 8.0 ridge point)
ridge_point = peak_gops / mem_bw

# Generate axes
ai = np.logspace(-1, 3, 500)
perf = np.minimum(peak_gops, mem_bw * ai)

# Plot the roofline boundaries
ax.plot(ai, perf, linewidth=3, label=f'Theoretical Compute Roof ({peak_gops} GOPS)', color='#2b6A99')
ax.axvline(x=ridge_point, color='gray', linestyle=':', alpha=0.5, label=f'Ridge Point ({ridge_point} BOPs/Byte)')

# Define the M1 Baseline and M4 Accelerator points
m1_ai = 1.0
m1_gops = 2.65
m4_ai = 4.0
m4_gops = 4.51

# Plot points
ax.scatter(m1_ai, m1_gops, color='#E74C3C', s=250, edgecolor='black', zorder=5, linewidth=2, label='M1 SW Baseline (CPU) $\\rightarrow$ 2.65 GOPS')
ax.scatter(m4_ai, m4_gops, color='#9B59B6', s=350, marker='*', edgecolor='black', zorder=5, linewidth=2, label='M4 Accelerator (Sky130) $\\rightarrow$ 4.51 GOPS')

# Draw a dashed line showing the transition
ax.plot([m1_ai, m4_ai], [m1_gops, m4_gops], color='gray', linestyle='--', alpha=0.5, linewidth=1)

# Annotations
ax.text(m4_ai + 0.5, m4_gops - 0.5, 
        'M4 HDC Accelerator\n4.51 GOPS\n141.2 MHz Post-PnR\n300x Energy Efficiency', 
        color='#7D3C98', fontweight='bold', fontsize=9, va='top')

ax.text(m1_ai - 0.1, m1_gops, 
        'M1 SW Baseline\n2.65 GOPS\nAI = 1.0', 
        color='black', fontsize=9, ha='right', va='center')

# Graph Formatting
ax.set_xscale('log')
ax.set_yscale('log')
ax.set_xlim(0.1, 100)
ax.set_ylim(0.1, 1000)
ax.set_xlabel('Arithmetic Intensity (BOPs/byte, log scale)')
ax.set_ylabel('Performance (GOPS, log scale)')
ax.set_title('M4 Final Roofline: HDC Edge Accelerator vs M1 SW Baseline', fontweight='bold')
ax.grid(True, which="both", ls="--", alpha=0.3)
ax.legend(loc='lower right')

plt.tight_layout()
plt.savefig(OUT)
plt.close()
print(f'Saved: {OUT}')