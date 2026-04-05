# HDC Accelerator Block Diagram

```mermaid
flowchart TD
    subgraph Host Microcontroller
        CPU[Host CPU / Feature Extractor]
        SENSOR[Streaming Sensor Data]
    end

    subgraph Standard Interface
        SPI((SPI / AXI4-Lite Bus))
    end

    subgraph Custom Co-Processor Chiplet
        CTRL[FSM Controller]
        
        subgraph On-Chip Memory
            IMEM[Item Memory SRAM - Base Vectors]
            AMEM[Associative Memory - Class Vectors]
        end
        
        subgraph HDC Compute Engine
            BIND[Binding Unit - XOR Gates]
            BUNDLE[Bundling Unit - Bitwise Accumulator]
            SIM[Similarity Check - Hamming Distance]
        end
    end

    SENSOR --> CPU
    CPU -- "Encoded Features" --> SPI
    SPI <--> CTRL
    
    CTRL --> IMEM
    
    IMEM -- "10,000-bit vectors" --> BIND
    BIND --> BUNDLE
    BUNDLE --> SIM
    AMEM --> SIM
    
    SIM -- "Predicted Class ID" --> CTRL