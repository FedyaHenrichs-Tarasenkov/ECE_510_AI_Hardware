### ResNet-18 Top 5 MAC Layers

| Rank | Layer Name   | MACs        | Parameters |
|------|--------------|-------------|------------|
| 1    | Conv2d: 1-1  | 118,013,952 | 9,408      |
| 2    | Conv2d: 3-1  | 115,605,504 | 36,864     |
| 3    | Conv2d: 3-4  | 115,605,504 | 36,864     |
| 4    | Conv2d: 3-7  | 115,605,504 | 36,864     |
| 5    | Conv2d: 3-10 | 115,605,504 | 36,864     |

### Arithmetic Intensity Calculation for most intense MAC layer: Conv2d: 1-1

### Total Weight Memory
Weight Bytes = Parameters x 4B = 9,408 x 4B = 37,632B

### Total Activation Memory
Input Elements = 1 x 3 x 224 x 224 = 150,528
Output Elements = 1 x 64 x 112 x 112 = 802,816
Activation Bytes = Total Activiation Elements x 4B = 953,344 x 4B = 3,813,376B

### Final Calculation
(2 x Total MACs) / (Weight bytes + Activation bytes) 
= (2 x 118,013,952) / (37,632B + 3,813,376B) = 61.29 FLOPs/B