### Codefest 4: CMAN Quantization Calculations

**Part 1: Original Matrix and Maximum Absolute Value**
* Original weights $W$:
    | 0.85 | -1.20 | 0.34 | 2.10 |
    | -0.07 | 0.91 | -1.88 | 0.12 |
    | 1.55 | 0.03 | -0.44 | -2.31 |
    | -0.18 | 1.03 | 0.77 | 0.55 |
* **$\max(|W|)$** = **2.31**

**Part 2: Quantization Scale ($S$)**
* Formula: $S = \max(|W|) / 127$
* **$S$** = $2.31 / 127$ = **0.01818897638**

**Part 3 & 4: Quantization, Dequantization, and Error**
* **Quantized Matrix ($W_q = \text{round}(W / S)$)**:
    | 47 | -66 | 19 | 115 |
    | -4 | 50 | -103 | 7 |
    | 85 | 2 | -24 | -127 |
    | -10 | 57 | 42 | 30 |

* **Dequantized Matrix ($W_{deq} = W_q \times S$)**:
    | 0.85488 | -1.20047 | 0.34559 | 2.09173 |
    | -0.07276 | 0.90945 | -1.87346 | 0.12732 |
    | 1.54606 | 0.03638 | -0.43654 | -2.31000 |
    | -0.18189 | 1.03677 | 0.76394 | 0.54567 |

* **Error Metrics**:
    * **Largest Error:** **0.008267**
    * **Mean Absolute Error (MAE):** **0.004326**

---

**Part 5: The "Bad Scale" Experiment ($S_{bad} = 0.01$)**
* **Quantized Matrix ($W_{q\_bad} = \max(-128, \min(127, \text{round}(W / 0.01)))$)**:
    | 85 | -120 | 34 | 127 |
    | -7 | 91 | -128 | 12 |
    | 127 | 3 | -44 | -128 |
    | -18 | 103 | 77 | 55 |

* **Dequantized Matrix ($W_{deq\_bad} = W_{q\_bad} \times 0.01$)**:
    | 0.85 | -1.20 | 0.34 | 1.27 |
    | -0.07 | 0.91 | -1.28 | 0.12 |
    | 1.27 | 0.03 | -0.44 | -1.28 |
    | -0.18 | 1.03 | 0.77 | 0.55 |

* **Bad Error Metrics**:
    * **Largest Bad Error:** **1.03**
    * **Mean Absolute Error ($MAE_{bad}$):** **0.17125**

    Using an artificially small quantization scale causes the network's highest-magnitude weights to hit the physical 8-bit integer limits, resulting in severe clipping that permanently destroys the model's precision and drastically spikes the Mean Absolute Error.