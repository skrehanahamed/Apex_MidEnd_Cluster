# ============================================================================
# Project:        Automotive Digital Instrument Cluster HMI
# File:           CMakeLists.txt
# Author:         SK Rehan Ahamed
# Description:    CMake Build System Configuration
# Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
# ============================================================================

cmake_minimum_required(VERSION 3.16)
project(HyundaiExterCluster LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Gui Qml Svg Multimedia)

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
        qml/gauges/FuelGauge.qml
        qml/gauges/FuelIcon.qml
        qml/gauges/TempGauge.qml
        qml/gauges/TempIcon.qml
        qml/center/CenterTripDisplay.qml
        qml/center/StartupAnimationView.qml
        qml/center/VehicleCheckView.qml
        qml/center/InstantEcoGauge.qml
        qml/center/GoodbyeView.qml
        qml/center/UserSettingsView.qml
        qml/center/TpmsDisplayView.qml
        qml/simulator/EcuSimulatorPanel.qml
    RESOURCES
        resources/fonts/HyundaiSansHead-Regular.ttf
        resources/fonts/HyundaiSansHead-Medium.ttf
        resources/fonts/HyundaiSansHead-Bold.ttf
        resources/fonts/NotoSansDevanagari-Regular.ttf
        resources/fonts/Orbitron-Bold.ttf
        resources/fonts/Rajdhani-Bold.ttf
        resources/fonts/DSEG7Classic-Bold.ttf
        resources/fonts/DSEG7Classic-Regular.ttf
        resources/icons/fuel_meter_icon.png
        resources/icons/temp_meter_icon.png
        resources/icons/brake.png
        resources/icons/abs.png
        resources/icons/seatbelt.png
        resources/icons/smart_key.png
        resources/icons/hyundai_smart_key_fob.png
        resources/icons/engine_start_button_oem.png
        resources/icons/engine_start_button_fob.png
        resources/icons/pedal_press_indicator.png
        resources/icons/car_doors_closed.png
        resources/icons/car_door_fl.png
        resources/icons/car_door_fl_half.png
        resources/icons/car_door_fr.png
        resources/icons/car_door_fr_half.png
        resources/icons/car_door_rl.png
        resources/icons/car_door_rl_half.png
        resources/icons/car_door_rr.png
        resources/icons/car_door_rr_half.png
        resources/icons/car_doors_left_both.png
        resources/icons/car_doors_left_both_half.png
        resources/icons/car_doors_right_both.png
        resources/icons/car_doors_right_both_half.png
        resources/icons/car_doors_front_both.png
        resources/icons/car_doors_front_both_half.png
        resources/icons/car_doors_rear_both.png
        resources/icons/car_doors_rear_both_half.png
        resources/icons/car_doors_all_open.png
        resources/icons/car_doors_all_half.png
        resources/icons/car_bonnet_red_glow.png
        resources/icons/car_trunk_red_glow.png
        resources/icons/car_topdown_shadow.png
        resources/icons/tpms.png
        resources/icons/steering.png
        resources/icons/battery.png
        resources/icons/airbag.png
        resources/icons/oil.png
        resources/icons/fuel_pump.png
        resources/icons/low_fuel_warning_3d.png
        resources/icons/trip_car.png
        resources/icons/trip_clock.png
        resources/icons/trip_fuel.png
        resources/icons/menu_tab_car.png
        resources/icons/menu_tab_settings.png
        resources/icons/menu_tab_info.png
        resources/icons/tpms_car_top.png
        resources/icons/turn_left.png
        resources/icons/turn_right.png
        resources/icons/high_beam.png
        resources/icons/low_beam.png
        resources/icons/position_lamp.png
        resources/icons/master_warning.png
        resources/icons/light_warning.png
        resources/icons/esc.png
        resources/icons/esc_off.png
        resources/icons/engine_mil.png
        resources/icons/cruise_green.png
        resources/icons/cruise_white.png
        resources/icons/media_usb.png
        resources/icons/media_bluetooth.png
        resources/icons/media_carplay.png
        resources/icons/media_android_auto.png
        resources/icons/media_note.png
        resources/audio/tick.wav
        resources/audio/tock.wav
        resources/audio/hyundai_chime.wav
        resources/audio/startup_animation_tone.wav
        resources/audio/welcome_chime.wav
        resources/audio/goodbye_chime.wav
        resources/audio/warning_chime.wav
        resources/audio/seatbelt_chime.wav
        resources/audio/key_alert_chime.wav
        resources/audio/speed_alert_chime.wav
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
        assets/welcome_laser_beam.png
        assets/car_silhouette_glow.png
        assets/welcome_wave_swoop.png
)

target_link_libraries(HyundaiExterClusterApp PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Gui
    Qt6::Qml
    Qt6::Svg
    Qt6::Multimedia
)

target_include_directories(HyundaiExterClusterApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
