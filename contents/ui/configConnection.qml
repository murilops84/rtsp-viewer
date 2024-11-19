import QtQuick 2.12
import QtQuick.Controls 2.8
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.14 as Kirigami

ColumnLayout {
  id: connections

  property var streamsList: Plasmoid.configuration.streamsUrls || [] 
  property var rows: []
  
  Kirigami.FormLayout {
    Layout.fillWidth: true
 
    RowLayout {
      Layout.fillWidth: true
  
      TextField {
        id: newStreamUrl
        Layout.fillWidth: true
        implicitWidth: parent.width
        Kirigami.FormData.label: i18n("URL:")
        placeholderText: i18n("RTSP Stream URL")
      }

      Button {
        Layout.alignment: Qt.AlignRight
        text: i18n("Add stream")
        icon.name: "list-add"
        onClicked: addStream() 
      }
    }
  }

  ButtonGroup {
    id: buttonGroup
  }

  ListView {
    Layout.fillWidth: true
    Layout.fillHeight: true
    model: ListModel {
      id: streamModel
    }
    spacing: 10
    delegate: Row {
      spacing: 20
      width: parent.width
      height: 40
      RadioButton {
        anchors.verticalCenter: parent.verticalCenter
        text: model.streamUrl
        checked: model.defaultStream 
        ButtonGroup.group: buttonGroup
        onCheckedChanged: {
          model.defaultStream = checked
          Plasmoid.configuration.defaultStream = text
        }
      }

      Button {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        icon.name: "trash-empty"
        onClicked: streamModel.remove(index)
      }
    }
  }

  Item {
    Layout.fillHeight: true
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

  Component.onCompleted: {
    for (let i = 0; i < streamsList.length; i++) {
      const item = streamsList[i]
      streamModel.append({ streamUrl: item.streamUrl, defaultStream: item.defaultStream })
    }
  }

  Component.onDestruction: {
    let streams = []
    for (let i = 0; i < streamModel.count; i++) {
      const item = streamModel.get(i)
      streams.push({ streamUrl: item.streamUrl, defaultStream: item.defaultStream })
    }
    Plasmoid.configuration.streamsUrls = streams
  }
}
