import torch
from torchvision.models import resnet18
from torchinfo import summary

# 1. Load the ResNet-18 model architecture
model = resnet18()

# 2. Run the torchinfo profiler
# We specifically ask for "mult_adds" so you can answer Task 3
stats = summary(
    model, 
    input_size=(1, 3, 224, 224), 
    col_names=["input_size", "output_size", "num_params", "mult_adds"],
    verbose=0
)

# 3. Print the massive table to the console
print(stats)