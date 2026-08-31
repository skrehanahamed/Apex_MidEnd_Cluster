#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFontDatabase>
#include "ClusterController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Hyundai Exter AMT Cluster");
    app.setOrganizationName("Hyundai HMI Studio");

    QQuickStyle::setStyle("Basic");

    int f1 = QFontDatabase::addApplicationFont(":/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Regular.ttf");
    int f2 = QFontDatabase::addApplicationFont(":/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Medium.ttf");
    int f3 = QFontDatabase::addApplicationFont(":/qt/qml/HyundaiExterCluster/resources/fonts/HyundaiSansHead-Bold.ttf");
    QFontDatabase::addApplicationFont(":/qt/qml/HyundaiExterCluster/resources/fonts/Rajdhani-Bold.ttf");
    QFontDatabase::addApplicationFont(":/qt/qml/HyundaiExterCluster/resources/fonts/Orbitron-Bold.ttf");

    qDebug() << "Loaded Hyundai Sans Head Regular:" << QFontDatabase::applicationFontFamilies(f1);
    qDebug() << "Loaded Hyundai Sans Head Medium:" << QFontDatabase::applicationFontFamilies(f2);
    qDebug() << "Loaded Hyundai Sans Head Bold:" << QFontDatabase::applicationFontFamilies(f3);

    QQmlApplicationEngine engine;
    ClusterController controller;

    engine.rootContext()->setContextProperty("controller", &controller);

    const QUrl url(QStringLiteral("qrc:/qt/qml/HyundaiExterCluster/qml/Main.qml"));
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
