import QtQuick 2.12
import QtQuick.Controls 2.8
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
  id: connections

  property var streamsList: Plasmoid.configuration.streamsUrls || [] 
  
 
  RowLayout {
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
      spacing: 20
      width: parent.width
      RadioButton {
        text: model.streamUrl
        checked: model.defaultStream 
        ButtonGroup.group: buttonGroup
        onCheckedChanged: {
          model.defaultStream = checked
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
    if (streamsList.length > 0) {
      const json = JSON.parse(streamsList)
      json.forEach(item => streamModel.append({ streamUrl: item.streamUrl, defaultStream: item.defaultStream}))
      console.log(streamModel.count)
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
