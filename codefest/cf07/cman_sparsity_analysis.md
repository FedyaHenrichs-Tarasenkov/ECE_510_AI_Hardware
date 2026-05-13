# CMAN: Sparsity Breakeven Analysis

## 1. Expressions and Values ($N = 512$, $s = \text{sparsity}$)

**(a) Dense MVM compute (FLOPs):** * Expression: $2N^2$ (assuming 1 MAC = 2 FLOPs)
* Value: $2(512)^2 = \mathbf{524,288 \text{ FLOPs}}$

**(b) Dense memory bytes:** * Expression: $4N^2$ 
* Value: $4(512)^2 = \mathbf{1,048,576 \text{ bytes}}$

**(c) Sparse compute (FLOPs):** * Expression: $2N^2(1 - s)$
* Value: $2(512)^2(1 - s) = \mathbf{524,288(1 - s) \text{ FLOPs}}$

**(d) Sparse memory bytes:** * Expression: Values ($4N^2(1 - s)$) + Col Indices ($4N^2(1 - s)$) + Row Pointers ($4(N + 1)$) 
  * Total Expression: $8N^2(1 - s) + 4(N + 1)$
* Value: $8(512)^2(1 - s) + 4(512 + 1) = \mathbf{2,097,152(1 - s) + 2,052 \text{ bytes}}$

## 2. Theoretical Speedup
* **FLOPs Ratio (Speedup):** $\frac{\text{Dense FLOPs}}{\text{Sparse FLOPs}} = \frac{2N^2}{2N^2(1-s)} = \frac{1}{1 - s}$
* **For a 2x Speedup:** $2 = \frac{1}{1 - s} \implies 1 - s = 0.5 \implies \mathbf{s = 0.5}$

## 3. Memory Breakeven Sparsity
The breakeven occurs when Sparse Memory = Dense Memory:
$8N^2(1 - s) + 4(N + 1) = 4N^2$

Divide the equation by 4:
$2N^2(1 - s) + (N + 1) = N^2$

Expand and isolate $s$:
$2N^2 - 2N^2s + N + 1 = N^2$
$2N^2s = N^2 + N + 1$
$\mathbf{s = \frac{N^2 + N + 1}{2N^2}}$

For $N = 512$:
$s = \frac{512^2 + 512 + 1}{2(512^2)} = \frac{262144 + 512 + 1}{524288} = \frac{262657}{524288} \approx \mathbf{0.50097}$

Above $s \approx 50.1\%$, the CSR format uses less memory than dense storage.

## 4. End-to-End Speedup (Memory-Bound at $s=0.9$)
For a strictly memory-bandwidth-limited system, execution time scales directly with the amount of data transferred. The bandwidth ($320\text{ GB/s}$) cancels out when calculating the ratio.
* **Dense Bytes:** $4(512)^2 = \mathbf{1,048,576\text{ bytes}}$
* **Sparse Bytes:** $8(512)^2(1 - 0.9) + 4(512 + 1) = 209,715.2 + 2,052 = \mathbf{211,767.2\text{ bytes}}$
* **End-to-End Speedup:** $\frac{\text{Dense Bytes}}{\text{Sparse Bytes}} = \frac{1,048,576}{211,767.2} \approx \mathbf{4.95\times}$