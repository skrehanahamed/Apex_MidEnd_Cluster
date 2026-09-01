# Hyundai Exter AMT Digital Instrument Cluster HMI

<img width="2286" height="816" alt="image" src="https://github.com/user-attachments/assets/c62203a5-bfb2-44a0-aba9-de9c7c5c85c7" />

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Release_Date-September_2,_2026-orange.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Qt-6.6+-41CD52.svg?style=for-the-badge&logo=Qt&logoColor=white" />
  <img src="https://img.shields.io/badge/C%2B%2B-20-00599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white" />
  <img src="https://img.shields.io/badge/CMake-3.20+-064F8C.svg?style=for-the-badge&logo=cmake&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-macOS%20|%20Linux%20|%20Windows-lightgrey.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" />
</p>

A production-grade, photorealistic Automotive Digital Instrument Cluster HMI for the Hyundai Exter AMT (Smart Auto), engineered using Qt 6 (QML / Qt Quick) and modern C++20. Features authentic Hyundai typography, 1:1 OEM telltale layouts, dynamic multi-page trip computing, full 4-wheel TPMS simulation, an autonomous driving engine, standby power management with door-wake reactivity, and an infotainment media bridge.

---

## Release Notes - Version 2.0.0 (Updated: September 2, 2026)

### 1. OEM Infotainment & Media Popup Banner (Top-Line Emergence & Marquee)

<p align="center">
  <img src="assets/features/usb midea.png" alt="OEM Infotainment Media Popup Banner" width="95%" />
</p>

- Top-Line Emergence: The media banner glides out smoothly directly from inside the top white TFT divider line (520ms entrance with OutCubic easing) rather than dropping from outside the housing.
- 5-Second Auto-Dismiss: Stays visible for 5 seconds upon starting or switching tracks, then glides back up into the top line.
- Every-Song Re-Triggering: Switching songs always re-triggers the slide-out entrance and resets the text position to start.
- Marquee Text Scrolling:
  - Short track titles stay centered.
  - Long song and artist titles hold for 1.2 seconds at the start, glide smoothly horizontally to reveal the full title, hold for 1.2 seconds at the end, and glide back in a continuous loop.
- Official OEM Source Icons:
  - USB: Authentic USB drive with metal connector and engraved USB trident.
  - Apple CarPlay: Official Apple CarPlay dashboard touchscreen with dock and app grid.
  - Bluetooth Audio: Official high-definition Bluetooth symbol.
  - Android Auto: Official Android Auto chevron arrow.
  - FM Radio: Radio broadcast icon.

---

### 2. Full 4-Wheel Interactive TPMS Control Station

<p align="center">
  <img src="assets/features/tpms .png" alt="TPMS 4-Wheel Pressure Monitoring" width="95%" />
</p>

- 2x2 Interactive Wheel Grid in ECU Simulator:
  - Dedicated cards for Front-Left (FL), Front-Right (FR), Rear-Left (RL), and Rear-Right (RR) tyres.
  - Live Status Readout: Color-coded in Green (OK >= 32 PSI), Yellow/Amber (Low 26-31 PSI), and Red (Flat/Puncture < 26 PSI).
  - Steppers: Fine-tune each tyre pressure in 1 PSI increments.
  - Quick One-Touch Presets: Low 24, Flat 16, and OK 35 per tyre.
- Master Calibration & Unit Switcher:
  - Calibrated vs Drive to Display modes.
  - Live unit conversion between psi, kPa, and bar across cluster and simulator.
- Center Vehicle Diagram Reaction: Under-inflated tyres pulse with authentic amber/red glowing pills, triggering the cluster TPMS telltale and amber TFT accent lines.

---

### 3. Standby Ignition-OFF Mode with Door-Wake Reactivity

<p align="center">
  <img src="assets/features/igntion off door activity.png" alt="Standby Ignition-OFF Door Wake" width="95%" />
</p>

- State 5 (Ignition OFF / Standby):
  - When all doors are closed, the entire instrument cluster is 100% pitch black (total dark, zero dials, zero background glow).
- Door-Wake Reactivity:
  - Opening any door, bonnet, or trunk instantly wakes the central TFT display.
  - Displays pure crisp white curved top and bottom divider lines, the large centered vehicle animation showing open door swings and blinking red hazard hoods, and ONLY the Odometer at the bottom right (temperature, gear, and DTE headers remain hidden).
  - Closing all doors smoothly fades the cluster back to 100% total darkness.

---

### 4. Pixel-Locked Zero-Movement Car Door Animation & Hazard Glows

<p align="center">
  <img src="assets/features/all door open with green theme .png" alt="All Doors Open with Green Theme" width="95%" />
</p>

- Zero-Drift Pixel Lock: All 19 car door animation frames are mathematically normalized against the base chassis (0.000 pixel drift). When doors open or close, the chassis, roof, windshield, and wheels remain completely motionless — only the door flaps physically swing outward.
- Contoured Bonnet & Trunk Hazards: Photorealistic red hazard glow overlays following the exact vehicle body stamping lines, pulsing at a 400ms cadence.

---

### 5. Autonomous Dynamic Driving Simulation Engine

<p align="center">
  <img src="assets/features/red theme with speed.png" alt="Autonomous Dynamic Driving Simulation" width="95%" />
</p>

- Multi-Phase Driving Cycle (approx. 60 seconds realistic highway/city loop):
  - Phase 1: City Start & Acceleration (0 to 45 km/h) with automatic gear shifting D1 to D2 to D3.
  - Phase 2: Left Lane Change with automatic Left Turn Signal (3s flashing).
  - Phase 3: Highway Ramp Acceleration (55 to 105 km/h) through D4 to D5 with matching RPM powerband curves.
  - Phase 4: Highway Cruise Control locked at 100 km/h with green CRUISE telltale.
  - Phase 5: Right Lane Exit with automatic Right Turn Signal (3s flashing).
  - Phase 6: Deceleration / Coasting (80 to 0 km/h) with instant fuel economy maxing out at 30 km/L.
  - Phase 7: Traffic Light Idle at 0 km/h with idle RPM (0.8 x1000 RPM).
- Live Telemetry Synchronization: Odometer, trip distance, trip time, and average economy continuously update in real-time.

---

### 6. OEM Warning Telltale Realignment
- Swapped Master Warning to Far-Left (mid-height beside speedometer).
- Swapped Bulb Fault to Bottom-Left (near lower gauge curved line).
- Aligned Smart Key alert triggers into a clean 2x2 grid with full-width dismiss bar.

---

## Feature Gallery

<p align="center">
  <img src="assets/features/green theme .png" alt="Emerald Green Cluster Theme" width="48%" />
  <img src="assets/features/red theme .png" alt="Crimson Red Cluster Theme" width="48%" />
</p>

<p align="center">
  <img src="assets/features/normal withh gear and all telltale .png" alt="Cluster Gauges and Telltales" width="48%" />
  <img src="assets/features/all telltale on in red theme .png" alt="Telltale Verification in Red Theme" width="48%" />
</p>

<p align="center">
  <img src="assets/features/press start buttin .png" alt="Smart Key Press Start Button Prompt" width="48%" />
  <img src="assets/features/key issue .png" alt="Smart Key Not Detected Alert" width="48%" />
</p>

<p align="center">
  <img src="assets/features/system check.png" alt="Startup Diagnostic System Check Sweep" width="48%" />
  <img src="assets/features/good bye screen.png" alt="Goodbye Shutdown Summary Screen" width="48%" />
</p>

<p align="center">
  <img src="assets/features/lines.png" alt="Curved Digital Gauge Lines and Cluster Architecture" width="95%" />
</p>

---

## System Architecture

```mermaid
graph TD
    subgraph "Core C++ Engine (Qt 6 / C++20)"
        MAIN["main.cpp<br>QGuiApplication & QQmlApplicationEngine"]
        CTRL["ClusterController (QObject Singleton)<br>CAN / ECU Telemetry, Timers & Power Engine"]
    end

    subgraph "Central TFT Display (4.2-inch MFD)"
        CENTER["CenterTripDisplay.qml"]
        MEDIA["MediaPopupBanner.qml<br>(Top-Line Emergence & Marquee)"]
        TPMS_VIEW["TpmsDisplayView.qml<br>(4-Wheel Graphic & Glowing Pills)"]
        SETTINGS["UserSettingsView.qml<br>(Hierarchical OEM Menus)"]
        ECO["InstantEcoGauge.qml<br>(3D Extruded Glow Gauge)"]
        STARTUP["StartupAnimationView.qml<br>(Welcome Light Wave)"]
        CHECK["VehicleCheckView.qml<br>(Self-Diagnostic Sweep)"]
        GOODBYE["GoodbyeView.qml<br>(Trip Summary & Shutdown)"]
    end

    subgraph "Digital Gauges & Telltales"
        SPEED["SpeedDisplay.qml<br>(7-Segment Speed & Arc Bars)"]
        RPM["RpmDisplay.qml<br>(7-Segment RPM & Torque Curve)"]
        BEZEL["BlueFrame.qml / ClusterUnit.qml<br>(Curved Bezel, Telltales & Master Warnings)"]
    end

    subgraph "ECU Simulation & Test Bench"
        ECU["EcuSimulatorPanel.qml<br>(Media Player, 4-Wheel TPMS, Auto-Drive, Smart Key)"]
    end

    MAIN --> CTRL
    CTRL --> CENTER
    CTRL --> SPEED
    CTRL --> RPM
    CTRL --> BEZEL
    CTRL <--> ECU

    CENTER --> MEDIA
    CENTER --> TPMS_VIEW
    CENTER --> SETTINGS
    CENTER --> ECO
    CENTER --> STARTUP
    CENTER --> CHECK
    CENTER --> GOODBYE
```

---

## Controls & Steering Wheel Switches

You can operate the cluster using either the ECU Simulator Bench ([F12] or [Tab]) or keyboard shortcuts:

| Steering Switch | Keyboard Key | Action |
| :--- | :--- | :--- |
| INFO / TAB | [ I ] | Cycle between Trip Computer, User Settings, and TPMS tabs |
| UP | [ Up Arrow ] | Scroll up / Previous trip page / Brightness increment |
| DOWN | [ Down Arrow ] | Scroll down / Next trip page / Brightness decrement |
| OK | [ Enter ] / [ Return ] | Enter submenu / Toggle checkbox / Select option |
| BACK | [ Esc ] / [ Backspace ] | Return to previous parent menu |
| THROTTLE | [ Right Arrow ] / [ Left Arrow ] | Accelerate / Decelerate speed and RPM |
| PARK BRAKE | [ B ] | Toggle Handbrake telltale |
| AUTO DRIVE | [ A ] | Start/Stop autonomous driving simulation |
| IGNITION | [ O ] | Toggle Ignition ON / OFF standby mode |
| SIMULATOR | [ F12 ] / [ Tab ] | Open/Close ECU Simulator Bench panel |

---

## Build & Run Instructions

### Prerequisites
- Qt 6.5+ (Qt Quick, QML, Core, Gui, Multimedia, Svg)
- CMake 3.20+
- C++20 compatible compiler (Clang / GCC / MSVC)
- Ninja or Make

### Quick Start
```bash
# Clone the repository
git clone https://github.com/skrehanahamed/hyundai-exter-cluster.git
cd hyundai-exter-cluster

# Configure and build
mkdir build && cd build
cmake .. -GNinja
ninja

# Run the cluster application
./HyundaiExterClusterApp
```

Or using the built-in Makefile:
```bash
make run
```

---

## Project Structure

```text
hyundai-exter-cluster/
├── CMakeLists.txt            # CMake build configuration and QML type registration
├── Makefile                  # Helper make targets (run, build, clean)
├── README.md                 # Complete project documentation
├── assets/
│   ├── cluster_preview.png   # Full digital cluster overview screenshot
│   └── features/             # Feature screenshots and component illustrations
├── src/
│   ├── main.cpp              # Application entry point & QML engine initialization
│   ├── ClusterController.h   # C++ controller (CAN/ECU state, Media, TPMS, Power, Themes)
│   └── ClusterController.cpp # Simulation logic, driving loops, and properties
├── qml/
│   ├── Main.qml              # Root application window & global keyboard handlers
│   ├── ClusterUnit.qml       # Main cluster frame & gauge layout container
│   ├── center/
│   │   ├── CenterTripDisplay.qml   # Central TFT controller (Media Popup, Tabs, DTE, ODO)
│   │   ├── InstantEcoGauge.qml     # 3D curved instant ECO gauge
│   │   ├── UserSettingsView.qml    # OEM User Settings with subpages & Hindi localization
│   │   ├── TpmsDisplayView.qml     # 3D top-down TPMS screen with tyre warning glow
│   │   ├── StartupAnimationView.qml # Welcome light wave sequence
│   │   ├── VehicleCheckView.qml    # Startup vehicle self-check sweep
│   │   └── GoodbyeView.qml         # Trip summary & shutdown sequence
│   ├── gauges/
│   │   ├── SpeedDisplay.qml        # Digital speed readout & arc graphics
│   │   ├── RpmDisplay.qml          # Digital RPM readout & gauge styling
│   │   └── SevenSegmentDigit.qml   # Custom 7-segment display component
│   ├── frame/
│   │   └── BlueFrame.qml           # Outer bezel and background glow frame
│   └── simulator/
│       └── EcuSimulatorPanel.qml   # Interactive ECU test bench (Media, TPMS, Auto-Drive, Doors)
└── resources/
    ├── fonts/                # Authentic Hyundai Sans Head & automotive typography
    ├── icons/                # OEM telltales, media icons (USB, CarPlay, BT), TPMS car
    └── audio/                # Turn signal ticks and warning chimes
```

---

## License
This project is created for educational, portfolio, and automotive UI/UX demonstration purposes.
