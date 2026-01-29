# Scripts pentru Cursul 18supp: Integrarea NPU în SO

## Conținut

### 1. `npu_check.sh`
Script Bash pentru verificarea prezenței și statusului NPU pe sistem.

**Verifică:**
- Dispozitive `/dev/accel/*` (Linux 6.2+)
- Driver Intel NPU (ivpu)
- Driver AMD XDNA
- Firmware Intel NPU
- Instalare OpenVINO
- Mesaje kernel relevante

**Utilizare:**
```bash
chmod +x npu_check.sh
./npu_check.sh
```

### 2. `npu_benchmark.py`
Script Python pentru benchmarking inferență pe diferite dispozitive.

**Testează:**
- CPU (ONNX Runtime)
- GPU CUDA (dacă disponibil)
- DirectML (Windows)
- Intel NPU (via OpenVINO)
- Alte dispozitive OpenVINO

**Cerințe:**
```bash
pip install openvino onnxruntime numpy
# Pentru GPU: pip install onnxruntime-gpu
```

**Utilizare:**
```bash
python3 npu_benchmark.py
```

## Output Exemplu

```
╔═══════════════════════════════════════════════════════════════════╗
║            NPU vs CPU vs GPU Inference Benchmark                  ║
╚═══════════════════════════════════════════════════════════════════╝

================================================================================
Provider                  Mean (ms)    P50 (ms)     P99 (ms)     Std       
================================================================================
CPUExecutionProvider      45.23        44.89        52.34        3.21      
OpenVINO-CPU              38.45        37.92        45.67        2.89      
OpenVINO-NPU              8.34         8.12         9.45         0.67      
================================================================================

🏆 Fastest: OpenVINO-NPU (8.34 ms)
```
