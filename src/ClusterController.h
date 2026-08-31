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
    Q_PROPERTY(bool checkEngineActive READ checkEngineActive WRITE setCheckEngineActive NOTIFY checkEngineActiveChanged)
    Q_PROPERTY(bool escOffActive READ escOffActive WRITE setEscOffActive NOTIFY escOffActiveChanged)
    Q_PROPERTY(bool leftIndicator READ leftIndicator WRITE setLeftIndicator NOTIFY leftIndicatorChanged)
    Q_PROPERTY(bool rightIndicator READ rightIndicator WRITE setRightIndicator NOTIFY rightIndicatorChanged)
    Q_PROPERTY(bool highBeam READ highBeam WRITE setHighBeam NOTIFY highBeamChanged)
    Q_PROPERTY(bool isInteractiveMode READ isInteractiveMode WRITE setIsInteractiveMode NOTIFY isInteractiveModeChanged)

public:
    enum State {
        StateInitialStartup = 1, // 1. ODO Only
        StateBootCheck = 2,      // 2. Boot & System Check
        StateNormalTrip = 3      // 3. Normal Driving / Current Trip
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
    bool checkEngineActive() const { return m_checkEngineActive; }
    bool escOffActive() const { return m_escOffActive; }
    bool leftIndicator() const { return m_leftIndicator; }
    bool rightIndicator() const { return m_rightIndicator; }
    bool highBeam() const { return m_highBeam; }
    bool isInteractiveMode() const { return m_isInteractiveMode; }

public slots:
    void setThemeColor(const QString& color);
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
    void setTpmsCalibrated(bool cal);

    void nextTripPage();
    void prevTripPage();

    void setParkBrakeActive(bool active);
    void setSeatbeltActive(bool active);
    void setAbsActive(bool active);
    void setTpmsActive(bool active);
    void setBatteryActive(bool active);
    void setOilActive(bool active);
    void setCheckEngineActive(bool active);
    void setEscOffActive(bool active);
    void setLeftIndicator(bool active);
    void setRightIndicator(bool active);
    void setHighBeam(bool active);
    void setIsInteractiveMode(bool interactive);

    void triggerStartupSequence();
    void resetTrip();
    void cycleGear();
    void driveDemo();

signals:
    void themeColorChanged();
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
    void checkEngineActiveChanged();
    void escOffActiveChanged();
    void leftIndicatorChanged();
    void rightIndicatorChanged();
    void highBeamChanged();
    void isInteractiveModeChanged();

private slots:
    void onSequenceStep();
    void onDriveSimulationTick();

private:
    QString m_themeColor = "blue"; // "blue", "green", "red"
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
    int m_tripPage = 1; // 0 = Drive info, 1 = Since refuelling, 2 = Accumulated info
    double m_refuelKm = 154.9;
    QString m_refuelTime = "10:21";
    double m_refuelEconomy = 12.5;
    double m_accumKm = 3454.0;
    QString m_accumTime = "84:12";
    double m_accumEconomy = 14.2;
    double m_instantEconomy = 26.1;
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
    bool m_checkEngineActive = false;
    bool m_escOffActive = false;
    bool m_leftIndicator = false;
    bool m_rightIndicator = false;
    bool m_highBeam = false;
    bool m_isInteractiveMode = false;

    QTimer m_sequenceTimer;
    QTimer m_driveSimTimer;
    int m_sequenceStepIndex = 0;
    bool m_isDemoDriving = false;
    double m_demoTargetSpeed = 0.0;
};
