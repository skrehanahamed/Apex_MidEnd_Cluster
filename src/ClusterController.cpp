/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           ClusterController.cpp
 * Author:         SK Rehan Ahamed
 * Description:    Automotive CAN / ECU Telemetry Controller Implementation
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

#include "ClusterController.h"
#include <cmath>

ClusterController::ClusterController(QObject *parent)
    : QObject(parent)
{
    connect(&m_sequenceTimer, &QTimer::timeout, this, &ClusterController::onSequenceStep);
    connect(&m_driveSimTimer, &QTimer::timeout, this, &ClusterController::onDriveSimulationTick);
    m_driveSimTimer.start(33); // ~30 FPS telemetry simulation

    m_rearAlarmTimer = new QTimer(this);
    m_rearAlarmTimer->setSingleShot(true);
    connect(m_rearAlarmTimer, &QTimer::timeout, this, &ClusterController::onRearAlarmTimeout);

    m_rearBlinkTimer = new QTimer(this);
    m_rearBlinkTimer->setInterval(350);
    connect(m_rearBlinkTimer, &QTimer::timeout, this, &ClusterController::onRearBlinkTick);
}

void ClusterController::triggerStartupSequence()
{
    m_sequenceStepIndex = 1;
    setClusterState(StateInitialStartup);

    // Reset Drive info for new ignition start cycle
    resetTrip();

    // Play authentic Hyundai Startup Animation Tone
    emit signalStartupAnimationTone();

    // Initial state: Everything dark except frame + signature wave
    setSpeed(0);
    setRpm(0.0);
    setAllTelltales(false);

    m_sequenceTimer.start(3800); // 3.8s in State 1 (Multi-Section Wave of Light Welcome Animation)
}

void ClusterController::onSequenceStep()
{
    if (m_sequenceStepIndex == 1) {
        // Transition to State 2: Boot / System check
        m_sequenceStepIndex = 2;
        setClusterState(StateBootCheck);

        // Play authentic Hyundai System Check Chime
        emit signalWelcomeChime();

        // Turn on safety self-test telltales & gauge sweep
        setBulbCheckTelltales(true);

        m_sequenceTimer.start(5000); // 5.0s in State 2 (System check)
    }
    else if (m_sequenceStepIndex == 2) {
        // Transition to State 3: Normal Driving / Current trip
        m_sequenceStepIndex = 3;
        setClusterState(StateNormalTrip);

        // Self-test complete: Safety warning lamps extinguish upon successful check
        setAbsActive(false);
        setAirbagActive(false);
        setTpmsActive(false);
        setEscActive(false);
        setSteeringActive(false);
        setSeatbeltActive(false); // 3 rear seatbelts handled dynamically on unbuckle

        // Keep key-on standard engine-off telltales
        setParkBrakeActive(true);
        setBatteryActive(true);
        setOilActive(true);
        setCheckEngineActive(true);
        setSmartKeyActive(false);
        setEscOffActive(false);
        setMasterWarning(false);

        m_sequenceTimer.stop();
    }
}

void ClusterController::cycleGear()
{
    if (m_gear == "P") setGear("R");
    else if (m_gear == "R") setGear("N");
    else if (m_gear == "N") setGear("D");
    else if (m_gear == "D" || m_gear == "1" || m_gear == "2" || m_gear == "3" || m_gear == "4" || m_gear == "5") setGear("M1");
    else if (m_gear == "M1") setGear("M2");
    else if (m_gear == "M2") setGear("M3");
    else if (m_gear == "M3") setGear("M4");
    else if (m_gear == "M4") setGear("M5");
    else setGear("P");
}

void ClusterController::resetTrip()
{
    m_tripSeconds  = 0;
    m_tripLitres   = 0.0;
    m_rawTripKm    = 0.0;
    m_engineSecAcc = 0.0;
    setTripKm(0.0);
    setTripTime("0:00");
    setTripEconomy(0.0);
}

void ClusterController::resetActiveTripPage()
{
    if (m_tripPage == 1) {
        resetSinceRefuel();
    } else if (m_tripPage == 2) {
        resetAccumInfo();
    } else {
        resetTrip();
    }
}

void ClusterController::resetSinceRefuel()
{
    m_refuelSeconds = 0;
    m_refuelLitres  = 0.0;
    m_rawRefuelKm   = 0.0;
    setRefuelKm(0.0);
    setRefuelTime("0:00");
    setRefuelEconomy(0.0);
}

void ClusterController::resetAccumInfo()
{
    m_accumSeconds = 0;
    m_accumLitres  = 0.0;
    m_rawAccumKm   = 0.0;
    setAccumKm(0.0);
    setAccumTime("0:00");
    setAccumEconomy(0.0);
}

void ClusterController::driveDemo()
{
    m_isDemoDriving = !m_isDemoDriving;
    emit isDemoDrivingChanged();

    if (m_isDemoDriving) {
        if (m_clusterState != StateNormalTrip) {
            triggerStartupSequence();
        }
        setGear("D");
        setParkBrakeActive(false);
        setBatteryActive(false);
        setOilActive(false);
        setSeatbeltActive(false);
        m_demoScenario = "Starting Autonomous Drive";
        emit demoScenarioChanged();
    } else {
        m_demoCycleTime = 0.0;
        m_demoPrevGear  = 1;
        setGear("N");
        setSpeed(0);
        setRpm(0.0);
        setLeftIndicator(false);
        setRightIndicator(false);
        setCruiseActive(false);
        setParkBrakeActive(true);
        setBatteryActive(true);
        setOilActive(true);
        setSeatbeltActive(true);
        m_demoScenario = "Idle / Parked";
        emit demoScenarioChanged();
    }
}

void ClusterController::onDriveSimulationTick()
{
    if (m_isDemoDriving && m_clusterState == StateNormalTrip) {
        m_demoCycleTime += 0.033; // 30Hz tick

        // Simulation loop duration: ~60 seconds total cycle
        double phase = std::fmod(m_demoCycleTime, 60.0);
        double targetSpeed = 0.0;
        QString scenario = "City Driving";

        if (phase < 8.0) {
            // Phase 1: City Start & Acceleration (0 -> 45 km/h)
            double p = phase / 8.0;
            targetSpeed = 45.0 * std::sin(p * 1.5708);
            scenario = QString("City Acceleration (%1 km/h)").arg(m_speed);
            setCruiseActive(false);
            setLeftIndicator(false);
            setRightIndicator(false);
        } else if (phase < 13.0) {
            // Phase 2: Left Lane Change with Turn Signal (45 -> 55 km/h)
            double p = (phase - 8.0) / 5.0;
            targetSpeed = 45.0 + 10.0 * p;
            scenario = "Left Lane Change (Indicator Active)";
            setLeftIndicator(true);
            setRightIndicator(false);
        } else if (phase < 24.0) {
            // Phase 3: Highway Ramp Acceleration (55 -> 105 km/h)
            setLeftIndicator(false);
            double p = (phase - 13.0) / 11.0;
            targetSpeed = 55.0 + 50.0 * std::sin(p * 1.5708);
            scenario = QString("Highway Acceleration (%1 km/h)").arg(m_speed);
        } else if (phase < 38.0) {
            // Phase 4: Highway Cruise Control Active (100 km/h locked)
            targetSpeed = 100.0 + 2.0 * std::sin((phase - 24.0) * 0.8);
            scenario = "Highway Cruise Control (100 km/h Active)";
            setCruiseEnabled(true);
            setCruiseActive(true);
            setCruiseSetSpeed(100);
        } else if (phase < 43.0) {
            // Phase 5: Right Lane Change / Exit (100 -> 80 km/h)
            setCruiseActive(false);
            setRightIndicator(true);
            double p = (phase - 38.0) / 5.0;
            targetSpeed = 100.0 - 20.0 * p;
            scenario = "Right Lane Exit (Indicator Active)";
        } else if (phase < 54.0) {
            // Phase 6: Deceleration / Coasting to Stop (80 -> 0 km/h)
            setRightIndicator(false);
            double p = (phase - 43.0) / 11.0;
            targetSpeed = 80.0 * (1.0 - std::sin(p * 1.5708));
            if (targetSpeed < 0.0) targetSpeed = 0.0;
            scenario = QString("Decelerating to Stop (%1 km/h)").arg(m_speed);
        } else {
            // Phase 7: Idle Stop at Traffic Light (0 km/h)
            targetSpeed = 0.0;
            scenario = "Traffic Light Stop (Idle)";
        }

        // Smooth speed convergence
        double currentSpeed = m_speed + (targetSpeed - m_speed) * 0.08;
        int nextSpeed = static_cast<int>(std::round(currentSpeed));
        if (nextSpeed < 0) nextSpeed = 0;
        setSpeed(nextSpeed);

        // Simulated Exter 1.2L Kappa AMT RPM curve with gear shifts
        int currentGearNum = 1;
        if (nextSpeed <= 16) currentGearNum = 1;
        else if (nextSpeed <= 34) currentGearNum = 2;
        else if (nextSpeed <= 58) currentGearNum = 3;
        else if (nextSpeed <= 82) currentGearNum = 4;
        else currentGearNum = 5;

        // Gear display (Auto D mode)
        if (nextSpeed == 0) {
            setGear("D");
        } else {
            setGear(QString("D%1").arg(currentGearNum));
        }

        // Realistic RPM curve per gear
        double gearMinSpeed = (currentGearNum == 1) ? 0 : (currentGearNum == 2 ? 16 : (currentGearNum == 3 ? 34 : (currentGearNum == 4 ? 58 : 82)));
        double gearMaxSpeed = (currentGearNum == 1) ? 22 : (currentGearNum == 2 ? 42 : (currentGearNum == 3 ? 66 : (currentGearNum == 4 ? 90 : 165)));
        double fraction = (nextSpeed - gearMinSpeed) / std::max(1.0, gearMaxSpeed - gearMinSpeed);
        fraction = std::clamp(fraction, 0.0, 1.0);

        double calculatedRpm = 0.9;
        if (nextSpeed > 0) {
            calculatedRpm = 1.1 + fraction * 2.8;
            // Brief RPM drop on gear shift
            if (currentGearNum != m_demoPrevGear) {
                calculatedRpm = 1.2;
                m_demoPrevGear = currentGearNum;
            }
        }
        setRpm(calculatedRpm);

        // Dynamic Instant Fuel Economy (km/L)
        double instantEco = 18.0;
        if (nextSpeed == 0) {
            instantEco = 0.0;
        } else if (targetSpeed > currentSpeed + 2.0) {
            // Accelerating
            instantEco = 9.5 + 4.0 * (1.0 - fraction);
        } else if (targetSpeed < currentSpeed - 2.0) {
            // Coasting / decelerating
            instantEco = 28.5 + 1.5 * std::sin(m_demoCycleTime * 2.0);
        } else {
            // Cruising
            instantEco = 19.2 + 2.5 * std::sin(m_demoCycleTime * 0.5);
        }
        setInstantEconomy(std::clamp(instantEco, 0.0, 30.0));

        // Update trip distance & odometer (use raw accumulators – never truncated by setter)
        double distanceIncrement = (currentSpeed / 3600.0) * 0.033 * 5.0;
        m_rawTripKm   += distanceIncrement;
        m_rawRefuelKm += distanceIncrement;
        m_rawAccumKm  += distanceIncrement;
        setTripKm(std::round(m_rawTripKm * 10.0) / 10.0);
        setRefuelKm(std::round(m_rawRefuelKm * 10.0) / 10.0);
        setAccumKm(std::round(m_rawAccumKm * 10.0) / 10.0);

        // Odometer increments
        m_rawOdoAcc += distanceIncrement;
        if (m_rawOdoAcc >= 1.0) {
            int kmToAdd = static_cast<int>(m_rawOdoAcc);
            setOdoKm(m_odoKm + kmToAdd);
            m_rawOdoAcc -= kmToAdd;
        }

        // Range (DTE) consumption
        m_rawDteAcc += distanceIncrement;
        if (m_rawDteAcc >= 1.0) {
            int kmToSub = static_cast<int>(m_rawDteAcc);
            if (m_dteKm > kmToSub) {
                setDteKm(m_dteKm - kmToSub);
            }
            m_rawDteAcc -= kmToSub;
        }

        // Consumed fuel
        double litresDelta = (instantEco > 1.0) ? (distanceIncrement / instantEco) : (distanceIncrement / 16.0);
        m_tripLitres += litresDelta;
        m_refuelLitres += litresDelta;
        m_accumLitres += litresDelta;
        m_fuelBarAccumulator += litresDelta;
        if (m_fuelBarAccumulator >= 3.08 && m_fuelLevel > 0) {
            m_fuelBarAccumulator -= 3.08;
            setFuelLevel(m_fuelLevel - 1);
        }

        // Average trip economy for each page (km / litres)
        if (m_tripLitres > 0.005 && m_tripKm >= 0.1) {
            double avgEcon = m_tripKm / m_tripLitres;
            setTripEconomy(std::clamp(std::round(avgEcon * 10.0) / 10.0, 5.0, 30.0));
        } else {
            setTripEconomy(0.0);
        }

        if (m_refuelLitres > 0.005 && m_refuelKm >= 0.1) {
            double avgRefuel = m_refuelKm / m_refuelLitres;
            setRefuelEconomy(std::clamp(std::round(avgRefuel * 10.0) / 10.0, 5.0, 30.0));
        } else {
            setRefuelEconomy(0.0);
        }

        if (m_accumLitres > 0.005 && m_accumKm >= 0.1) {
            double avgAccum = m_accumKm / m_accumLitres;
            setAccumEconomy(std::clamp(std::round(avgAccum * 10.0) / 10.0, 5.0, 30.0));
        } else {
            setAccumEconomy(0.0);
        }

        // Update Scenario string
        if (m_demoScenario != scenario) {
            m_demoScenario = scenario;
            emit demoScenarioChanged();
        }
    }
    else if (!m_isDemoDriving && m_speed > 0 && m_clusterState == StateNormalTrip) {
        // Manual driving live speed telemetry calculation
        double speedVal = static_cast<double>(m_speed);

        // Instant economy based on speed (km/L)
        double instantEco = 16.0;
        if (speedVal <= 15.0) instantEco = 8.5 + speedVal * 0.3;
        else if (speedVal <= 65.0) instantEco = 13.0 + (speedVal - 15.0) * 0.22;
        else if (speedVal <= 90.0) instantEco = 24.0 - (speedVal - 65.0) * 0.15;
        else instantEco = 20.2 - (speedVal - 90.0) * 0.12;
        setInstantEconomy(std::clamp(instantEco, 0.0, 30.0));

        // Simulation distance increment (Responsive ~12x time compression for simulator bench)
        double distanceIncrement = (speedVal / 3600.0) * 0.033 * 12.0;

        // Use RAW accumulators so rounding in the setter never eats sub-0.1 km progress
        m_rawTripKm   += distanceIncrement;
        m_rawRefuelKm += distanceIncrement;
        m_rawAccumKm  += distanceIncrement;
        setTripKm(std::round(m_rawTripKm * 10.0) / 10.0);
        setRefuelKm(std::round(m_rawRefuelKm * 10.0) / 10.0);
        setAccumKm(std::round(m_rawAccumKm * 10.0) / 10.0);

        // Odometer: only tick whole km
        m_rawOdoAcc += distanceIncrement;
        if (m_rawOdoAcc >= 1.0) {
            int kmToAdd = static_cast<int>(m_rawOdoAcc);
            setOdoKm(m_odoKm + kmToAdd);
            m_rawOdoAcc -= kmToAdd;
        }

        // DTE: only decrease whole km
        m_rawDteAcc += distanceIncrement;
        if (m_rawDteAcc >= 1.0) {
            int kmToSub = static_cast<int>(m_rawDteAcc);
            if (m_dteKm > kmToSub) {
                setDteKm(m_dteKm - kmToSub);
            }
            m_rawDteAcc -= kmToSub;
        }

        // Fuel consumption calculation
        double litresDelta = (instantEco > 1.0) ? (distanceIncrement / instantEco) : (distanceIncrement / 16.0);
        m_tripLitres += litresDelta;
        m_refuelLitres += litresDelta;
        m_accumLitres += litresDelta;
        m_fuelBarAccumulator += litresDelta;
        if (m_fuelBarAccumulator >= 3.08 && m_fuelLevel > 0) {
            m_fuelBarAccumulator -= 3.08;
            setFuelLevel(m_fuelLevel - 1);
        }

        // Accurate average mileage calculations (km / L)
        if (m_tripLitres > 0.002 && m_tripKm >= 0.05) {
            double avgEcon = m_tripKm / m_tripLitres;
            setTripEconomy(std::clamp(std::round(avgEcon * 10.0) / 10.0, 5.0, 30.0));
        }

        if (m_refuelLitres > 0.002 && m_refuelKm >= 0.05) {
            double avgRefuel = m_refuelKm / m_refuelLitres;
            setRefuelEconomy(std::clamp(std::round(avgRefuel * 10.0) / 10.0, 5.0, 30.0));
        }

        if (m_accumLitres > 0.002 && m_accumKm >= 0.05) {
            double avgAccum = m_accumKm / m_accumLitres;
            setAccumEconomy(std::clamp(std::round(avgAccum * 10.0) / 10.0, 5.0, 30.0));
        }
    }

    // Engine running time clock (Updates only when vehicle is moving)
    if (m_clusterState == StateNormalTrip && m_speed > 0) {
        double timeRate = 0.20; // Accelerated (1s wall clock = 6s trip time) for responsive bench testing
        m_engineSecAcc += timeRate;
        if (m_engineSecAcc >= 1.0) {
            int sec = static_cast<int>(m_engineSecAcc);
            m_engineSecAcc -= sec;
            m_tripSeconds    += sec;
            m_refuelSeconds  += sec;
            m_accumSeconds   += sec;

            auto fmtTime = [](int s) -> QString {
                int mins  = (s / 60) % 60;
                int hours = s / 3600;
                char buf[32];
                std::snprintf(buf, sizeof(buf), "%d:%02d", hours, mins);
                return QString::fromUtf8(buf);
            };

            setTripTime(fmtTime(m_tripSeconds));
            setRefuelTime(fmtTime(m_refuelSeconds));
            setAccumTime(fmtTime(m_accumSeconds));
        }
    }
}

void ClusterController::setThemeColor(const QString& color) { if (m_themeColor != color) { m_themeColor = color; emit themeColorChanged(); } }
void ClusterController::setTempUnit(const QString& unit) { if (m_tempUnit != unit) { m_tempUnit = unit; emit tempUnitChanged(); } }
void ClusterController::setFuelUnit(const QString& unit) { if (m_fuelUnit != unit) { m_fuelUnit = unit; emit fuelUnitChanged(); } }
void ClusterController::setTpmsUnit(const QString& unit) { if (m_tpmsUnit != unit) { m_tpmsUnit = unit; emit tpmsUnitChanged(); } }
void ClusterController::setIllumination(int level) { if (m_illumination != level) { m_illumination = level; emit illuminationChanged(); } }
void ClusterController::setClusterState(int state) {
    if (m_clusterState != state) {
        m_clusterState = state;
        emit clusterStateChanged();
        if (state == StateShutdown) {
            emit signalGoodbyeChime();
        }
    }
}
void ClusterController::setCruiseEnabled(bool enabled) {
    if (m_cruiseEnabled != enabled) {
        m_cruiseEnabled = enabled;
        if (!m_cruiseEnabled) {
            m_cruiseActive = false;
            emit cruiseActiveChanged();
        }
        emit cruiseEnabledChanged();
    }
}

void ClusterController::setCruiseActive(bool active) {
    if (m_cruiseActive != active) {
        m_cruiseActive = active;
        if (m_cruiseActive && !m_cruiseEnabled) {
            m_cruiseEnabled = true;
            emit cruiseEnabledChanged();
        }
        emit cruiseActiveChanged();
    }
}

void ClusterController::setCruiseSetSpeed(int speed) {
    if (m_cruiseSetSpeed != speed) {
        m_cruiseSetSpeed = speed;
        emit cruiseSetSpeedChanged();
    }
}

void ClusterController::toggleCruise() {
    if (!m_cruiseEnabled) {
        setCruiseEnabled(true);
        setCruiseActive(false); // Standby (White icon)
    } else {
        setCruiseEnabled(false);
        setCruiseActive(false);
    }
}

void ClusterController::cruiseSet() {
    if (!m_cruiseEnabled) {
        setCruiseEnabled(true);
    }
    int target = m_speed > 30 ? m_speed : (m_cruiseSetSpeed > 0 ? m_cruiseSetSpeed : 41);
    setCruiseSetSpeed(target);
    setCruiseActive(true); // Active (Green icon)
    setSpeed(target);
    setRpm(1.2 + (target / 100.0) * 1.5);
}

void ClusterController::cruiseResPlus() {
    if (!m_cruiseEnabled) {
        setCruiseEnabled(true);
    }
    setCruiseActive(true);
    int target = std::min(180, m_cruiseSetSpeed + 2);
    setCruiseSetSpeed(target);
    setSpeed(target);
    setRpm(1.2 + (target / 100.0) * 1.5);
}

void ClusterController::cruiseSetMinus() {
    if (!m_cruiseEnabled) {
        setCruiseEnabled(true);
    }
    if (!m_cruiseActive) {
        cruiseSet();
        return;
    }
    int target = std::max(30, m_cruiseSetSpeed - 2);
    setCruiseSetSpeed(target);
    setSpeed(target);
    setRpm(1.2 + (target / 100.0) * 1.5);
}

void ClusterController::cruiseCancel() {
    setCruiseActive(false); // Cancel back to Standby
}

void ClusterController::setShowLightPopup(bool show) {
    if (m_showLightPopup != show) {
        m_showLightPopup = show;
        emit showLightPopupChanged();
    }
}

void ClusterController::setLightMode(int mode) {
    m_lightMode = std::clamp(mode, 0, 3);
    emit lightModeChanged();

    // Trigger popup display on center screen
    setShowLightPopup(true);

    // Update telltale states directly:
    // 0 = OFF (all off)
    // 1 = AUTO (position lamp + low beam on)
    // 2 = POSITION (position lamp on, low beam off)
    // 3 = HEADLIGHT (position lamp + low beam on)
    switch (m_lightMode) {
    case 0:
        setPositionLamp(false);
        setLowBeam(false);
        break;
    case 1:
        setPositionLamp(true);
        setLowBeam(true);
        break;
    case 2:
        setPositionLamp(true);
        setLowBeam(false);
        break;
    case 3:
        setPositionLamp(true);
        setLowBeam(true);
        break;
    }
}

void ClusterController::cycleLightMode() {
    setLightMode((m_lightMode + 1) % 4);
}

void ClusterController::setSpeed(int s)
{
    if (m_speed != s) {
        int prevSpeed = m_speed;
        m_speed = s;
        emit speedChanged();

        // If speed increases while in startup/boot check, transition directly to normal trip mode
        if (m_speed > 0 && m_clusterState != StateNormalTrip) {
            m_sequenceTimer.stop();
            setClusterState(StateNormalTrip);
        }

        // =============================================================
        // HYUNDAI EXTER 1.2L KAPPA 5-SPEED SMART AUTO AMT COUPLING:
        // Speed directly drives realistic AMT gear shifts and engine RPM
        // =============================================================
        int currentGearNum = 1;
        if (m_speed <= 18) currentGearNum = 1;
        else if (m_speed <= 36) currentGearNum = 2;
        else if (m_speed <= 58) currentGearNum = 3;
        else if (m_speed <= 82) currentGearNum = 4;
        else currentGearNum = 5;

        // Gear display (Auto D mode)
        if (m_speed == 0) {
            setGear("D");
        } else {
            setGear(QString("D%1").arg(currentGearNum));
        }

        // Realistic AMT RPM curve coupled to speed per gear
        if (m_clusterState == StateNormalTrip) {
            if (m_speed == 0) {
                setRpm(0.8); // 800 RPM smooth idle in D
            } else {
                double gearMin = (currentGearNum == 1) ? 0.0 : (currentGearNum == 2 ? 18.0 : (currentGearNum == 3 ? 36.0 : (currentGearNum == 4 ? 58.0 : 82.0)));
                double gearMax = (currentGearNum == 1) ? 24.0 : (currentGearNum == 2 ? 44.0 : (currentGearNum == 3 ? 68.0 : (currentGearNum == 4 ? 92.0 : 175.0)));
                double frac = (m_speed - gearMin) / std::max(1.0, gearMax - gearMin);
                frac = std::clamp(frac, 0.0, 1.0);

                double baseR = (currentGearNum == 1) ? 0.9 : 1.4;
                double topR = (currentGearNum == 5) ? 5.8 : 3.2;
                double calcRpm = baseR + frac * (topR - baseR);
                setRpm(std::round(calcRpm * 10.0) / 10.0);
            }
        }

        // =============================================================
        // INDIAN AIS-145 SPEED ALERT SYSTEM (Exter / Creta / Venue):
        // 1. At 80 km/h: 1 single warning chime + "Reduce speed" popup for 4.0s
        // 2. At 120 km/h: "Reduce speed" popup + continuous 1s beeping while >= 120 km/h
        // =============================================================
        if (m_speed >= 80 && prevSpeed < 80 && !m_speed80Triggered) {
            m_speed80Triggered = true;
            triggerReduceSpeedAlert();
            emit signalSpeedAlertChime();
        } else if (m_speed < 76) {
            m_speed80Triggered = false; // Reset 80 km/h trigger with hysteresis
        }

        if (m_speed >= 120) {
            if (prevSpeed < 120 && !m_speed120Triggered) {
                m_speed120Triggered = true;
                triggerReduceSpeedAlert();
                emit signalSpeedAlertChime();
            }

            if (!m_overspeedBeepTimer) {
                m_overspeedBeepTimer = new QTimer(this);
                connect(m_overspeedBeepTimer, &QTimer::timeout, this, &ClusterController::onOverspeedBeepTick);
            }
            if (!m_overspeedBeepTimer->isActive()) {
                m_overspeedBeepTimer->start(1000); // 1-second continuous chime intervals
                emit signalSpeedAlertChime();
            }
        } else {
            m_speed120Triggered = false;
            if (m_overspeedBeepTimer && m_overspeedBeepTimer->isActive()) {
                m_overspeedBeepTimer->stop();
            }
        }
    }
}
void ClusterController::setRpm(double r) { if (std::abs(m_rpm - r) > 0.01) { m_rpm = r; emit rpmChanged(); } }
void ClusterController::setFuelLevel(int f) {
    if (m_fuelLevel != f) {
        int oldLevel = m_fuelLevel;
        m_fuelLevel = f;
        emit fuelLevelChanged();

        // Calculate DTE (Range) based on remaining fuel in 37L tank and economy
        double remainingLitres = (f / 12.0) * 37.0;
        double effectiveEcon = m_refuelEconomy > 5.0 ? m_refuelEconomy : (m_accumEconomy > 5.0 ? m_accumEconomy : 15.5);
        int calculatedDte = static_cast<int>(std::round(remainingLitres * effectiveEcon));
        setDteKm(calculatedDte);

        // Auto-reset Since refuelling when fuel level increases (car refuelled)
        if (f > oldLevel) {
            resetSinceRefuel();
        }

        if (oldLevel > 2 && f <= 2 && m_clusterState == StateNormalTrip) {
            emit signalWarningChime();
        }
    }
}
void ClusterController::setTempLevel(int t) { if (m_tempLevel != t) { m_tempLevel = t; emit tempLevelChanged(); } }
void ClusterController::setGear(const QString& g) { if (m_gear != g) { m_gear = g; emit gearChanged(); } }
void ClusterController::setOdoKm(int odo) { if (m_odoKm != odo) { m_odoKm = odo; emit odoKmChanged(); } }
void ClusterController::setDteKm(int dte) { if (m_dteKm != dte) { m_dteKm = dte; emit dteKmChanged(); } }
void ClusterController::setAmbientTemp(int temp) { if (m_ambientTemp != temp) { m_ambientTemp = temp; emit ambientTempChanged(); } }
void ClusterController::setTripKm(double km) { m_tripKm = km; emit tripKmChanged(); }
void ClusterController::setTripTime(const QString& time) { if (m_tripTime != time) { m_tripTime = time; emit tripTimeChanged(); } }
void ClusterController::setTripEconomy(double econ) { m_tripEconomy = econ; emit tripEconomyChanged(); }
void ClusterController::setTripPage(int page) { int p = (page % 3 + 3) % 3; if (m_tripPage != p) { m_tripPage = p; emit tripPageChanged(); } }
void ClusterController::nextTripPage() { setTripPage(m_tripPage + 1); }
void ClusterController::prevTripPage() { setTripPage(m_tripPage - 1); }

void ClusterController::setRefuelKm(double km) { m_refuelKm = km; emit refuelKmChanged(); }
void ClusterController::setRefuelTime(const QString& time) { if (m_refuelTime != time) { m_refuelTime = time; emit refuelTimeChanged(); } }
void ClusterController::setRefuelEconomy(double econ) { m_refuelEconomy = econ; emit refuelEconomyChanged(); }

void ClusterController::setAccumKm(double km) { m_accumKm = km; emit accumKmChanged(); }
void ClusterController::setAccumTime(const QString& time) { if (m_accumTime != time) { m_accumTime = time; emit accumTimeChanged(); } }
void ClusterController::setAccumEconomy(double econ) { m_accumEconomy = econ; emit accumEconomyChanged(); }
void ClusterController::setInstantEconomy(double econ) { if (std::abs(m_instantEconomy - econ) > 0.01) { m_instantEconomy = std::clamp(econ, 0.0, 30.0); emit instantEconomyChanged(); } }
void ClusterController::setMenuTab(int tab) { int t = (tab % 3 + 3) % 3; if (m_menuTab != t) { m_menuTab = t; emit menuTabChanged(); } }
void ClusterController::setShowMenuTabs(bool show) { if (m_showMenuTabs != show) { m_showMenuTabs = show; emit showMenuTabsChanged(); } }
void ClusterController::nextMenuTab() { setMenuTab(m_menuTab + 1); setShowMenuTabs(true); }
void ClusterController::triggerInfoMenu() {
    if (!m_showMenuTabs) {
        setShowMenuTabs(true);
    } else {
        nextMenuTab();
    }
}

void ClusterController::setFlPsi(double psi) {
    if (std::abs(m_flPsi - psi) > 0.1) {
        m_flPsi = psi;
        emit flPsiChanged();
        bool anyLow = (m_flPsi < 32.0 || m_frPsi < 32.0 || m_rlPsi < 32.0 || m_rrPsi < 32.0);
        setTpmsActive(anyLow);
    }
}
void ClusterController::setFrPsi(double psi) {
    if (std::abs(m_frPsi - psi) > 0.1) {
        m_frPsi = psi;
        emit frPsiChanged();
        bool anyLow = (m_flPsi < 32.0 || m_frPsi < 32.0 || m_rlPsi < 32.0 || m_rrPsi < 32.0);
        setTpmsActive(anyLow);
    }
}
void ClusterController::setRlPsi(double psi) {
    if (std::abs(m_rlPsi - psi) > 0.1) {
        m_rlPsi = psi;
        emit rlPsiChanged();
        bool anyLow = (m_flPsi < 32.0 || m_frPsi < 32.0 || m_rlPsi < 32.0 || m_rrPsi < 32.0);
        setTpmsActive(anyLow);
    }
}
void ClusterController::setRrPsi(double psi) {
    if (std::abs(m_rrPsi - psi) > 0.1) {
        m_rrPsi = psi;
        emit rrPsiChanged();
        bool anyLow = (m_flPsi < 32.0 || m_frPsi < 32.0 || m_rlPsi < 32.0 || m_rrPsi < 32.0);
        setTpmsActive(anyLow);
    }
}
void ClusterController::setAllPsi(double psi) {
    double clamped = std::clamp(psi, 15.0, 50.0);
    setFlPsi(clamped);
    setFrPsi(clamped);
    setRlPsi(clamped);
    setRrPsi(clamped);
}

void ClusterController::adjustPsi(const QString& tyre, double delta) {
    if (tyre.compare("FL", Qt::CaseInsensitive) == 0) {
        setFlPsi(std::clamp(m_flPsi + delta, 15.0, 50.0));
    } else if (tyre.compare("FR", Qt::CaseInsensitive) == 0) {
        setFrPsi(std::clamp(m_frPsi + delta, 15.0, 50.0));
    } else if (tyre.compare("RL", Qt::CaseInsensitive) == 0) {
        setRlPsi(std::clamp(m_rlPsi + delta, 15.0, 50.0));
    } else if (tyre.compare("RR", Qt::CaseInsensitive) == 0) {
        setRrPsi(std::clamp(m_rrPsi + delta, 15.0, 50.0));
    } else if (tyre.compare("ALL", Qt::CaseInsensitive) == 0) {
        setFlPsi(std::clamp(m_flPsi + delta, 15.0, 50.0));
        setFrPsi(std::clamp(m_frPsi + delta, 15.0, 50.0));
        setRlPsi(std::clamp(m_rlPsi + delta, 15.0, 50.0));
        setRrPsi(std::clamp(m_rrPsi + delta, 15.0, 50.0));
    }
}

void ClusterController::resetTpms() {
    setAllPsi(35.0);
    setTpmsCalibrated(true);
}

void ClusterController::setTpmsCalibrated(bool cal) {
    if (m_tpmsCalibrated != cal) {
        m_tpmsCalibrated = cal;
        emit tpmsCalibratedChanged();
    }
}

void ClusterController::setParkBrakeActive(bool active) { if (m_parkBrakeActive != active) { m_parkBrakeActive = active; emit parkBrakeActiveChanged(); } }
void ClusterController::setSeatbeltActive(bool active) { if (m_seatbeltActive != active) { m_seatbeltActive = active; emit seatbeltActiveChanged(); } }
void ClusterController::setAbsActive(bool active) { if (m_absActive != active) { m_absActive = active; emit absActiveChanged(); } }
void ClusterController::setTpmsActive(bool active) {
    if (m_tpmsActive != active) {
        m_tpmsActive = active;
        emit tpmsActiveChanged();

        if (active && m_clusterState == StateNormalTrip) {
            // Automatically switch to TPMS Tyre Pressure page (Tab 2)
            setMenuTab(2);
            setShowMenuTabs(true);

            // Auto-return to Current trip page (Tab 0) after 5 seconds
            if (!m_tpmsDismissTimer) {
                m_tpmsDismissTimer = new QTimer(this);
                m_tpmsDismissTimer->setSingleShot(true);
                connect(m_tpmsDismissTimer, &QTimer::timeout, this, &ClusterController::onTpmsDismissTimeout);
            }
            m_tpmsDismissTimer->start(5000);
        }
    }
}
void ClusterController::setBatteryActive(bool active) { if (m_batteryActive != active) { m_batteryActive = active; emit batteryActiveChanged(); } }
void ClusterController::setOilActive(bool active) { if (m_oilActive != active) { m_oilActive = active; emit oilActiveChanged(); } }
void ClusterController::setLeftIndicator(bool active) { if (m_leftIndicator != active) { m_leftIndicator = active; emit leftIndicatorChanged(); } }
void ClusterController::setRightIndicator(bool active) { if (m_rightIndicator != active) { m_rightIndicator = active; emit rightIndicatorChanged(); } }
void ClusterController::setHighBeam(bool active) { if (m_highBeam != active) { m_highBeam = active; emit highBeamChanged(); } }
void ClusterController::setLowBeam(bool active) { if (m_lowBeam != active) { m_lowBeam = active; emit lowBeamChanged(); } }
void ClusterController::setPositionLamp(bool active) { if (m_positionLamp != active) { m_positionLamp = active; emit positionLampChanged(); } }
void ClusterController::setMasterWarning(bool active) { if (m_masterWarning != active) { m_masterWarning = active; emit masterWarningChanged(); } }
void ClusterController::setLightWarning(bool active) { if (m_lightWarning != active) { m_lightWarning = active; emit lightWarningChanged(); } }
void ClusterController::setEscActive(bool active) { if (m_escActive != active) { m_escActive = active; emit escActiveChanged(); } }
void ClusterController::setEscOffActive(bool active) { if (m_escOffActive != active) { m_escOffActive = active; emit escOffActiveChanged(); } }
void ClusterController::setCheckEngineActive(bool active) { if (m_checkEngineActive != active) { m_checkEngineActive = active; emit checkEngineActiveChanged(); } }
void ClusterController::setSmartKeyActive(bool active) { if (m_smartKeyActive != active) { m_smartKeyActive = active; emit smartKeyActiveChanged(); } }
void ClusterController::setSteeringActive(bool active) { if (m_steeringActive != active) { m_steeringActive = active; emit steeringActiveChanged(); } }
void ClusterController::setAirbagActive(bool active) { if (m_airbagActive != active) { m_airbagActive = active; emit airbagActiveChanged(); } }

void ClusterController::setAllTelltales(bool active)
{
    setParkBrakeActive(active);
    setSeatbeltActive(active);
    setAbsActive(active);
    setTpmsActive(active);
    setBatteryActive(active);
    setOilActive(active);
    setLeftIndicator(active);
    setRightIndicator(active);
    setHighBeam(active);
    setLowBeam(active);
    setPositionLamp(active);
    setMasterWarning(active);
    setLightWarning(active);
    setEscActive(active);
    setEscOffActive(active);
    setCheckEngineActive(active);
    setSmartKeyActive(active);
    setSteeringActive(active);
    setAirbagActive(active);
}

void ClusterController::setBulbCheckTelltales(bool active)
{
    // ALL telltales around Speedometer and Tachometer turn ON during System Check:
    setParkBrakeActive(active);
    setSeatbeltActive(active);
    setAbsActive(active);
    setTpmsActive(active);
    setSmartKeyActive(active);
    setMasterWarning(active);

    setSteeringActive(active);
    setBatteryActive(active);
    setAirbagActive(active);
    setOilActive(active);
    setEscActive(active);
    setEscOffActive(active);
    setCheckEngineActive(active);

    // Upper turn signals and lighting indicators remain OFF during bulb check:
    setLeftIndicator(false);
    setRightIndicator(false);
    setHighBeam(false);
    setLowBeam(m_lightMode == 3);
    setPositionLamp(m_lightMode == 2 || m_lightMode == 3);
    setLightWarning(false);
}

void ClusterController::setIsInteractiveMode(bool interactive) { if (m_isInteractiveMode != interactive) { m_isInteractiveMode = interactive; emit isInteractiveModeChanged(); } }

void ClusterController::setRearLeftBuckled(bool buckled) {
    if (m_rearLeftBuckled != buckled) {
        m_rearLeftBuckled = buckled;
        emit rearLeftBuckledChanged();
        if (!buckled) {
            triggerRearAlarm(0);
        } else if (m_rearAlarmSeat == 0) {
            stopRearAlarm();
        }
    }
}

void ClusterController::setRearCenterBuckled(bool buckled) {
    if (m_rearCenterBuckled != buckled) {
        m_rearCenterBuckled = buckled;
        emit rearCenterBuckledChanged();
        if (!buckled) {
            triggerRearAlarm(1);
        } else if (m_rearAlarmSeat == 1) {
            stopRearAlarm();
        }
    }
}

void ClusterController::setRearRightBuckled(bool buckled) {
    if (m_rearRightBuckled != buckled) {
        m_rearRightBuckled = buckled;
        emit rearRightBuckledChanged();
        if (!buckled) {
            triggerRearAlarm(2);
        } else if (m_rearAlarmSeat == 2) {
            stopRearAlarm();
        }
    }
}

void ClusterController::triggerRearAlarm(int seat) {
    m_rearAlarmSeat = seat;
    emit rearAlarmSeatChanged();
    m_rearAlarmActive = true;
    emit rearAlarmActiveChanged();

    // Blink timer and 10s alarm timer
    m_rearSeatBlinkState = true;
    emit rearSeatBlinkStateChanged();
    if (m_rearBlinkTimer) m_rearBlinkTimer->start();
    if (m_rearAlarmTimer) m_rearAlarmTimer->start(10000); // 10 seconds

    // Play chime sound
    emit signalPlayChime();
}

void ClusterController::stopRearAlarm() {
    m_rearAlarmActive = false;
    emit rearAlarmActiveChanged();
    m_rearSeatBlinkState = false;
    emit rearSeatBlinkStateChanged();
    if (m_rearBlinkTimer) m_rearBlinkTimer->stop();
    if (m_rearAlarmTimer) m_rearAlarmTimer->stop();
}

void ClusterController::onRearBlinkTick() {
    m_rearSeatBlinkState = !m_rearSeatBlinkState;
    emit rearSeatBlinkStateChanged();
}

void ClusterController::onRearAlarmTimeout() {
    stopRearAlarm();
}

void ClusterController::setLanguage(const QString& lang) {
    if (m_language != lang) {
        m_language = lang;
        emit languageChanged();
    }
}

void ClusterController::setDriverAttentionActive(bool active) {
    if (m_driverAttentionActive != active) {
        m_driverAttentionActive = active;
        emit driverAttentionActiveChanged();
        if (active) emit signalPlayChime();
    }
}

void ClusterController::setAttentionLevel(int level) {
    if (m_attentionLevel != level) {
        m_attentionLevel = qBound(1, level, 5);
        emit attentionLevelChanged();
    }
}

void ClusterController::triggerDriverAttention() {
    setAttentionLevel(1);
    setDriverAttentionActive(true);
}

void ClusterController::setServiceDueKm(int km) {
    if (m_serviceDueKm != km) {
        m_serviceDueKm = km;
        emit serviceDueKmChanged();
    }
}

void ClusterController::setServiceDueDays(int days) {
    if (m_serviceDueDays != days) {
        m_serviceDueDays = days;
        emit serviceDueDaysChanged();
    }
}

void ClusterController::setServicePopupActive(bool active) {
    if (m_servicePopupActive != active) {
        m_servicePopupActive = active;
        emit servicePopupActiveChanged();
        if (active) emit signalPlayChime();
    }
}

void ClusterController::triggerServiceReminder() {
    setServicePopupActive(true);
}

void ClusterController::resetServiceInterval() {
    setServiceDueKm(10000);
    setServiceDueDays(365);
    setServicePopupActive(false);
}

void ClusterController::setSunroofOpen(bool open) {
    if (m_sunroofOpen != open) {
        m_sunroofOpen = open;
        emit sunroofOpenChanged();
    }
}

void ClusterController::setSunroofAlertActive(bool active) {
    if (m_sunroofAlertActive != active) {
        m_sunroofAlertActive = active;
        emit sunroofAlertActiveChanged();
        if (active) emit signalPlayChime();
    }
}

void ClusterController::setSmartKeyPrompt(int prompt) {
    if (m_smartKeyPrompt != prompt) {
        m_smartKeyPrompt = prompt;
        emit smartKeyPromptChanged();
        if (prompt > 0) emit signalPlayChime();
    }
}

void ClusterController::showSmartKeyAlert(int type) {
    setSmartKeyPrompt(type);
}

void ClusterController::setIsgActive(bool active) {
    if (m_isgActive != active) {
        m_isgActive = active;
        emit isgActiveChanged();
    }
}

void ClusterController::toggleIsg() {
    setIsgActive(!m_isgActive);
}

void ClusterController::triggerShutdown() {
    setClusterState(StateShutdown);
    setSpeed(0);
    setRpm(0.0);
    setAllTelltales(false);

    // Play authentic Hyundai Goodbye Chime
    emit signalGoodbyeChime();

    if (m_sunroofOpen) {
        setSunroofAlertActive(true);
    }

    if (!m_shutdownTimer) {
        m_shutdownTimer = new QTimer(this);
        m_shutdownTimer->setSingleShot(true);
        connect(m_shutdownTimer, &QTimer::timeout, this, &ClusterController::onShutdownTimeout);
    }
    m_shutdownTimer->start(4500); // 4.5s goodbye screen
}

void ClusterController::onShutdownTimeout() {
    setSunroofAlertActive(false);
    setClusterState(StateOff);
}

void ClusterController::setReduceSpeedAlert(bool active) {
    if (m_reduceSpeedAlert != active) {
        m_reduceSpeedAlert = active;
        emit reduceSpeedAlertChanged();
        if (active) emit signalPlayChime();
    }
}

void ClusterController::triggerReduceSpeedAlert() {
    setReduceSpeedAlert(true);

    if (!m_reduceSpeedDismissTimer) {
        m_reduceSpeedDismissTimer = new QTimer(this);
        m_reduceSpeedDismissTimer->setSingleShot(true);
        connect(m_reduceSpeedDismissTimer, &QTimer::timeout, this, &ClusterController::onReduceSpeedDismissTimeout);
    }
    m_reduceSpeedDismissTimer->start(4000); // 4.0s popup display
}

void ClusterController::onReduceSpeedDismissTimeout() {
    setReduceSpeedAlert(false);
}

void ClusterController::onOverspeedBeepTick() {
    if (m_speed >= 120) {
        emit signalSpeedAlertChime();
    }
}

void ClusterController::onTpmsDismissTimeout() {
    if (m_clusterState == StateNormalTrip && m_menuTab == 2) {
        setMenuTab(0); // Return smoothly to Current Trip (Tab 0)
        setShowMenuTabs(false);
    }
}

void ClusterController::setPressStartAgainAlert(bool active) {
    if (m_pressStartAgainAlert != active) {
        m_pressStartAgainAlert = active;
        emit pressStartAgainAlertChanged();
        if (active) emit signalKeyAlertChime();
    }
}

void ClusterController::setStartPedalPrompt(int prompt) {
    if (m_startPedalPrompt != prompt) {
        m_startPedalPrompt = prompt;
        emit startPedalPromptChanged();
        if (prompt > 0) emit signalKeyAlertChime();
    }
}

void ClusterController::setDoorOpenAlert(bool open) {
    if (m_doorOpenAlert != open) {
        m_doorOpenAlert = open;
        if (!open) {
            setAllDoors(false);
        } else if (!isAnyDoorOpen()) {
            setDoorFrontRight(true); // Default driver door
        }
        emit doorOpenAlertChanged();
        if (open) emit signalWarningChime();
    }
}

void ClusterController::setDoorOpenSide(int side) {
    if (m_doorOpenSide != side) {
        m_doorOpenSide = side;
        if (side == 1) { // Driver (FR)
            m_doorFrontRight = true; m_doorFrontLeft = false; m_doorRearLeft = false; m_doorRearRight = false;
        } else if (side == 2) { // Passenger (FL)
            m_doorFrontLeft = true; m_doorFrontRight = false; m_doorRearLeft = false; m_doorRearRight = false;
        } else if (side == 3) { // Front Both
            m_doorFrontLeft = true; m_doorFrontRight = true; m_doorRearLeft = false; m_doorRearRight = false;
        } else if (side == 0) {
            setAllDoors(false);
        }
        m_doorOpenAlert = isAnyDoorOpen();
        emit doorFrontLeftChanged();
        emit doorFrontRightChanged();
        emit doorRearLeftChanged();
        emit doorRearRightChanged();
        emit doorOpenSideChanged();
        emit doorOpenAlertChanged();
        if (side > 0) emit signalPlayChime();
    }
}

void ClusterController::setDoorFrontLeft(bool open) {
    if (m_doorFrontLeft != open) {
        m_doorFrontLeft = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit doorFrontLeftChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setDoorFrontRight(bool open) {
    if (m_doorFrontRight != open) {
        m_doorFrontRight = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit doorFrontRightChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setDoorRearLeft(bool open) {
    if (m_doorRearLeft != open) {
        m_doorRearLeft = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit doorRearLeftChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setDoorRearRight(bool open) {
    if (m_doorRearRight != open) {
        m_doorRearRight = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit doorRearRightChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setBonnetOpen(bool open) {
    if (m_bonnetOpen != open) {
        m_bonnetOpen = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit bonnetOpenChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setTrunkOpen(bool open) {
    if (m_trunkOpen != open) {
        m_trunkOpen = open;
        m_doorOpenAlert = isAnyDoorOpen();
        emit trunkOpenChanged();
        emit doorOpenAlertChanged();
        if (open) emit signalPlayChime();
    }
}

void ClusterController::setAllDoors(bool open) {
    m_doorFrontLeft = open;
    m_doorFrontRight = open;
    m_doorRearLeft = open;
    m_doorRearRight = open;
    m_bonnetOpen = open;
    m_trunkOpen = open;
    m_doorOpenAlert = open;
    emit doorFrontLeftChanged();
    emit doorFrontRightChanged();
    emit doorRearLeftChanged();
    emit doorRearRightChanged();
    emit bonnetOpenChanged();
    emit trunkOpenChanged();
    emit doorOpenAlertChanged();
    if (open) emit signalPlayChime();
}

struct MediaTrack {
    QString source;
    QString artist;
    QString title;
};

static const std::vector<MediaTrack> s_playlist = {
    { "USB", "Revoic", "Sunset Drive" },
    { "Bluetooth", "The Weeknd", "Blinding Lights (After Hours)" },
    { "Apple CarPlay", "Dua Lipa", "Levitating (Club Future Nostalgia)" },
    { "Android Auto", "A.R. Rahman", "Dil Se Re (Original Soundtrack)" },
    { "Bluetooth", "Arijit Singh", "Kesariya (Brahmastra Audio)" },
    { "USB", "Coldplay", "Viva La Vida" },
    { "FM Radio", "Radio Mirchi 98.3 FM", "Top Bollywood Hits Live" }
};

void ClusterController::setShowMediaPopup(bool show) {
    if (m_showMediaPopup != show) {
        m_showMediaPopup = show;
        emit showMediaPopupChanged();
    }
}

void ClusterController::setMediaSource(const QString& source) {
    if (m_mediaSource != source) {
        m_mediaSource = source;
        emit mediaSourceChanged();
    }
}

void ClusterController::setMediaTitle(const QString& title) {
    if (m_mediaTitle != title) {
        m_mediaTitle = title;
        emit mediaTitleChanged();
    }
}

void ClusterController::setMediaArtist(const QString& artist) {
    if (m_mediaArtist != artist) {
        m_mediaArtist = artist;
        emit mediaArtistChanged();
    }
}

void ClusterController::setIsMediaPlaying(bool playing) {
    if (m_isMediaPlaying != playing) {
        m_isMediaPlaying = playing;
        emit isMediaPlayingChanged();
    }
}

void ClusterController::setMediaTrackIndex(int index) {
    if (m_mediaTrackIndex != index) {
        m_mediaTrackIndex = index;
        emit mediaTrackIndexChanged();
    }
}

void ClusterController::onMediaPopupTimeout() {
    setShowMediaPopup(false);
}

void ClusterController::triggerMediaPopup() {
    setShowMediaPopup(true);
    if (!m_mediaPopupTimer) {
        m_mediaPopupTimer = new QTimer(this);
        m_mediaPopupTimer->setSingleShot(true);
        connect(m_mediaPopupTimer, &QTimer::timeout, this, &ClusterController::onMediaPopupTimeout);
    }
    m_mediaPopupTimer->start(5000); // 5 seconds display duration
}

void ClusterController::dismissMediaPopup() {
    if (m_mediaPopupTimer && m_mediaPopupTimer->isActive()) {
        m_mediaPopupTimer->stop();
    }
    setShowMediaPopup(false);
}

void ClusterController::playTrack(const QString& source, const QString& artist, const QString& title) {
    setMediaSource(source);
    setMediaArtist(artist);
    setMediaTitle(title);
    setIsMediaPlaying(true);
    triggerMediaPopup();
}

void ClusterController::nextMediaTrack() {
    m_mediaTrackIndex = (m_mediaTrackIndex + 1) % s_playlist.size();
    emit mediaTrackIndexChanged();
    const auto& track = s_playlist[m_mediaTrackIndex];
    playTrack(track.source, track.artist, track.title);
}

void ClusterController::prevMediaTrack() {
    m_mediaTrackIndex = (m_mediaTrackIndex - 1 + s_playlist.size()) % s_playlist.size();
    emit mediaTrackIndexChanged();
    const auto& track = s_playlist[m_mediaTrackIndex];
    playTrack(track.source, track.artist, track.title);
}

void ClusterController::toggleMediaPlayback() {
    setIsMediaPlaying(!m_isMediaPlaying);
    triggerMediaPopup();
}
