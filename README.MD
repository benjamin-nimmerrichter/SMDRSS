# SMDRSS: Low-Cost MATLAB Framework for Electroacoustic Measurements

**SMDRSS** stands for **System for Measuring Directional Responses of Sound Sources**. This is an open-source, MATLAB-based framework designed for flexible laboratory use with standard audio hardware. It provides a modular software architecture enabling reproducible acoustic measurements using common ASIO-compatible audio interfaces and measurement microphones.

## Features

- **Dual Acquisition Modes:** Supports both synchronous measurements (known excitation signal, e.g., speakers) and asynchronous measurements of independent acoustic sources (e.g., instruments).
- **Automated Signal Quality Control:** Includes built-in verification for Signal-to-Noise Ratio (SNR), clipping detection, and robust onset-detection algorithms employing circular-buffer hysteresis.
- **Comprehensive Analysis Modules:**
  - Frequency Response (Transfer Function Estimation)
  - Magnitude Spectrum
  - Fractional-Octave Processing (1/3-octave bands)
  - Directional Response (2D Polar and 3D Spherical Plots)
  - Impulse Response (Time Domain via IFFT/Swept-Sine)
- **Calibration:** Supports absolute SPL calibration using acoustic calibrators or relative calibration for microphone arrays.
- **Compliance:** Measurement geometries adhere to AES56 recommendations.

## Hardware Requirements

The system operates with standard ASIO interfaces and supports user-defined measurement geometries.

- **Audio Interface:** Any ASIO-compatible interface (e.g., RME, Focusrite).
- **Microphones:** Supports single microphones or arrays (limited by channel count). Recommended: Audix TM-1 or Behringer ECM8000.
- **Sound Source:** Compatible with speakers and or acoustic instruments.

## Installation and Usage

### Running the Application

To run the program, you can either:

1. Start the `SMDRSS` shortcut in the main folder (MATLAB App Designer).
2. Open the `SMDRSS` file directly from the `scripts` folder for script-based execution.

### File Structure

- **`config_files`**: Contains configurations saved during measurement sessions.
- **`measurement_files`**: Stores measured data and analysis results.
- **`measurement_tones`**: Contains generated test tones (e.g., sweeps, calibration tones).
- **`scripts`**: Contains all MATLAB scripts for processing and analysis.
- **`test_files`**: Development scripts intended for debugging; may be deprecated in future versions.

## Configuration Data Structure

The main access variable is `config`. Key parameters include:

- `.array_dir`: Array direction (Static, Horizontal, Vertical).
- `.n_meas`: Number of measurements per pass.
- `.meas_center`: Center of measurement geometry.
- `.meas_angle`: Measurement angle sector.
- `.has_audio_in`: Boolean flag indicating if the source accepts input signals (Synchronous mode).
- `.start_ch`: Start channel for microphone mapping.
- `.passes`: Total number of measurement passes.
- `.angles(m)`: Azimuth/Elevation angles for pass `m`.
- `.calib_freq`: Calibration frequency for tone detection.
- `.mic(k)`: Microphone configuration for index `k`.
  - `.az(p)`: Initial azimuth angle for pass `p`.
  - `.el(p)`: Initial elevation angle for pass `p`.
  - `.chan`: Microphone channel mapping.

## Measurement Data Structure

The main access variable is `meas`, where `n` represents the number of measurement passes.

- `.type`: Linked to `config.has_audio_in` ('sync' or 'async').
- `.atten`: Attenuation setting.
- `.headroom`: Headroom for clipping detection algorithm.
- `.num_clips`: Threshold for clipping detection (samples exceeding -3dBFS).
- `.min_SNR`: Minimal allowed Signal-to-Noise Ratio (default ≥20 dB).
- `.dev`: Device settings structure.
  - `.fs`: Sampling rate.
  - `.sel_dev`: Selected audio device.
  - `.n_bits`: Bit depth.
  - `.buffer_sz`: Circular buffer size.

### Data Access Example

To access the signal from Microphone 3, Measurement 4, Pass 5:

```matlab
app.meas(5).mic(3).point(4).signal
```

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
