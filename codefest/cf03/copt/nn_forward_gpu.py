import torch
import torch.nn as nn
import sys

def main():
    # 1. Detect GPU and exit if not found
    if not torch.cuda.is_available():
        print("Error: No CUDA GPU found. Exiting.")
        sys.exit(1)
        
    device = torch.device("cuda")
    print(f"Device found: {torch.cuda.get_device_name(device)}")

    # 2. Define the network (4 -> 5 with ReLU -> 1) and move to GPU
    model = nn.Sequential(
        nn.Linear(4, 5),
        nn.ReLU(),
        nn.Linear(5, 1)
    )
    model.to(device)
    print("Network successfully built and moved to GPU.")

    # 3. Generate random input batch [16, 4], move to GPU, and run forward pass
    inputs = torch.randn(16, 4).to(device)
    print(f"Input tensor generated with shape: {list(inputs.shape)} on {inputs.device}")
    
    # Run forward pass
    output = model(inputs)
    
    # Verify output shape and device placement
    print(f"Output tensor shape: {list(output.shape)} (Expected: [16, 1])")
    print(f"Output is on device: {output.device}")

if __name__ == "__main__":
    main()
