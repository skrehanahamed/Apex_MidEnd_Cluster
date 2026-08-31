cmake_minimum_required(VERSION 3.16)
project(HyundaiExterCluster LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Gui Qml Svg)

qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(HyundaiExterClusterApp
    src/main.cpp
    src/ClusterController.h
    src/ClusterController.cpp
)

qt_add_qml_module(HyundaiExterClusterApp
    URI HyundaiExterCluster
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        qml/Main.qml
        qml/ClusterUnit.qml
        qml/frame/BlueFrame.qml
        qml/gauges/SpeedDisplay.qml
        qml/gauges/RpmDisplay.qml
        qml/gauges/SevenSegmentDigit.qml
        qml/center/CenterTripDisplay.qml
        qml/center/VehicleCheckView.qml
        qml/center/TripComputerCard.qml
        qml/center/InstantEcoGauge.qml
        qml/center/UserSettingsView.qml
        qml/center/TpmsDisplayView.qml
        qml/simulator/EcuSimulatorPanel.qml
    RESOURCES
        resources/fonts/HyundaiSansHead-Regular.ttf
        resources/fonts/HyundaiSansHead-Medium.ttf
        resources/fonts/HyundaiSansHead-Bold.ttf
        resources/fonts/Orbitron-Bold.ttf
        resources/fonts/Rajdhani-Bold.ttf
        resources/fonts/DSEG7Classic-Bold.ttf
        resources/fonts/DSEG7Classic-Regular.ttf
        resources/icons/brake.png
        resources/icons/abs.png
        resources/icons/seatbelt.png
        resources/icons/smart_key.png
        resources/icons/tpms.png
        resources/icons/steering.png
        resources/icons/battery.png
        resources/icons/airbag.png
        resources/icons/oil.png
        resources/icons/fuel_pump.png
        resources/icons/trip_car.png
        resources/icons/trip_clock.png
        resources/icons/trip_fuel.png
        resources/icons/eco_gauge_hq.png
        resources/icons/eco_gauge_base_empty.png
        resources/icons/eco_gauge_glow_fill.png
        resources/icons/menu_tab_car.png
        resources/icons/menu_tab_settings.png
        resources/icons/menu_tab_info.png
        resources/icons/tpms_car_top.png
        assets/speed_line1.svg
        assets/speed_line2.svg
        assets/speed_line3.svg
        assets/speed_line4.svg
        assets/speed_line5.svg
        assets/rpm_line1.svg
        assets/rpm_line2.svg
        assets/rpm_line3.svg
        assets/rpm_line4.svg
        assets/rpm_line5.svg
        assets/hyundai_exter_car.png
        assets/oem_studio_ground.png
        assets/car_ground_shadow.png
)

target_link_libraries(HyundaiExterClusterApp PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Gui
    Qt6::Qml
    Qt6::Svg
)

target_include_directories(HyundaiExterClusterApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
