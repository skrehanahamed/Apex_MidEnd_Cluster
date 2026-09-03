/**
 * ============================================================================
 * Project:        Automotive Digital Instrument Cluster HMI
 * File:           main.cpp
 * Author:         SK Rehan Ahamed
 * Description:    Application Entry Point & QML Engine Initializer
 * Copyright (c) 2026 SK Rehan Ahamed. All rights reserved.
 * ============================================================================
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFontDatabase>
#include "ClusterController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("APEX Horizon AMT Cluster");
    app.setOrganizationName("APEX Motors HMI");

    QQuickStyle::setStyle("Basic");

    int f1 = QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Regular.ttf");
    int f2 = QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Medium.ttf");
    int f3 = QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/ClusterSansHead-Bold.ttf");
    int f4 = QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/NotoSansDevanagari-Regular.ttf");
    QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/Rajdhani-Bold.ttf");
    QFontDatabase::addApplicationFont(":/qt/qml/ApexCluster/resources/fonts/Orbitron-Bold.ttf");

    qDebug() << "Loaded Cluster Sans Head Regular:" << QFontDatabase::applicationFontFamilies(f1);
    qDebug() << "Loaded Cluster Sans Head Medium:" << QFontDatabase::applicationFontFamilies(f2);
    qDebug() << "Loaded Cluster Sans Head Bold:" << QFontDatabase::applicationFontFamilies(f3);
    qDebug() << "Loaded Noto Sans Devanagari:" << QFontDatabase::applicationFontFamilies(f4);

    QQmlApplicationEngine engine;
    ClusterController controller;

    engine.rootContext()->setContextProperty("controller", &controller);

    const QUrl url(QStringLiteral("qrc:/qt/qml/ApexCluster/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
