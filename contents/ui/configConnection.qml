pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.config as KConfig
import org.kde.kcmutils as KCMUtils
//import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
  property var streamsList: Plasmoid.configuration.streamsUrls || [] 
  property var defaultStream: Plasmoid.configuration.defaultStream || ''
  property var cfg_defaultStream
  property var cfg_defaultStreamDefault
  property var cfg_streamsUrls
  property var cfg_streamsUrlsDefault

  ColumnLayout {
    id: connections
    width: root.height 
    height: root.width
     
    RowLayout {
      id: inputStream
      Layout.fillWidth: true

      TextField {
        id: newStreamUrl
        Layout.fillWidth: true
        placeholderText: i18n("RTSP Stream URL")
      }

      Button {
        Layout.alignment: Qt.AlignRight
        text: i18n("Add stream")
        icon.name: "list-add"
        onClicked: addStream() 
      }
    }

    ButtonGroup {
      id: buttonGroup
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.topMargin: 5
      model: ListModel {
        id: streamModel
      }
      spacing: 10
      delegate: RowLayout {
        required property int index
        required property var streamUrl
        required property bool defaultStream
        width: inputStream.width
        RadioButton {
          id: stream
          text: streamUrl
          checked: defaultStream || false 
          ButtonGroup.group: buttonGroup
          onCheckedChanged: {
            defaultStream = checked || false
            Plasmoid.configuration.defaultStream = text
          }
        }

        Button {
          Layout.alignment: Qt.AlignRight
          icon.name: "trash-empty"
          onClicked: streamModel.remove(index)
        }
      }
    }

    Item {
      Layout.fillHeight: true
    }

    Component.onCompleted: {
      if (streamsList.length > 0) {
        const json = JSON.parse(streamsList)
        json.forEach(item => streamModel.append({ streamUrl: item.streamUrl, defaultStream: item.defaultStream}))
      }
    }

    Component.onDestruction: {
      let streams = []
      for (let i = 0; i < streamModel.count; i++) {
        const item = streamModel.get(i)
        streams.push({ streamUrl: item.streamUrl, defaultStream: item.defaultStream })
      }
      Plasmoid.configuration.streamsUrls = JSON.stringify(streams)
    }
  }

  function addStream() {
    let duplicated = false;
    for (let i = 0; i < streamModel.count; i++) {
      duplicated = (streamModel.get(i).streamUrl === newStreamUrl.text || duplicated) ? true : false
    }

    if (newStreamUrl !== "" && !duplicated) {
      const first = streamModel.count === 0 ? true : false
      streamModel.append({ streamUrl: newStreamUrl.text, defaultStream: first })
      if (first) {
        Plasmoid.configuration.defaultStream = newStreamUrl.text
      }
      newStreamUrl.text = ""
    }
  }

}
