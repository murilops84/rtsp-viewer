import QtQuick 2.12
import QtQuick.Controls 2.8 as QQC2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.14 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

ColumnLayout {
  id: connections

  property var streamsList: Plasmoid.configuration.streamsUrls || [] 
  property var rows: []
  
  Kirigami.FormLayout {
    Layout.fillWidth: true
 
    RowLayout {
      Layout.fillWidth: true
  
      QQC2.TextField {
        id: newStreamUrl
        Layout.fillWidth: true
        implicitWidth: parent.width
        Kirigami.FormData.label: i18n("URL:")
        placeholderText: i18n("RTSP Stream URL")
      }

      QQC2.Button {
        Layout.alignment: Qt.AlignRight
        text: i18n("Add stream")
        icon.name: "list-add"
        onClicked: addStream() 
      }
    }
  }

  ColumnLayout {
    id: streams
  }

  Component {
    id: row
    PlasmaComponents3.RadioButton {
      height: 10
      Layout.fillWidth: true
      onClicked: {
        Plasmoid.configuration.defaultStream = text
      }
    }
  }

  function addStream() {
    const stream = newStreamUrl.text;
    streamsList.push(stream);
    Plasmoid.configuration.streamsUrls = streamsList;
    console.log(streamsList.length);
    const checked = streamsList.length === 1 ? true : false;
    row.createObject(streams, { id: streamsList.length, text: newStreamUrl.text, checked: checked });
    if (checked) {
      Plasmoid.configuration.defaultStream = newStreamUrl.text;
    }
  }

  function getAllStreams() {
    const defaultStream = Plasmoid.configuration.defaultStream;
    for (let i=0; i < streamsList.length; i++) {
      const checked = streamsList[i] === defaultStream ? true : false;
      row.createObject(streams, { id: i, text: streamsList[i], checked: checked });
    }
  }

  Item {
    Layout.fillHeight: true
  }

  Component.onCompleted: {
    getAllStreams()
  }

}
