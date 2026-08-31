#include "ClusterController.h"
#include <cmath>

ClusterController::ClusterController(QObject *parent)
    : QObject(parent)
{
    connect(&m_sequenceTimer, &QTimer::timeout, this, &ClusterController::onSequenceStep);
    connect(&m_driveSimTimer, &QTimer::timeout, this, &ClusterController::onDriveSimulationTick);
    m_driveSimTimer.start(33); // ~30 FPS telemetry simulation
}

void ClusterController::triggerStartupSequence()
{
    m_sequenceStepIndex = 1;
    setClusterState(StateInitialStartup);

    // Initial state: Everything dark except frame + Odo
    setSpeed(0);
    setRpm(0.0);
    setParkBrakeActive(false);
    setSeatbeltActive(false);
    setAbsActive(false);
    setTpmsActive(false);
    setBatteryActive(false);
    setOilActive(false);
    setCheckEngineActive(false);
    setEscOffActive(false);

    m_sequenceTimer.start(1500); // 1.5s in State 1
}

void ClusterController::onSequenceStep()
{
    if (m_sequenceStepIndex == 1) {
        // Transition to State 2: Boot / System check
        m_sequenceStepIndex = 2;
        setClusterState(StateBootCheck);

        // Turn on all bulb check telltales
        setParkBrakeActive(true);
        setSeatbeltActive(true);
        setAbsActive(true);
        setTpmsActive(true);
        setBatteryActive(true);
        setOilActive(true);
        setCheckEngineActive(true);
        setEscOffActive(true);

        m_sequenceTimer.start(5000); // 5.0s in State 2 (System check)
    }
    else if (m_sequenceStepIndex == 2) {
        // Transition to State 3: Normal Driving / Current trip
        m_sequenceStepIndex = 3;
        setClusterState(StateNormalTrip);

        // Turn off system check telltales, keep operational ones
        setAbsActive(false);
        setTpmsActive(false);
        setCheckEngineActive(false);
        setEscOffActive(false);
        setParkBrakeActive(true);
        setSeatbeltActive(true);
        setBatteryActive(true);
        setOilActive(true);

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
    setTripKm(0.0);
    setTripTime("0:00");
    setTripEconomy(0.0);
}

void ClusterController::driveDemo()
{
    m_isDemoDriving = !m_isDemoDriving;
    if (m_isDemoDriving) {
        setGear("D");
        setParkBrakeActive(false);
        setBatteryActive(false);
        setOilActive(false);
        setSeatbeltActive(false);
    } else {
        setGear("N");
        setParkBrakeActive(true);
        setBatteryActive(true);
        setOilActive(true);
        setSeatbeltActive(true);
    }
}

void ClusterController::onDriveSimulationTick()
{
    if (m_isDemoDriving && m_clusterState == StateNormalTrip) {
        static double t = 0.0;
        t += 0.033;

        // Realistic driving wave for speed & RPM
        double targetSpeed = 48.0 + 35.0 * std::sin(t * 0.4) + 12.0 * std::sin(t * 0.85);
        if (targetSpeed < 0) targetSpeed = 0;

        double currentSpeed = m_speed + (targetSpeed - m_speed) * 0.08;
        int nextSpeed = static_cast<int>(std::round(currentSpeed));
        setSpeed(nextSpeed);

        // Simulated Exter 1.2L Kappa AMT RPM curve with gear shifts
        int currentGearNum = 1;
        if (nextSpeed <= 15) currentGearNum = 1;
        else if (nextSpeed <= 32) currentGearNum = 2;
        else if (nextSpeed <= 55) currentGearNum = 3;
        else if (nextSpeed <= 78) currentGearNum = 4;
        else currentGearNum = 5;

        // Realistic RPM curve per gear
        double gearMinSpeed = (currentGearNum == 1) ? 0 : (currentGearNum == 2 ? 15 : (currentGearNum == 3 ? 32 : (currentGearNum == 4 ? 55 : 78)));
        double gearMaxSpeed = (currentGearNum == 1) ? 20 : (currentGearNum == 2 ? 38 : (currentGearNum == 3 ? 62 : (currentGearNum == 4 ? 85 : 160)));
        double fraction = (nextSpeed - gearMinSpeed) / std::max(1.0, gearMaxSpeed - gearMinSpeed);
        fraction = std::clamp(fraction, 0.0, 1.0);
        double calculatedRpm = 1.0 + fraction * 2.6;
        if (calculatedRpm < 0.8) calculatedRpm = 0.8;
        setRpm(calculatedRpm);

        // Update trip stats
        double newTrip = m_tripKm + (currentSpeed / 3600.0) * 0.033 * 5.0; // accelerated demo
        setTripKm(std::round(newTrip * 10.0) / 10.0);

        int totalSeconds = static_cast<int>(t * 4.0);
        int mins = (totalSeconds / 60) % 60;
        int hours = totalSeconds / 3600;
        char timeBuf[32];
        std::snprintf(timeBuf, sizeof(timeBuf), "%d:%02d", hours, mins);
        setTripTime(QString::fromUtf8(timeBuf));

        double econ = 16.4 + 2.2 * std::sin(t * 0.2);
        setTripEconomy(std::round(econ * 10.0) / 10.0);
    }
}

void ClusterController::setThemeColor(const QString& color) { if (m_themeColor != color) { m_themeColor = color; emit themeColorChanged(); } }
void ClusterController::setClusterState(int state) { if (m_clusterState != state) { m_clusterState = state; emit clusterStateChanged(); } }

void ClusterController::setSpeed(int s)
{
    if (m_speed != s) {
        m_speed = s;
        emit speedChanged();

        // When in Drive or numbered gears, display direct gear 1-5 as speed increases
        bool isDriveMode = (m_gear == "D" || m_gear == "1" || m_gear == "2" || m_gear == "3" || m_gear == "4" || m_gear == "5");
        if (isDriveMode) {
            QString targetGear = "D";
            if (m_speed == 0) targetGear = "D";
            else if (m_speed <= 15) targetGear = "1";
            else if (m_speed <= 32) targetGear = "2";
            else if (m_speed <= 55) targetGear = "3";
            else if (m_speed <= 78) targetGear = "4";
            else targetGear = "5";

            if (m_gear != targetGear) {
                setGear(targetGear);
            }
        }
    }
}
void ClusterController::setRpm(double r) { if (std::abs(m_rpm - r) > 0.01) { m_rpm = r; emit rpmChanged(); } }
void ClusterController::setFuelLevel(int f) { if (m_fuelLevel != f) { m_fuelLevel = f; emit fuelLevelChanged(); } }
void ClusterController::setTempLevel(int t) { if (m_tempLevel != t) { m_tempLevel = t; emit tempLevelChanged(); } }
void ClusterController::setGear(const QString& g) { if (m_gear != g) { m_gear = g; emit gearChanged(); } }
void ClusterController::setOdoKm(int odo) { if (m_odoKm != odo) { m_odoKm = odo; emit odoKmChanged(); } }
void ClusterController::setDteKm(int dte) { if (m_dteKm != dte) { m_dteKm = dte; emit dteKmChanged(); } }
void ClusterController::setAmbientTemp(int temp) { if (m_ambientTemp != temp) { m_ambientTemp = temp; emit ambientTempChanged(); } }
void ClusterController::setTripKm(double km) { if (std::abs(m_tripKm - km) > 0.01) { m_tripKm = km; emit tripKmChanged(); } }
void ClusterController::setTripTime(const QString& time) { if (m_tripTime != time) { m_tripTime = time; emit tripTimeChanged(); } }
void ClusterController::setTripEconomy(double econ) { if (std::abs(m_tripEconomy - econ) > 0.01) { m_tripEconomy = econ; emit tripEconomyChanged(); } }
void ClusterController::setTripPage(int page) { int p = (page % 3 + 3) % 3; if (m_tripPage != p) { m_tripPage = p; emit tripPageChanged(); } }
void ClusterController::nextTripPage() { setTripPage(m_tripPage + 1); }
void ClusterController::prevTripPage() { setTripPage(m_tripPage - 1); }

void ClusterController::setRefuelKm(double km) { if (std::abs(m_refuelKm - km) > 0.01) { m_refuelKm = km; emit refuelKmChanged(); } }
void ClusterController::setRefuelTime(const QString& time) { if (m_refuelTime != time) { m_refuelTime = time; emit refuelTimeChanged(); } }
void ClusterController::setRefuelEconomy(double econ) { if (std::abs(m_refuelEconomy - econ) > 0.01) { m_refuelEconomy = econ; emit refuelEconomyChanged(); } }

void ClusterController::setAccumKm(double km) { if (std::abs(m_accumKm - km) > 0.01) { m_accumKm = km; emit accumKmChanged(); } }
void ClusterController::setAccumTime(const QString& time) { if (m_accumTime != time) { m_accumTime = time; emit accumTimeChanged(); } }
void ClusterController::setAccumEconomy(double econ) { if (std::abs(m_accumEconomy - econ) > 0.01) { m_accumEconomy = econ; emit accumEconomyChanged(); } }
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
void ClusterController::setTpmsCalibrated(bool cal) {
    if (m_tpmsCalibrated != cal) {
        m_tpmsCalibrated = cal;
        emit tpmsCalibratedChanged();
    }
}

void ClusterController::setParkBrakeActive(bool active) { if (m_parkBrakeActive != active) { m_parkBrakeActive = active; emit parkBrakeActiveChanged(); } }
void ClusterController::setSeatbeltActive(bool active) { if (m_seatbeltActive != active) { m_seatbeltActive = active; emit seatbeltActiveChanged(); } }
void ClusterController::setAbsActive(bool active) { if (m_absActive != active) { m_absActive = active; emit absActiveChanged(); } }
void ClusterController::setTpmsActive(bool active) { if (m_tpmsActive != active) { m_tpmsActive = active; emit tpmsActiveChanged(); } }
void ClusterController::setBatteryActive(bool active) { if (m_batteryActive != active) { m_batteryActive = active; emit batteryActiveChanged(); } }
void ClusterController::setOilActive(bool active) { if (m_oilActive != active) { m_oilActive = active; emit oilActiveChanged(); } }
void ClusterController::setCheckEngineActive(bool active) { if (m_checkEngineActive != active) { m_checkEngineActive = active; emit checkEngineActiveChanged(); } }
void ClusterController::setEscOffActive(bool active) { if (m_escOffActive != active) { m_escOffActive = active; emit escOffActiveChanged(); } }
void ClusterController::setLeftIndicator(bool active) { if (m_leftIndicator != active) { m_leftIndicator = active; emit leftIndicatorChanged(); } }
void ClusterController::setRightIndicator(bool active) { if (m_rightIndicator != active) { m_rightIndicator = active; emit rightIndicatorChanged(); } }
void ClusterController::setHighBeam(bool active) { if (m_highBeam != active) { m_highBeam = active; emit highBeamChanged(); } }
void ClusterController::setIsInteractiveMode(bool interactive) { if (m_isInteractiveMode != interactive) { m_isInteractiveMode = interactive; emit isInteractiveModeChanged(); } }
