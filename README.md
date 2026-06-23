# Software-Defined Universal IC Tester & DAQ 🚀

![MATLAB](https://img.shields.io/badge/MATLAB-Data_Processing-blue.svg)
![Arduino](https://img.shields.io/badge/Arduino-Hardware_Execution-00979C.svg)
![Hardware](https://img.shields.io/badge/Hardware-Mixed_Signal-red.svg)

A low-cost, software-defined Hardware-in-the-Loop (HIL) diagnostic platform capable of performing both digital logic verification and complex analog parametric analysis without manual hardware rewiring.

## 📖 Project Overview
Commercial IC testers are traditionally constrained by rigid, hardware-locked architectures. This project democratizes advanced hardware diagnostics by partitioning the computational workload between a high-level PC interface (MATLAB) and an embedded execution layer (Arduino Mega). 

By utilizing a dynamic switching matrix connected to a Universal ZIF socket, power, ground, and test signals are routed algorithmically. The system serves as a high-speed Data Acquisition (DAQ) node, streaming raw analog telemetry to a PC for Digital Signal Processing (DSP) and automated System Identification.

### ✨ Key Features
* **Algorithmic Hardware Routing:** A solid-state switching matrix that dynamically configures pinouts for diverse IC families (e.g., 74xx, 40xx, Linear Op-Amps) via serial commands.
* **High-Speed DAQ Pipeline:** Digitizes continuous analog waveforms utilizing external 16-bit ADCs and streams raw telemetry for PC-side analysis.
* **DSP & Parametric Extraction:** MATLAB-based algorithms to automatically extract Voltage Gain ($A_v$), DC bias offsets, and Common-Mode Rejection Ratios (CMRR).
* **Automated System Identification:** Calculates and plots empirical Transfer Functions, $H(s)$, and harmonic distortion profiles (FFT) directly from acquired time-domain data.

---

## 🏗️ System Architecture

### 1. The Execution Layer (Hardware)
* **Microcontroller:** Arduino Mega 2560 acts as the high-speed command parser and signal injector.
* **Switching Matrix:** Digitally controlled analog multiplexers route VCC, GND, and I/O dynamically.
* **Analog Bus:** High-resolution ADC integration for continuous waveform sampling.

### 2. The Evaluation Layer (Software)
* **Digital Domain:** Executes discrete boolean vector injection for exhaustive truth-table verification and granular fault localization.
* **Analog Domain:** Processes the raw DAQ stream to generate Bode plots, evaluate spectral purity, and model silicon behavior.

---

## 📊 Empirical Results & DSP Analysis
*Included in this repository are empirical test datasets derived from a BJT Common-Emitter Amplifier operating at 50Hz.*

When the raw `.CSV` telemetry is passed through the MATLAB pipeline, the system successfully:
1. Calculates a linear Voltage Gain of **82.14 V/V** (38.29 dB).
2. Isolates the precise output Q-Point (DC Offset) at **1.05 V**.
3. Generates a clean FFT distortion profile, verifying linear amplification.
4. Estimates a continuous-time $s$-domain Transfer Function based on phase-shift dynamics.

*(Recommend adding a screenshot of your MATLAB Time-Domain and FFT plots here!)*

---

## 📂 Repository Structure
```text
├── /Hardware_Design           # KiCad/Proteus schematics for the switching matrix
├── /Arduino_Firmware          # C++ code for DAQ streaming and matrix control
├── /MATLAB_DSP_Pipeline       # Scripts for signal processing and System ID
│   ├── IC_Tester_DSP.m        # Main analysis script
│   └── /Sample_Data           # Raw 50Hz Oscilloscope/DAQ CSV files for testing
├── /Documentation             # PDF of the formal project thesis/report
└── README.md
