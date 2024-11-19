import QtQuick 2.15
import QtQuick.Controls 2.8 
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
  id: root
  
  property string currentStream: Plasmoid.configuration.defaultStream
  
  width: 480
  height: 300

  Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

  RowLayout {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop
    height: 30
    ComboBox {
      id: streamComboBox
      Layout.fillWidth: true
      Layout.margins: 5
      model: ListModel {
        id: streamModel
      }
      delegate: ItemDelegate {
        text: model.streamUrl
        highlighted: streamComboBox.currentIndex === index
        onClicked: root.currentStream = model.streamUrl
      }
      onCurrentIndexChanged: {
        root.currentStream = model.get(currentIndex).streamUrl
      }
    }

    Button {
      id: muteButton
      icon.name: (stream.muted) ? "player-volume-muted" : "player-volume"
      onClicked: {
        stream.muted = !stream.muted
      }
    }
  }

  RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    Label {
      Layout.fillHeight: true
      visible: !root.currentStream
      text: "Add at less one stream at applet configurations"
    }

    VideoOutput {
      id: v1
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: root.currentStream 
      MediaPlayer {
        id: stream
        source: root.currentStream
        autoPlay: true
        muted: true
        videoOutput: v1
        onError: {
          console.error("Failed to connect to the camera:", errorString)
        }
      }
    }
  }

  function populateModel() {
    const streamList = Plasmoid.configuration.streamsUrls
    for (let i = 0; i < streamList.length; i++) {
      const item = streamList[i]
      streamModel.append({ streamUrl: item.streamUrl, defaultStream: item.defaultStream})
    }
  }

  Connections {
    target: Plasmoid.configuration
    function onStreamsUrlsChanged(){
      streamModel.clear()
      populateModel()
    }
  }

  Component.onCompleted: {
    populateModel()
    stream.play()
  }
}
