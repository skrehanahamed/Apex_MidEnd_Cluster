# Next-Gen Automotive Digital Instrument Cluster & Cockpit HMI

<img width="2636" height="1044" alt="image" src="https://github.com/user-attachments/assets/d50b3afd-ec90-4132-927f-19a5e6692699" />


<p align="center">
  <img src="https://img.shields.io/badge/Version-2.1.0-blue.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Release_Date-September_3,_2026-orange.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Qt-6.6+-41CD52.svg?style=for-the-badge&logo=Qt&logoColor=white" />
  <img src="https://img.shields.io/badge/C%2B%2B-20-00599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white" />
  <img src="https://img.shields.io/badge/CMake-3.20+-064F8C.svg?style=for-the-badge&logo=cmake&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-macOS%20|%20Linux%20|%20Windows-lightgrey.svg?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" />
</p>

A production-grade, photorealistic Automotive Digital Instrument Cluster HMI for the Hyundai Exter AMT (Smart Auto), engineered using Qt 6 (QML / Qt Quick) and modern C++20. Features authentic Hyundai typography, 1:1 OEM telltale layouts, dynamic multi-page trip computing, full 4-wheel TPMS simulation, an autonomous driving engine, standby power management with door-wake reactivity, and an infotainment media bridge.

---

## Release Notes - Version 2.1.0 (Updated: September 3, 2026)

### 1. AMT Powertrain Simulation (Speed-Coupled Gear Shifts and Engine RPM)

- Hyundai Exter 1.2L Kappa 5-Speed Smart Auto AMT logic fully integrated into the C++ simulation engine.
- Vehicle speed directly drives automatic gear selection: D1 (0-16 km/h), D2 (17-34 km/h), D3 (35-58 km/h), D4 (59-82 km/h), D5 (83+ km/h).
- Engine RPM curve calculated realistically per gear using gear-ratio fraction interpolation with a brief RPM drop on every upshift.
- Both left (speedometer) and right (tachometer) concentric arc lines 2 through 5 illuminate based on speed thresholds (30, 60, 90, 120 km/h) instead of a separate RPM input.
- Removed the manual RPM slider from the ECU Simulator. RPM is now fully automatic, derived from speed and gear state. A live AMT RPM readout is displayed in the bench panel.

### 2. Accurate Live Trip Telemetry (Distance, Time, and Fuel Economy per Page)

- All three trip pages - Drive Info, Since Refuelling, and Accumulated Info - now accumulate distance (km), elapsed driving time (h:m), and average fuel economy (km/L) independently and update in real time as the speed slider changes.
- Root cause of the non-updating trip display identified and fixed: the C++ setters were overwriting the internal floating-point accumulator with a rounded display value each tick, causing sub-0.1 km increments to be silently discarded.
- Introduced separate raw accumulator variables (m_rawTripKm, m_rawRefuelKm, m_rawAccumKm) that are never touched by the Qt property setters, ensuring precise accumulation across all ticks.
- Same fix applied to both the manual speed mode and the auto demo drive mode.
- Odometer (ODO) and Estimated Range (DTE) counters use the same raw accumulator pattern via m_rawOdoAcc and m_rawDteAcc, replacing static local variables that could not be reset.

### 3. Trip Timer Accuracy and Reset Fix

- Timer now advances only when the vehicle is moving (speed greater than 0). Previously it ticked at idle, causing the elapsed time to show random non-zero values at startup.
- The fractional second accumulator was previously declared as a static local inside the simulation tick function, making it impossible to reset between sessions. Moved to m_engineSecAcc, a proper member variable initialized to zero.
- All three reset functions (resetTrip, resetSinceRefuel, resetAccumInfo) now correctly zero their corresponding raw distance accumulators, litre accumulators, second counters, and the engine time accumulator.
- All trip member variable initial values corrected from hardcoded demo values (e.g. "0:42", 154.9 km, 3454.0 km) to clean zeros so the cluster starts fresh on every launch.

### 4. Demo Drive Simulation Card (Premium ECU Bench Control)

- The flat one-line demo drive toggle button has been replaced with a live telemetry control card in the ECU Simulator panel.
- When idle: compact 44 px row with a grey status LED and a cyan START button.
- When running: animates to 86 px showing a pulsing green LED, a live scenario label (e.g. Highway Cruise Control 100 km/h Active), an animated speed progress bar (0-120 km/h range), and a red STOP button.
- Speed bar uses three colour states: orange for idle/stop, blue for city speed (5-60 km/h), and green for highway (60+ km/h), each transitioning with a 400 ms colour animation.
- Border pulses with a glowing green animation while the simulation is active.
- All static local variables in the demo tick loop (cycleTime, prevGearNum, odoAcc, dteAcc) promoted to member variables (m_demoCycleTime, m_demoPrevGear, m_rawOdoAcc, m_rawDteAcc) so the demo resets cleanly each time it is started.

### 5. Fuel Range Display at Zero Fuel

- When the fuel gauge reaches 0 bars, the Estimated Range (DTE) field in the center TFT displays three dashes (---) instead of 0 km, matching the OEM Hyundai Exter instrument cluster behavior.

### 6. Welcome Screen Concentric Line Sequencing

- During the welcome animation (StateInitialStartup), all five concentric arc lines on both gauge rings are lit in glowing blue.
- When the welcome animation ends and the system check begins (StateBootCheck), all lines collapse to only line 1 (the baseline arc).
- The system check then runs with only the single baseline line active, matching the authentic OEM power-on sequence.

### 7. Hyundai Sans Head Font Name Table Patch

- All three Hyundai Sans Head typeface files (Regular, Medium, Bold) had a broken OpenType name table with no registered family name (nameID 1 was absent), causing Qt to log a missing font family warning on every launch.
- The font files were patched in-place using Python fonttools to inject correct name records: family "Hyundai Sans Head", styles Regular / Medium / Bold.
- QML files that used CSS-style font stacks (Hyundai Sans Head, Segoe UI, Roboto, Helvetica, Arial, sans-serif) were updated to the single Qt-compatible family name "Hyundai Sans Head". Qt does not support comma-separated font fallback stacks in the font.family property.
- The console now prints QList("Hyundai Sans Head") for all three weights with no font alias warnings.

---

## Release Notes - Version 2.0.0 (Updated: September 2, 2026)

### 1. OEM Infotainment & Media Popup Banner (Top-Line Emergence & Marquee)

<p align="center">
  <img src="assets/features/usb_media.png" alt="OEM Infotainment Media Popup Banner" width="95%" />
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
  <img src="assets/features/tpms.png" alt="TPMS 4-Wheel Pressure Monitoring" width="95%" />
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
  <img src="assets/features/ignition_off_door_activity.png" alt="Standby Ignition-OFF Door Wake" width="95%" />
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
  <img src="assets/features/all_door_open_green_theme.png" alt="All Doors Open with Green Theme" width="95%" />
</p>

- Zero-Drift Pixel Lock: All 19 car door animation frames are mathematically normalized against the base chassis (0.000 pixel drift). When doors open or close, the chassis, roof, windshield, and wheels remain completely motionless — only the door flaps physically swing outward.
- Contoured Bonnet & Trunk Hazards: Photorealistic red hazard glow overlays following the exact vehicle body stamping lines, pulsing at a 400ms cadence.

---

### 5. Regional Multi-Language Localization (English & Hindi)

<p align="center">
  <img src="assets/features/hindi_language_menu.png" alt="Vernacular Hindi Localization Menu" width="95%" />
</p>

- Real-Time Language Switching: Seamlessly toggle between English and Hindi (हिन्दी) through the User Settings menu (`Settings -> Language -> English / हिन्दी`).
- Full Vernacular Localization: All primary categories, submenus, vehicle diagnostics, prompts, and settings translated into authentic OEM Hindi terminology:
  - चालक सहायता (Driver assistance)
  - क्लस्टर (Cluster)
  - लाइट्स (Lights)
  - डोर (Door)
  - सुविधा (Convenience)
  - यूनिट सेटिंग (Unit setting)
  - भाषा (Language)
  - सेटिंग्स रीसेट करें (Reset settings)
- Responsive Devnagari Typography: Integrated with clean Unicode line spacing and dynamic centering across all TFT views.

---

### 6. Autonomous Dynamic Driving Simulation Engine & OEM Telltales

<p align="center">
  <img src="assets/features/normal_gear_all_telltale.png" alt="Normal Cluster View with Gears and Telltales" width="95%" />
</p>

- Multi-Phase Driving Cycle (approx. 60 seconds realistic highway/city loop):
  - Phase 1: City Start & Acceleration (0 to 45 km/h) with automatic gear shifting D1 to D2 to D3.
  - Phase 2: Left Lane Change with automatic Left Turn Signal (3s flashing).
  - Phase 3: Highway Ramp Acceleration (55 to 105 km/h) through D4 to D5 with matching RPM powerband curves.
  - Phase 4: Highway Cruise Control locked at 100 km/h with green CRUISE telltale.
  - Phase 5: Right Lane Exit with automatic Right Turn Signal (3s flashing).
  - Phase 6: Deceleration / Coasting (80 to 0 km/h) with instant fuel economy maxing out at 30 km/L.
  - Phase 7: Traffic Light Idle at 0 km/h with idle RPM (0.8 x1000 RPM).
- Realigned OEM Telltales: Master Warning on Far-Left and Bulb Fault on Bottom-Left matching physical cluster blueprints.

---

## Feature Gallery

<p align="center">
  <img src="assets/features/green_theme.png" alt="Emerald Green Cluster Theme" width="48%" />
  <img src="assets/features/red_theme.png" alt="Crimson Red Cluster Theme" width="48%" />
</p>

<p align="center">
  <img src="assets/features/all_telltale_red_theme.png" alt="Telltale Verification in Red Theme" width="48%" />
  <img src="assets/features/lines.png" alt="Curved Digital Gauge Lines and Cluster Architecture" width="48%" />
</p>

<p align="center">
  <img src="assets/features/press_start_button.png" alt="Smart Key Press Start Button Prompt" width="48%" />
  <img src="assets/features/key_issue.png" alt="Smart Key Not Detected Alert" width="48%" />
</p>

<p align="center">
  <img src="assets/features/system_check.png" alt="Startup Diagnostic System Check Sweep" width="48%" />
  <img src="assets/features/good_bye_screen.png" alt="Goodbye Shutdown Summary Screen" width="48%" />
</p>

---

## System Architecture

```mermaid
graph TD
    subgraph "Core C++ Engine (Qt 6 / C++20)"
        MAIN["main.cpp<br>QGuiApplication & QQmlApplicationEngine"]
        CTRL["ClusterController (QObject Singleton)<br>CAN / ECU Telemetry, AMT Powertrain,<br>Trip Accumulators, Timers & Power Engine"]
    end

    subgraph "Central TFT Display (4.2-inch MFD)"
        CENTER["CenterTripDisplay.qml<br>(Trip Pages, DTE, ODO, Gear, Temp)"]
        MEDIA["MediaPopupBanner.qml<br>(Top-Line Emergence & Marquee)"]
        TPMS_VIEW["TpmsDisplayView.qml<br>(4-Wheel Graphic & Glowing Pills)"]
        SETTINGS["UserSettingsView.qml<br>(Hierarchical OEM Menus & Hindi Localization)"]
        ECO["InstantEcoGauge.qml<br>(3D Extruded Glow Gauge)"]
        STARTUP["StartupAnimationView.qml<br>(5-Line Welcome & Laser Convergence)"]
        CHECK["VehicleCheckView.qml<br>(Self-Diagnostic Bulb Check)"]
        GOODBYE["GoodbyeView.qml<br>(Trip Summary & Shutdown)"]
    end

    subgraph "Digital Gauges & Telltales"
        SPEED["SpeedDisplay.qml<br>(7-Segment Speed & Arc Bars)"]
        RPM["RpmDisplay.qml<br>(7-Segment AMT RPM & Torque Curve)"]
        FUEL["FuelGauge.qml + FuelIcon.qml<br>(Custom OEM Fuel Bar & Low Fuel Icon)"]
        TEMP["TempGauge.qml + TempIcon.qml<br>(Custom OEM Coolant Temp Bar & Icon)"]
        BEZEL["BlueFrame.qml / ClusterUnit.qml<br>(Speed-Driven Concentric Arc Lines,<br>Telltales & Master Warnings)"]
    end

    subgraph "ECU Simulation & Test Bench"
        ECU["EcuSimulatorPanel.qml<br>(Media Player, 4-Wheel TPMS,<br>AMT Auto-Drive Card, Smart Key)"]
    end

    MAIN --> CTRL
    CTRL --> CENTER
    CTRL --> SPEED
    CTRL --> RPM
    CTRL --> FUEL
    CTRL --> TEMP
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
├── CMakeLists.txt              # CMake build configuration and QML type registration
├── Makefile                    # Helper make targets (run, build, clean)
├── README.md                   # Complete project documentation
├── assets/
│   ├── cluster_preview.png     # Full digital cluster overview screenshot
│   ├── hyundai_exter_car.png   # OEM Exter silhouette for TFT center display
│   ├── oem_studio_ground.png   # Studio ground plane for car render
│   ├── car_ground_shadow.png   # Ground shadow overlay
│   ├── rpm_line1-5.svg         # Right gauge concentric arc line SVGs
│   ├── speed_line1-5.svg       # Left gauge concentric arc line SVGs
│   └── features/               # Feature screenshots and component illustrations
├── src/
│   ├── main.cpp                # Application entry point & QML engine initialization
│   ├── ClusterController.h     # C++ controller header (AMT, Trip, Media, TPMS, Power, Themes)
│   └── ClusterController.cpp   # Simulation engine: AMT powertrain, trip accumulators,
│                               #   demo drive loop, instant economy, chime triggers
├── qml/
│   ├── Main.qml                # Root application window & global keyboard handlers
│   ├── ClusterUnit.qml         # Master cluster frame, state machine, gauge layout
│   ├── center/
│   │   ├── CenterTripDisplay.qml    # Central TFT: trip pages, DTE, ODO, gear, temp, media
│   │   ├── InstantEcoGauge.qml      # 3D curved instant fuel economy gauge
│   │   ├── UserSettingsView.qml     # OEM User Settings: subpages, Hindi localization
│   │   ├── TpmsDisplayView.qml      # 3D top-down TPMS screen with tyre warning glow
│   │   ├── StartupAnimationView.qml # Welcome animation: 5-line arc & laser convergence
│   │   ├── VehicleCheckView.qml     # Startup self-diagnostic bulb check sweep
│   │   └── GoodbyeView.qml          # Ignition-off trip summary & shutdown sequence
│   ├── gauges/
│   │   ├── SpeedDisplay.qml         # 7-segment digital speed readout & arc bars
│   │   ├── RpmDisplay.qml           # 7-segment AMT RPM readout & torque curve
│   │   ├── FuelGauge.qml            # Custom OEM-style horizontal fuel bar gauge
│   │   ├── FuelIcon.qml             # Fuel pump icon with low-fuel warning state
│   │   ├── TempGauge.qml            # Custom OEM-style horizontal coolant temp bar
│   │   ├── TempIcon.qml             # Coolant thermometer icon with overheat warning
│   │   └── SevenSegmentDigit.qml    # Reusable 7-segment display digit component
│   ├── frame/
│   │   └── BlueFrame.qml            # Outer bezel, speed-driven arc lines, glow frame
│   └── simulator/
│       └── EcuSimulatorPanel.qml    # ECU test bench: media, TPMS, AMT auto-drive card,
│                                    #   smart key, doors, telltales, light stalk
└── resources/
    ├── fonts/
    │   ├── HyundaiSansHead-Regular.ttf   # Hyundai Sans Head (patched name table)
    │   ├── HyundaiSansHead-Medium.ttf    # Hyundai Sans Head Medium weight
    │   ├── HyundaiSansHead-Bold.ttf      # Hyundai Sans Head Bold weight
    │   ├── NotoSansDevanagari-Regular.ttf # Hindi localization typeface
    │   ├── DSEG7Classic-Bold.ttf         # 7-segment display font
    │   ├── DSEG7Classic-Regular.ttf      # 7-segment display font (regular)
    │   ├── Orbitron-Bold.ttf             # Futuristic HUD accent font
    │   └── Rajdhani-Bold.ttf             # Automotive display accent font
    ├── icons/
    │   ├── (OEM telltale PNGs)           # abs, airbag, battery, brake, engine_mil,
    │   │                                 #   esc, high_beam, low_beam, master_warning,
    │   │                                 #   oil, seatbelt, steering, tpms, etc.
    │   ├── (Media source icons)          # media_usb, media_carplay, media_bluetooth,
    │   │                                 #   media_android_auto, media_note
    │   ├── (Gauge icons)                 # fuel_meter_icon, temp_meter_icon,
    │   │                                 #   low_fuel_warning_3d, fuel_pump
    │   ├── (Car door animation frames)   # car_door_fl/fr/rl/rr + half variants,
    │   │                                 #   car_doors_all_open, bonnet/trunk glow
    │   ├── (TPMS)                        # tpms_car_top, tpms
    │   ├── (Trip computer)               # trip_car, trip_clock, trip_fuel
    │   ├── (Smart Key)                   # smart_key, hyundai_smart_key_fob,
    │   │                                 #   engine_start_button_oem
    │   └── (Cruise control)              # cruise_green, cruise_white
    └── audio/
        ├── tick.wav                      # Turn signal tick (left / right)
        ├── tock.wav                      # Turn signal tock (left / right)
        ├── hyundai_chime.wav             # OEM Hyundai 3-tone startup chime
        ├── welcome_chime.wav             # Welcome screen entry tone
        ├── startup_animation_tone.wav    # Boot animation tone
        ├── goodbye_chime.wav             # Ignition-off shutdown chime
        ├── key_alert_chime.wav           # Smart key not detected alert
        ├── seatbelt_chime.wav            # Seatbelt reminder chime
        ├── speed_alert_chime.wav         # Overspeed warning chime
        └── warning_chime.wav             # Generic telltale warning chime
```

---

## License
This project is created for educational, portfolio, and automotive UI/UX demonstration purposes.
