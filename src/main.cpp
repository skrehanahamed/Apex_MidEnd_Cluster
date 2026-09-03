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
#include <QFont>
#include <QLoggingCategory>
#include <QString>
#include <QByteArray>
#include <cstdio>
#include <cstdlib>
#include "ClusterController.h"

static void clusterMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    // Filter out internal Qt font database OpenType script fallback warnings (e.g. script 11)
    if (msg.contains(QLatin1String("OpenType support missing")) ||
        (context.category && strcmp(context.category, "qt.text.font.db") == 0)) {
        return;
    }

    QByteArray localMsg = msg.toLocal8Bit();
    switch (type) {
    case QtDebugMsg:
        fprintf(stdout, "%s\n", localMsg.constData());
        break;
    case QtInfoMsg:
        fprintf(stdout, "%s\n", localMsg.constData());
        break;
    case QtWarningMsg:
        fprintf(stderr, "%s\n", localMsg.constData());
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s\n", localMsg.constData());
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s\n", localMsg.constData());
        abort();
    }
}

int main(int argc, char *argv[])
{
    qInstallMessageHandler(clusterMessageHandler);
    QLoggingCategory::setFilterRules(QStringLiteral("qt.text.font.db.warning=false\nqt.text.font.db.debug=false"));

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

    // Insert OpenType fallback font substitution so script 11 (Devanagari) glyphs route directly to Noto Sans Devanagari
    QFont::insertSubstitutions(QStringLiteral("Cluster Sans Head"), QStringList() << QStringLiteral("Noto Sans Devanagari") << QStringLiteral("Devanagari Sangam MN") << QStringLiteral("Kohinoor Devanagari"));

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
