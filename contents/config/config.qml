pragma ComponentBehavior: Bound

import QtQuick
import QtQml

import org.kde.plasma.plasmoid
import org.kde.plasma.configuration

ConfigModel {
    id: configModel

    ConfigCategory {
         name: i18n("Connections")
         icon: "video-mp4" 
         source: "configConnection.qml"
    }
}
