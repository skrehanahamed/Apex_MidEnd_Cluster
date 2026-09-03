/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           ClusterController.h
 * Author:         SK Rehan Ahamed
 * Description:    Automotive CAN / ECU Telemetry Controller Header
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QString>

class ClusterController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString themeColor READ themeColor WRITE setThemeColor NOTIFY themeColorChanged)
    Q_PROPERTY(int clusterState READ clusterState WRITE setClusterState NOTIFY clusterStateChanged)
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double rpm READ rpm WRITE setRpm NOTIFY rpmChanged)
    Q_PROPERTY(int fuelLevel READ fuelLevel WRITE setFuelLevel NOTIFY fuelLevelChanged)
    Q_PROPERTY(int tempLevel READ tempLevel WRITE setTempLevel NOTIFY tempLevelChanged)
    Q_PROPERTY(QString gear READ gear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(int odoKm READ odoKm WRITE setOdoKm NOTIFY odoKmChanged)
    Q_PROPERTY(int dteKm READ dteKm WRITE setDteKm NOTIFY dteKmChanged)
    Q_PROPERTY(int ambientTemp READ ambientTemp WRITE setAmbientTemp NOTIFY ambientTempChanged)
    Q_PROPERTY(double tripKm READ tripKm WRITE setTripKm NOTIFY tripKmChanged)
    Q_PROPERTY(QString tripTime READ tripTime WRITE setTripTime NOTIFY tripTimeChanged)
    Q_PROPERTY(double tripEconomy READ tripEconomy WRITE setTripEconomy NOTIFY tripEconomyChanged)
    Q_PROPERTY(int tripPage READ tripPage WRITE setTripPage NOTIFY tripPageChanged)
    Q_PROPERTY(double refuelKm READ refuelKm WRITE setRefuelKm NOTIFY refuelKmChanged)
    Q_PROPERTY(QString refuelTime READ refuelTime WRITE setRefuelTime NOTIFY refuelTimeChanged)
    Q_PROPERTY(double refuelEconomy READ refuelEconomy WRITE setRefuelEconomy NOTIFY refuelEconomyChanged)
    Q_PROPERTY(double accumKm READ accumKm WRITE setAccumKm NOTIFY accumKmChanged)
    Q_PROPERTY(QString accumTime READ accumTime WRITE setAccumTime NOTIFY accumTimeChanged)
    Q_PROPERTY(double accumEconomy READ accumEconomy WRITE setAccumEconomy NOTIFY accumEconomyChanged)
    Q_PROPERTY(double instantEconomy READ instantEconomy WRITE setInstantEconomy NOTIFY instantEconomyChanged)
    Q_PROPERTY(int menuTab READ menuTab WRITE setMenuTab NOTIFY menuTabChanged)
    Q_PROPERTY(bool showMenuTabs READ showMenuTabs WRITE setShowMenuTabs NOTIFY showMenuTabsChanged)

    Q_PROPERTY(double flPsi READ flPsi WRITE setFlPsi NOTIFY flPsiChanged)
    Q_PROPERTY(double frPsi READ frPsi WRITE setFrPsi NOTIFY frPsiChanged)
    Q_PROPERTY(double rlPsi READ rlPsi WRITE setRlPsi NOTIFY rlPsiChanged)
    Q_PROPERTY(double rrPsi READ rrPsi WRITE setRrPsi NOTIFY rrPsiChanged)
    Q_PROPERTY(bool tpmsCalibrated READ tpmsCalibrated WRITE setTpmsCalibrated NOTIFY tpmsCalibratedChanged)

    Q_PROPERTY(bool parkBrakeActive READ parkBrakeActive WRITE setParkBrakeActive NOTIFY parkBrakeActiveChanged)
    Q_PROPERTY(bool seatbeltActive READ seatbeltActive WRITE setSeatbeltActive NOTIFY seatbeltActiveChanged)
    Q_PROPERTY(bool absActive READ absActive WRITE setAbsActive NOTIFY absActiveChanged)
    Q_PROPERTY(bool tpmsActive READ tpmsActive WRITE setTpmsActive NOTIFY tpmsActiveChanged)
    Q_PROPERTY(bool batteryActive READ batteryActive WRITE setBatteryActive NOTIFY batteryActiveChanged)
    Q_PROPERTY(bool oilActive READ oilActive WRITE setOilActive NOTIFY oilActiveChanged)
    Q_PROPERTY(bool leftIndicator READ leftIndicator WRITE setLeftIndicator NOTIFY leftIndicatorChanged)
    Q_PROPERTY(bool rightIndicator READ rightIndicator WRITE setRightIndicator NOTIFY rightIndicatorChanged)
    Q_PROPERTY(bool highBeam READ highBeam WRITE setHighBeam NOTIFY highBeamChanged)
    Q_PROPERTY(bool lowBeam READ lowBeam WRITE setLowBeam NOTIFY lowBeamChanged)
    Q_PROPERTY(bool positionLamp READ positionLamp WRITE setPositionLamp NOTIFY positionLampChanged)
    Q_PROPERTY(bool masterWarning READ masterWarning WRITE setMasterWarning NOTIFY masterWarningChanged)
    Q_PROPERTY(bool lightWarning READ lightWarning WRITE setLightWarning NOTIFY lightWarningChanged)
    Q_PROPERTY(bool escActive READ escActive WRITE setEscActive NOTIFY escActiveChanged)
    Q_PROPERTY(bool escOffActive READ escOffActive WRITE setEscOffActive NOTIFY escOffActiveChanged)
    Q_PROPERTY(bool checkEngineActive READ checkEngineActive WRITE setCheckEngineActive NOTIFY checkEngineActiveChanged)
    Q_PROPERTY(bool smartKeyActive READ smartKeyActive WRITE setSmartKeyActive NOTIFY smartKeyActiveChanged)
    Q_PROPERTY(bool steeringActive READ steeringActive WRITE setSteeringActive NOTIFY steeringActiveChanged)
    Q_PROPERTY(bool airbagActive READ airbagActive WRITE setAirbagActive NOTIFY airbagActiveChanged)
    Q_PROPERTY(bool isInteractiveMode READ isInteractiveMode WRITE setIsInteractiveMode NOTIFY isInteractiveModeChanged)
    Q_PROPERTY(bool isDemoDriving READ isDemoDriving NOTIFY isDemoDrivingChanged)
    Q_PROPERTY(QString demoScenario READ demoScenario NOTIFY demoScenarioChanged)
    Q_PROPERTY(QString tempUnit READ tempUnit WRITE setTempUnit NOTIFY tempUnitChanged)
    Q_PROPERTY(QString fuelUnit READ fuelUnit WRITE setFuelUnit NOTIFY fuelUnitChanged)
    Q_PROPERTY(QString tpmsUnit READ tpmsUnit WRITE setTpmsUnit NOTIFY tpmsUnitChanged)
    Q_PROPERTY(int illumination READ illumination WRITE setIllumination NOTIFY illuminationChanged)
    Q_PROPERTY(bool cruiseEnabled READ cruiseEnabled WRITE setCruiseEnabled NOTIFY cruiseEnabledChanged)
    Q_PROPERTY(bool cruiseActive READ cruiseActive WRITE setCruiseActive NOTIFY cruiseActiveChanged)
    Q_PROPERTY(int cruiseSetSpeed READ cruiseSetSpeed WRITE setCruiseSetSpeed NOTIFY cruiseSetSpeedChanged)
    Q_PROPERTY(int lightMode READ lightMode WRITE setLightMode NOTIFY lightModeChanged)
    Q_PROPERTY(bool showLightPopup READ showLightPopup WRITE setShowLightPopup NOTIFY showLightPopupChanged)
    Q_PROPERTY(bool rearLeftBuckled READ rearLeftBuckled WRITE setRearLeftBuckled NOTIFY rearLeftBuckledChanged)
    Q_PROPERTY(bool rearCenterBuckled READ rearCenterBuckled WRITE setRearCenterBuckled NOTIFY rearCenterBuckledChanged)
    Q_PROPERTY(bool rearRightBuckled READ rearRightBuckled WRITE setRearRightBuckled NOTIFY rearRightBuckledChanged)
    Q_PROPERTY(bool rearAlarmActive READ rearAlarmActive NOTIFY rearAlarmActiveChanged)
    Q_PROPERTY(int rearAlarmSeat READ rearAlarmSeat NOTIFY rearAlarmSeatChanged)
    Q_PROPERTY(bool rearSeatBlinkState READ rearSeatBlinkState NOTIFY rearSeatBlinkStateChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

    // Manual Cluster Features:
    Q_PROPERTY(bool driverAttentionActive READ driverAttentionActive WRITE setDriverAttentionActive NOTIFY driverAttentionActiveChanged)
    Q_PROPERTY(int attentionLevel READ attentionLevel WRITE setAttentionLevel NOTIFY attentionLevelChanged)
    Q_PROPERTY(int serviceDueKm READ serviceDueKm WRITE setServiceDueKm NOTIFY serviceDueKmChanged)
    Q_PROPERTY(int serviceDueDays READ serviceDueDays WRITE setServiceDueDays NOTIFY serviceDueDaysChanged)
    Q_PROPERTY(bool servicePopupActive READ servicePopupActive WRITE setServicePopupActive NOTIFY servicePopupActiveChanged)
    Q_PROPERTY(bool sunroofOpen READ sunroofOpen WRITE setSunroofOpen NOTIFY sunroofOpenChanged)
    Q_PROPERTY(bool sunroofAlertActive READ sunroofAlertActive WRITE setSunroofAlertActive NOTIFY sunroofAlertActiveChanged)
    Q_PROPERTY(int smartKeyPrompt READ smartKeyPrompt WRITE setSmartKeyPrompt NOTIFY smartKeyPromptChanged)
    Q_PROPERTY(bool isgActive READ isgActive WRITE setIsgActive NOTIFY isgActiveChanged)
    Q_PROPERTY(bool reduceSpeedAlert READ reduceSpeedAlert WRITE setReduceSpeedAlert NOTIFY reduceSpeedAlertChanged)
    Q_PROPERTY(bool pressStartAgainAlert READ pressStartAgainAlert WRITE setPressStartAgainAlert NOTIFY pressStartAgainAlertChanged)
    Q_PROPERTY(int startPedalPrompt READ startPedalPrompt WRITE setStartPedalPrompt NOTIFY startPedalPromptChanged)
    Q_PROPERTY(bool doorOpenAlert READ doorOpenAlert WRITE setDoorOpenAlert NOTIFY doorOpenAlertChanged)
    Q_PROPERTY(bool isAnyDoorOpen READ isAnyDoorOpen NOTIFY doorOpenAlertChanged)
    Q_PROPERTY(int doorOpenSide READ doorOpenSide WRITE setDoorOpenSide NOTIFY doorOpenSideChanged)
    Q_PROPERTY(bool doorFrontLeft READ doorFrontLeft WRITE setDoorFrontLeft NOTIFY doorFrontLeftChanged)
    Q_PROPERTY(bool doorFrontRight READ doorFrontRight WRITE setDoorFrontRight NOTIFY doorFrontRightChanged)
    Q_PROPERTY(bool doorRearLeft READ doorRearLeft WRITE setDoorRearLeft NOTIFY doorRearLeftChanged)
    Q_PROPERTY(bool doorRearRight READ doorRearRight WRITE setDoorRearRight NOTIFY doorRearRightChanged)
    Q_PROPERTY(bool bonnetOpen READ bonnetOpen WRITE setBonnetOpen NOTIFY bonnetOpenChanged)
    Q_PROPERTY(bool trunkOpen READ trunkOpen WRITE setTrunkOpen NOTIFY trunkOpenChanged)

    // Media Popup Features (OEM Infotainment Bridge):
    Q_PROPERTY(bool showMediaPopup READ showMediaPopup WRITE setShowMediaPopup NOTIFY showMediaPopupChanged)
    Q_PROPERTY(QString mediaSource READ mediaSource WRITE setMediaSource NOTIFY mediaSourceChanged)
    Q_PROPERTY(QString mediaTitle READ mediaTitle WRITE setMediaTitle NOTIFY mediaTitleChanged)
    Q_PROPERTY(QString mediaArtist READ mediaArtist WRITE setMediaArtist NOTIFY mediaArtistChanged)
    Q_PROPERTY(bool isMediaPlaying READ isMediaPlaying WRITE setIsMediaPlaying NOTIFY isMediaPlayingChanged)
    Q_PROPERTY(int mediaTrackIndex READ mediaTrackIndex WRITE setMediaTrackIndex NOTIFY mediaTrackIndexChanged)

public:
    enum State {
        StateInitialStartup = 1, // 1. ODO Only + Wave of Light
        StateBootCheck = 2,      // 2. Boot & System Check
        StateNormalTrip = 3,     // 3. Normal Driving / Current Trip
        StateShutdown = 4,       // 4. Ignition OFF / Good-bye Screen
        StateOff = 5             // 5. Ignition OFF / Sleep / Standby (Wake on door)
    };
    Q_ENUM(State)

    explicit ClusterController(QObject *parent = nullptr);

    QString themeColor() const { return m_themeColor; }
    int clusterState() const { return m_clusterState; }
    int speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    int fuelLevel() const { return m_fuelLevel; }
    int tempLevel() const { return m_tempLevel; }
    QString gear() const { return m_gear; }
    int odoKm() const { return m_odoKm; }
    int dteKm() const { return m_dteKm; }
    int ambientTemp() const { return m_ambientTemp; }
    double tripKm() const { return m_tripKm; }
    QString tripTime() const { return m_tripTime; }
    double tripEconomy() const { return m_tripEconomy; }
    int tripPage() const { return m_tripPage; }
    double refuelKm() const { return m_refuelKm; }
    QString refuelTime() const { return m_refuelTime; }
    double refuelEconomy() const { return m_refuelEconomy; }
    double accumKm() const { return m_accumKm; }
    QString accumTime() const { return m_accumTime; }
    double accumEconomy() const { return m_accumEconomy; }
    double instantEconomy() const { return m_instantEconomy; }
    int menuTab() const { return m_menuTab; }
    bool showMenuTabs() const { return m_showMenuTabs; }

    double flPsi() const { return m_flPsi; }
    double frPsi() const { return m_frPsi; }
    double rlPsi() const { return m_rlPsi; }
    double rrPsi() const { return m_rrPsi; }
    bool tpmsCalibrated() const { return m_tpmsCalibrated; }

    bool parkBrakeActive() const { return m_parkBrakeActive; }
    bool seatbeltActive() const { return m_seatbeltActive; }
    bool absActive() const { return m_absActive; }
    bool tpmsActive() const { return m_tpmsActive; }
    bool batteryActive() const { return m_batteryActive; }
    bool oilActive() const { return m_oilActive; }
    bool leftIndicator() const { return m_leftIndicator; }
    bool rightIndicator() const { return m_rightIndicator; }
    bool highBeam() const { return m_highBeam; }
    bool lowBeam() const { return m_lowBeam; }
    bool positionLamp() const { return m_positionLamp; }
    bool masterWarning() const { return m_masterWarning; }
    bool lightWarning() const { return m_lightWarning; }
    bool escActive() const { return m_escActive; }
    bool escOffActive() const { return m_escOffActive; }
    bool checkEngineActive() const { return m_checkEngineActive; }
    bool smartKeyActive() const { return m_smartKeyActive; }
    bool steeringActive() const { return m_steeringActive; }
    bool airbagActive() const { return m_airbagActive; }
    bool isInteractiveMode() const { return m_isInteractiveMode; }
    QString tempUnit() const { return m_tempUnit; }
    QString fuelUnit() const { return m_fuelUnit; }
    QString tpmsUnit() const { return m_tpmsUnit; }
    int illumination() const { return m_illumination; }
    bool cruiseEnabled() const { return m_cruiseEnabled; }
    bool cruiseActive() const { return m_cruiseActive; }
    int cruiseSetSpeed() const { return m_cruiseSetSpeed; }
    int lightMode() const { return m_lightMode; }
    bool showLightPopup() const { return m_showLightPopup; }
    bool rearLeftBuckled() const { return m_rearLeftBuckled; }
    bool rearCenterBuckled() const { return m_rearCenterBuckled; }
    bool rearRightBuckled() const { return m_rearRightBuckled; }
    bool rearAlarmActive() const { return m_rearAlarmActive; }
    int rearAlarmSeat() const { return m_rearAlarmSeat; }
    bool rearSeatBlinkState() const { return m_rearSeatBlinkState; }
    QString language() const { return m_language; }

    bool driverAttentionActive() const { return m_driverAttentionActive; }
    int attentionLevel() const { return m_attentionLevel; }
    int serviceDueKm() const { return m_serviceDueKm; }
    int serviceDueDays() const { return m_serviceDueDays; }
    bool servicePopupActive() const { return m_servicePopupActive; }
    bool sunroofOpen() const { return m_sunroofOpen; }
    bool sunroofAlertActive() const { return m_sunroofAlertActive; }
    int smartKeyPrompt() const { return m_smartKeyPrompt; }
    bool isgActive() const { return m_isgActive; }
    bool reduceSpeedAlert() const { return m_reduceSpeedAlert; }

    bool showMediaPopup() const { return m_showMediaPopup; }
    QString mediaSource() const { return m_mediaSource; }
    QString mediaTitle() const { return m_mediaTitle; }
    QString mediaArtist() const { return m_mediaArtist; }
    bool isMediaPlaying() const { return m_isMediaPlaying; }
    int mediaTrackIndex() const { return m_mediaTrackIndex; }

public slots:
    void setShowMediaPopup(bool show);
    void setMediaSource(const QString& source);
    void setMediaTitle(const QString& title);
    void setMediaArtist(const QString& artist);
    void setIsMediaPlaying(bool playing);
    void setMediaTrackIndex(int index);
    void onMediaPopupTimeout();
    void setLanguage(const QString& lang);
    void setThemeColor(const QString& color);
    void setTempUnit(const QString& unit);
    void setFuelUnit(const QString& unit);
    void setTpmsUnit(const QString& unit);
    void setIllumination(int level);
    void setCruiseEnabled(bool enabled);
    void setCruiseActive(bool active);
    void setCruiseSetSpeed(int speed);
    void toggleCruise();
    void cruiseSet();
    void cruiseResPlus();
    void cruiseSetMinus();
    void cruiseCancel();
    void setLightMode(int mode);
    void cycleLightMode();
    void setShowLightPopup(bool show);
    void setRearLeftBuckled(bool buckled);
    void setRearCenterBuckled(bool buckled);
    void setRearRightBuckled(bool buckled);
    void triggerRearAlarm(int seat);
    void stopRearAlarm();
    void setClusterState(int state);
    void setSpeed(int s);
    void setRpm(double r);
    void setFuelLevel(int f);
    void setTempLevel(int t);
    void setGear(const QString& g);
    void setOdoKm(int odo);
    void setDteKm(int dte);
    void setAmbientTemp(int temp);
    void setTripKm(double km);
    void setTripTime(const QString& time);
    void setTripEconomy(double econ);
    void setTripPage(int page);
    void setRefuelKm(double km);
    void setRefuelTime(const QString& time);
    void setRefuelEconomy(double econ);
    void setAccumKm(double km);
    void setAccumTime(const QString& time);
    void setAccumEconomy(double econ);
    void setInstantEconomy(double econ);
    void setMenuTab(int tab);
    void setShowMenuTabs(bool show);
    void triggerInfoMenu();
    void nextMenuTab();

    void setFlPsi(double psi);
    void setFrPsi(double psi);
    void setRlPsi(double psi);
    void setRrPsi(double psi);
    void setAllPsi(double psi);
    void adjustPsi(const QString& tyre, double delta);
    void resetTpms();
    void setTpmsCalibrated(bool cal);

    void nextTripPage();
    void prevTripPage();

    void setParkBrakeActive(bool active);
    void setSeatbeltActive(bool active);
    void setAbsActive(bool active);
    void setTpmsActive(bool active);
    void setBatteryActive(bool active);
    void setOilActive(bool active);
    void setLeftIndicator(bool active);
    void setRightIndicator(bool active);
    void setHighBeam(bool active);
    void setLowBeam(bool active);
    void setPositionLamp(bool active);
    void setMasterWarning(bool active);
    void setLightWarning(bool active);
    void setEscActive(bool active);
    void setEscOffActive(bool active);
    void setCheckEngineActive(bool active);
    void setSmartKeyActive(bool active);
    void setSteeringActive(bool active);
    void setAirbagActive(bool active);
    void setAllTelltales(bool active);
    void setBulbCheckTelltales(bool active);
    void setIsInteractiveMode(bool interactive);

    // Manual Actions:
    void setDriverAttentionActive(bool active);
    void setAttentionLevel(int level);
    void triggerDriverAttention();
    void setServiceDueKm(int km);
    void setServiceDueDays(int days);
    void setServicePopupActive(bool active);
    void triggerServiceReminder();
    void resetServiceInterval();
    void setSunroofOpen(bool open);
    void setSunroofAlertActive(bool active);
    void setSmartKeyPrompt(int prompt);
    void showSmartKeyAlert(int type);
    void setIsgActive(bool active);
    void toggleIsg();
    void triggerShutdown();
    void setReduceSpeedAlert(bool active);
    void triggerReduceSpeedAlert();
    bool pressStartAgainAlert() const { return m_pressStartAgainAlert; }
    void setPressStartAgainAlert(bool active);
    Q_INVOKABLE void showPressStartAgainAlert(bool show) { setPressStartAgainAlert(show); }
    int startPedalPrompt() const { return m_startPedalPrompt; }
    void setStartPedalPrompt(int prompt);
    Q_INVOKABLE void showStartPedalAlert(int prompt) { setStartPedalPrompt(prompt); }
    bool doorOpenAlert() const { return m_doorOpenAlert || isAnyDoorOpen(); }
    void setDoorOpenAlert(bool open);
    Q_INVOKABLE void toggleDoorOpen() { setDoorFrontRight(!m_doorFrontRight); }
    int doorOpenSide() const { return m_doorOpenSide; }
    void setDoorOpenSide(int side);
    bool doorFrontLeft() const { return m_doorFrontLeft; }
    bool doorFrontRight() const { return m_doorFrontRight; }
    bool doorRearLeft() const { return m_doorRearLeft; }
    bool doorRearRight() const { return m_doorRearRight; }
    bool bonnetOpen() const { return m_bonnetOpen; }
    bool trunkOpen() const { return m_trunkOpen; }
    bool isAnyDoorOpen() const { return m_doorFrontLeft || m_doorFrontRight || m_doorRearLeft || m_doorRearRight || m_bonnetOpen || m_trunkOpen; }
    void setDoorFrontLeft(bool open);
    void setDoorFrontRight(bool open);
    void setDoorRearLeft(bool open);
    void setDoorRearRight(bool open);
    void setBonnetOpen(bool open);
    void setTrunkOpen(bool open);
    void setAllDoors(bool open);
    Q_INVOKABLE void toggleDoorFL() { setDoorFrontLeft(!m_doorFrontLeft); }
    Q_INVOKABLE void toggleDoorFR() { setDoorFrontRight(!m_doorFrontRight); }
    Q_INVOKABLE void toggleDoorRL() { setDoorRearLeft(!m_doorRearLeft); }
    Q_INVOKABLE void toggleDoorRR() { setDoorRearRight(!m_doorRearRight); }
    Q_INVOKABLE void toggleBonnet() { setBonnetOpen(!m_bonnetOpen); }
    Q_INVOKABLE void toggleTrunk() { setTrunkOpen(!m_trunkOpen); }
    Q_INVOKABLE void toggleLeftDoors() { bool op = !(m_doorFrontLeft && m_doorRearLeft); setDoorFrontLeft(op); setDoorRearLeft(op); }
    Q_INVOKABLE void toggleRightDoors() { bool op = !(m_doorFrontRight && m_doorRearRight); setDoorFrontRight(op); setDoorRearRight(op); }
    Q_INVOKABLE void toggleBothDoors() { bool op = !(m_doorFrontLeft && m_doorFrontRight); setDoorFrontLeft(op); setDoorFrontRight(op); }
    Q_INVOKABLE void toggleAllDoors() { bool op = !isAnyDoorOpen(); setAllDoors(op); }
    Q_INVOKABLE void toggleIgnition() { if (m_clusterState == StateOff || m_clusterState == StateShutdown) { triggerStartupSequence(); } else { triggerShutdown(); } }
    Q_INVOKABLE void setIgnitionOffDirect() { setClusterState(StateOff); setSpeed(0); setRpm(0.0); setAllTelltales(false); }
    Q_INVOKABLE void setIgnitionOnDirect() { triggerStartupSequence(); }
    Q_INVOKABLE void deflateFL() { setFlPsi(24.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void deflateFR() { setFrPsi(24.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void deflateRL() { setRlPsi(24.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void deflateRR() { setRrPsi(24.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void punctureFL() { setFlPsi(16.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void punctureFR() { setFrPsi(16.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void punctureRL() { setRlPsi(16.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void punctureRR() { setRrPsi(16.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void setAllTiresOK() { setAllPsi(35.0); setTpmsCalibrated(true); }
    Q_INVOKABLE void setAllTiresLow() { setAllPsi(24.0); setTpmsCalibrated(true); }

    bool isDemoDriving() const { return m_isDemoDriving; }
    QString demoScenario() const { return m_demoScenario; }

    Q_INVOKABLE void toggleRandomSimulation() { driveDemo(); }
    Q_INVOKABLE void startRandomSimulation() { if (!m_isDemoDriving) driveDemo(); }
    Q_INVOKABLE void stopRandomSimulation() { if (m_isDemoDriving) driveDemo(); }

    Q_INVOKABLE void playTrack(const QString& source, const QString& artist, const QString& title);
    Q_INVOKABLE void nextMediaTrack();
    Q_INVOKABLE void prevMediaTrack();
    Q_INVOKABLE void toggleMediaPlayback();
    Q_INVOKABLE void triggerMediaPopup();
    Q_INVOKABLE void dismissMediaPopup();

    void triggerStartupSequence();
    void resetTrip();
    Q_INVOKABLE void resetActiveTripPage();
    Q_INVOKABLE void resetSinceRefuel();
    Q_INVOKABLE void resetAccumInfo();
    void cycleGear();
    void driveDemo();

signals:
    void showMediaPopupChanged();
    void mediaSourceChanged();
    void mediaTitleChanged();
    void mediaArtistChanged();
    void isMediaPlayingChanged();
    void mediaTrackIndexChanged();
    void isDemoDrivingChanged();
    void demoScenarioChanged();
    void themeColorChanged();
    void tempUnitChanged();
    void fuelUnitChanged();
    void tpmsUnitChanged();
    void illuminationChanged();
    void cruiseEnabledChanged();
    void cruiseActiveChanged();
    void cruiseSetSpeedChanged();
    void lightModeChanged();
    void showLightPopupChanged();
    void rearLeftBuckledChanged();
    void rearCenterBuckledChanged();
    void rearRightBuckledChanged();
    void rearAlarmActiveChanged();
    void rearAlarmSeatChanged();
    void rearSeatBlinkStateChanged();
    void signalPlayChime();
    void signalStartupAnimationTone();
    void signalWelcomeChime();
    void signalGoodbyeChime();
    void signalWarningChime();
    void signalSeatbeltChime();
    void signalKeyAlertChime();
    void signalSpeedAlertChime();
    void clusterStateChanged();
    void speedChanged();
    void rpmChanged();
    void fuelLevelChanged();
    void tempLevelChanged();
    void gearChanged();
    void odoKmChanged();
    void dteKmChanged();
    void ambientTempChanged();
    void tripKmChanged();
    void tripTimeChanged();
    void tripEconomyChanged();
    void tripPageChanged();
    void refuelKmChanged();
    void refuelTimeChanged();
    void refuelEconomyChanged();
    void accumKmChanged();
    void accumTimeChanged();
    void accumEconomyChanged();
    void instantEconomyChanged();
    void menuTabChanged();
    void showMenuTabsChanged();

    void flPsiChanged();
    void frPsiChanged();
    void rlPsiChanged();
    void rrPsiChanged();
    void tpmsCalibratedChanged();

    void parkBrakeActiveChanged();
    void seatbeltActiveChanged();
    void absActiveChanged();
    void tpmsActiveChanged();
    void batteryActiveChanged();
    void oilActiveChanged();
    void leftIndicatorChanged();
    void rightIndicatorChanged();
    void highBeamChanged();
    void lowBeamChanged();
    void positionLampChanged();
    void masterWarningChanged();
    void lightWarningChanged();
    void escActiveChanged();
    void escOffActiveChanged();
    void checkEngineActiveChanged();
    void smartKeyActiveChanged();
    void steeringActiveChanged();
    void airbagActiveChanged();
    void isInteractiveModeChanged();
    void languageChanged();

    void driverAttentionActiveChanged();
    void attentionLevelChanged();
    void serviceDueKmChanged();
    void serviceDueDaysChanged();
    void servicePopupActiveChanged();
    void sunroofOpenChanged();
    void sunroofAlertActiveChanged();
    void smartKeyPromptChanged();
    void isgActiveChanged();
    void reduceSpeedAlertChanged();
    void pressStartAgainAlertChanged();
    void startPedalPromptChanged();
    void doorOpenAlertChanged();
    void doorOpenSideChanged();
    void doorFrontLeftChanged();
    void doorFrontRightChanged();
    void doorRearLeftChanged();
    void doorRearRightChanged();
    void bonnetOpenChanged();
    void trunkOpenChanged();

private slots:
    void onSequenceStep();
    void onDriveSimulationTick();
    void onRearAlarmTimeout();
    void onRearBlinkTick();
    void onShutdownTimeout();
    void onReduceSpeedDismissTimeout();
    void onOverspeedBeepTick();
    void onTpmsDismissTimeout();

private:
    QString m_language = "English"; // "English" or "हिन्दी"
    QString m_themeColor = "blue"; // "blue", "green", "red"
    QString m_tempUnit = "°C";
    QString m_fuelUnit = "km/L";
    QString m_tpmsUnit = "psi";
    int m_illumination = 20;
    bool m_cruiseEnabled = false;
    bool m_cruiseActive = false;
    int m_cruiseSetSpeed = 41;
    int m_lightMode = 0; // 0 = OFF, 1 = AUTO, 2 = POSITION, 3 = HEADLIGHT
    bool m_showLightPopup = false;
    bool m_rearLeftBuckled = true;
    bool m_rearCenterBuckled = true;
    bool m_rearRightBuckled = true;
    bool m_rearAlarmActive = false;
    int m_rearAlarmSeat = -1; // 0=Left, 1=Center, 2=Right
    bool m_rearSeatBlinkState = false;
    QTimer* m_rearAlarmTimer = nullptr;
    QTimer* m_rearBlinkTimer = nullptr;

    bool m_driverAttentionActive = false;
    int m_attentionLevel = 4; // 1 to 5 bars
    int m_serviceDueKm = 1500;
    int m_serviceDueDays = 30;
    bool m_servicePopupActive = false;
    bool m_sunroofOpen = false;
    bool m_sunroofAlertActive = false;
    int m_smartKeyPrompt = 0; // 0=None, 1="Key not in vehicle", 2="Press brake to start", 3="Low Key Battery"
    bool m_isgActive = false;
    bool m_reduceSpeedAlert = false;
    bool m_pressStartAgainAlert = false;
    int m_startPedalPrompt = 0;
    bool m_doorOpenAlert = false;
    int m_doorOpenSide = 0;
    bool m_doorFrontLeft = false;
    bool m_doorFrontRight = false;
    bool m_doorRearLeft = false;
    bool m_doorRearRight = false;
    bool m_bonnetOpen = false;
    bool m_trunkOpen = false;
    bool m_speed80Triggered = false;
    bool m_speed120Triggered = false;
    QTimer* m_shutdownTimer = nullptr;
    QTimer* m_reduceSpeedDismissTimer = nullptr;
    QTimer* m_overspeedBeepTimer = nullptr;
    QTimer* m_tpmsDismissTimer = nullptr;

    int m_clusterState = StateNormalTrip;
    int m_speed = 0;
    double m_rpm = 0.0;
    int m_fuelLevel = 9;
    int m_tempLevel = 6;
    QString m_gear = "N";
    int m_odoKm = 176;
    int m_dteKm = 175;
    int m_ambientTemp = 32;
    double m_tripKm = 0.0;
    QString m_tripTime = "0:00";
    double m_tripEconomy = 0.0;
    int m_tripSeconds = 0;
    int m_tripPage = 1; // 0 = Drive info, 1 = Since refuelling, 2 = Accumulated info
    double m_refuelKm = 0.0;
    QString m_refuelTime = "0:00";
    double m_refuelEconomy = 0.0;
    int m_refuelSeconds = 0;
    double m_accumKm = 0.0;
    QString m_accumTime = "0:00";
    double m_accumEconomy = 0.0;
    int m_accumSeconds = 0;
    double m_instantEconomy = 0.0;
    double m_tripLitres = 0.0;
    double m_refuelLitres = 0.0;
    double m_accumLitres = 0.0;
    double m_fuelBarAccumulator = 0.0;
    double m_engineSecAcc       = 0.0; // Fractional second accumulator for trip timers
    // Raw (un-rounded) distance accumulators – never overwritten by setter
    double m_rawTripKm    = 0.0;
    double m_rawRefuelKm  = 0.0;
    double m_rawAccumKm   = 0.0;
    double m_rawOdoAcc    = 0.0;  // sub-km odo accumulator (replaces static local)
    double m_rawDteAcc    = 0.0;  // sub-km DTE accumulator (replaces static local)
    double m_demoCycleTime = 0.0; // Demo drive scenario clock (seconds since demo start)
    int    m_demoPrevGear  = 1;   // Previous gear num for RPM-drop on shift event
    int m_menuTab = 0; // 0 = Trip (Car), 1 = User Settings (Cog), 2 = TPMS/Info (i)
    bool m_showMenuTabs = false;

    double m_flPsi = 35.0;
    double m_frPsi = 35.0;
    double m_rlPsi = 35.0;
    double m_rrPsi = 31.0; // Sample low pressure for demo/verification
    bool m_tpmsCalibrated = false; // "Drive to display" until driven for 5s
    int m_driveSeconds = 0;

    bool m_parkBrakeActive = true;
    bool m_seatbeltActive = true;
    bool m_absActive = false;
    bool m_tpmsActive = false;
    bool m_batteryActive = true;
    bool m_oilActive = true;
    bool m_leftIndicator = false;
    bool m_rightIndicator = false;
    bool m_highBeam = false;
    bool m_lowBeam = false;
    bool m_positionLamp = false;
    bool m_masterWarning = false;
    bool m_lightWarning = false;
    bool m_escActive = false;
    bool m_escOffActive = false;
    bool m_checkEngineActive = false;
    bool m_smartKeyActive = true;
    bool m_steeringActive = true;
    bool m_airbagActive = false;
    bool m_isInteractiveMode = false;

    QTimer m_sequenceTimer;
    QTimer m_driveSimTimer;
    int m_sequenceStepIndex = 0;
    bool m_isDemoDriving = false;
    double m_demoTargetSpeed = 0.0;
    QString m_demoScenario = "Idle / Parked";

    bool m_showMediaPopup = false;
    QString m_mediaSource = "USB";
    QString m_mediaTitle = "Sunset Drive";
    QString m_mediaArtist = "Revoic";
    bool m_isMediaPlaying = true;
    int m_mediaTrackIndex = 0;
    QTimer* m_mediaPopupTimer = nullptr;
};
