import matplotlib.pyplot as plt
from vcdvcd import VCDVCD

def plot_waveform():
    print("Parsing final_waveform.vcd...")
    vcd = VCDVCD('final_waveform.vcd')

    # Extract the signal data from the VCD hierarchy
    clk = vcd['tb_top.clk']
    s_valid = vcd['tb_top.s_tvalid']
    s_data = vcd['tb_top.s_tdata[95:0]']
    m_valid = vcd['tb_top.m_tvalid']
    m_data = vcd['tb_top.m_tdata[95:0]']

    # Setup the plot
    fig, axs = plt.subplots(5, 1, figsize=(14, 8), sharex=True)
    fig.suptitle('HDC Accelerator AXI-Stream End-to-End Simulation', fontsize=16, fontweight='bold')

    signals = [
        (clk, 'clk', 'green'),
        (s_valid, 's_axis_tvalid', 'blue'),
        (s_data, 's_axis_tdata', 'black'),
        (m_valid, 'm_axis_tvalid', 'red'),
        (m_data, 'm_axis_tdata', 'purple')
    ]

    # Plot each signal as a step function
    for i, (sig, name, color) in enumerate(signals):
        times = [tv[0] for tv in sig.tv]
        
        if 'data' in name:
            values = [1 if '1' in str(tv[1]) or '0' in str(tv[1]) else 0 for tv in sig.tv]
        else:
            values = [int(tv[1]) if tv[1] in ('0', '1') else 0 for tv in sig.tv]

        axs[i].step(times, values, where='post', color=color, linewidth=1.5)
        axs[i].set_ylabel(name, rotation=0, labelpad=50, ha='right', fontweight='bold', fontsize=11)
        axs[i].set_yticks([]) 
        axs[i].grid(True, linestyle='--', alpha=0.5)
        axs[i].set_ylim(-0.2, 1.4) # Add breathing room for text

    # ==========================================
    # AUTOMATED ANNOTATIONS
    # ==========================================
    
    # 1. Label the Three Test Phases across the top of the s_axis_tvalid plot
    axs[1].text(0.65e6, 1.15, "TEST 1: Standard Inference", ha='center', fontweight='bold', color='blue', fontsize=10)
    axs[1].text(1.95e6, 1.15, "TEST 2: Perfect Match", ha='center', fontweight='bold', color='blue', fontsize=10)
    axs[1].text(3.25e6, 1.15, "TEST 3: Total Mismatch", ha='center', fontweight='bold', color='blue', fontsize=10)

    # 2. Annotate the m_axis_tdata output values with pointing arrows
    axs[4].annotate('Output: 512', xy=(1.33e6, 1.0), xytext=(1.33e6, 0.4),
                    ha='right', fontweight='bold', color='purple',
                    arrowprops=dict(facecolor='purple', arrowstyle='->', lw=1.5))
                    
    axs[4].annotate('Output: 0', xy=(2.64e6, 1.0), xytext=(2.64e6, 0.4),
                    ha='right', fontweight='bold', color='purple',
                    arrowprops=dict(facecolor='purple', arrowstyle='->', lw=1.5))
                    
    axs[4].annotate('Output: 1024', xy=(3.94e6, 1.0), xytext=(3.94e6, 0.4),
                    ha='right', fontweight='bold', color='purple',
                    arrowprops=dict(facecolor='purple', arrowstyle='->', lw=1.5))

    axs[-1].set_xlabel("Time (ps)", fontweight='bold', fontsize=12)
    plt.tight_layout()
    
    # Save the output directly to the figures folder
    output_path = '../report/figures/final_waveform.png'
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Success! Annotated plot saved to {output_path}")

if __name__ == "__main__":
    plot_waveform()