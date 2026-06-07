#!/usr/bin/env python3
"""Generate the M4 top-level block diagram for the AXI-Stream HDC Accelerator."""

from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

OUT = Path(__file__).parent / 'block_diagram.png'

fig, ax = plt.subplots(figsize=(12, 7))
ax.set_xlim(0, 16)
ax.set_ylim(0, 10)
ax.axis('off')

def box(x, y, w, h, label, color, fontsize=10, fontweight='normal'):
    p = FancyBboxPatch((x, y), w, h,
                       boxstyle="round,pad=0.1",
                       linewidth=1.5,
                       facecolor=color,
                       edgecolor='black')
    ax.add_patch(p)
    ax.text(x + w/2, y + h/2, label,
            ha='center', va='center',
            fontsize=fontsize, fontweight=fontweight)

def arrow(x1, y1, x2, y2, label=None, label_offset=(0, 0.2), color='black'):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2),
                                 arrowstyle='->',
                                 mutation_scale=18,
                                 color=color, linewidth=1.5))
    if label:
        mx, my = (x1+x2)/2 + label_offset[0], (y1+y2)/2 + label_offset[1]
        ax.text(mx, my, label, ha='center', va='center', fontsize=8,
                color=color, style='italic', fontweight='bold')

# Host CPU
box(0.2, 5.5, 2.8, 1.8, "Host CPU / DMA\nStreams 96-bit payloads:\nBase, Feat, Thresh, Opcode", '#FFE4B5')

# AXI-Stream Interface
box(4.2, 5.5, 3.2, 1.8, "AXI-Stream Interface\n(Flattened Pass-Through)\ns_axis_tdata [95:0]", '#C8E6C9', fontweight='bold')

# top.sv wrapper box
ax.text(8.0, 9.6, 'top.sv (HDC Accelerator)', fontsize=12, fontweight='bold', ha='center', style='italic')

# Compute Core Boundary
box(8.5, 2.0, 7.0, 6.8, "", '#F8F9FA')
ax.text(12.0, 8.4, 'Compute Core (compute_core.sv)\nOutput-Stationary Dataflow', fontsize=11, fontweight='bold', ha='center')

# FSM
box(9.2, 6.5, 5.6, 1.2, "5-Stage FSM\nOP_CLEAR, OP_ACCUM, OP_THRESH, OP_INFER, OP_READ_HD", '#E0F0FF')

# Memory blocks
box(9.2, 4.3, 2.6, 1.4, "accum_ram\nFlat 1D [319:0]\n(10-bit Precision)", '#FFCDD2', fontsize=9)
box(12.2, 4.3, 2.6, 1.4, "class_ram\n1-bit Quantized\n(Thresholded)", '#FFB347', fontsize=9)

# Adder Tree
box(9.2, 2.4, 5.6, 1.2, "32-Input Adder Tree\nComputes Hamming Distance", '#FFD89E', fontsize=9)

# Arrows
arrow(3.0, 6.4, 4.2, 6.4, "AXI-Stream", label_offset=(0, 0.2))
arrow(7.4, 6.4, 9.2, 6.4, "96-bit payload", label_offset=(0, 0.2))

# Internal FSM control arrows
arrow(10.5, 6.5, 10.5, 5.7, color='gray')
arrow(13.5, 6.5, 13.5, 5.7, color='gray')
arrow(10.5, 4.3, 10.5, 3.6, color='gray')
arrow(13.5, 4.3, 13.5, 3.6, color='gray')

# Output back to Host
arrow(12.0, 2.4, 12.0, 1.0, color='gray')
arrow(12.0, 1.0, 2.0, 1.0, "m_axis_tdata [95:0]\n(Returns 16-bit HD)", label_offset=(0, 0.3))
arrow(2.0, 1.0, 2.0, 5.5, color='gray')

# Title & Legend
ax.text(8, 10.2, 'M4 top.sv: 96-bit AXI-Stream HDC Accelerator Core', ha='center', fontsize=12, fontweight='bold')
ax.text(0.2, 0.8, "Legend:", fontsize=9, fontweight='bold')
ax.text(0.2, 0.4, "1024-Dimension Scaled Architecture | Post-PnR: 141.2 MHz (10ns constraint, +2.92ns slack)", fontsize=8)

plt.tight_layout()
plt.savefig(OUT, dpi=150, bbox_inches='tight')
plt.close()
print(f'Saved: {OUT}')