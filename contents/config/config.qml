import QtQuick 2.0
import QtQml 2.2

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    id: configModel

    ConfigCategory {
         name: i18n("Connections")
         icon: "video-mp4" 
         source: "configConnection.qml"
    }
}
