import QtQuick 2.15
import QtQuick.Controls 2.8 
import QtQuick.Layouts 1.1
import QtMultimedia 5.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

ColumnLayout {
  property string currentStream: Plasmoid.configuration.defaultStream 

  width: 480
  height: 300
  Layout.preferredWidth: 480
  Layout.preferredHeight: 300
  Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

  Row {
    Layout.fillWidth: true
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground
    height: 30
    ComboBox {
      id: streamComboBox
      width: parent.width - 15 - muteButton.width
      anchors {
        top: parent.top
        left: parent.left
        margins: 5
      }
      model: ListModel {
        id: streamModel
      }
      delegate: ItemDelegate {
        text: model.streamUrl
        highlighted: streamComboBox.currentIndex === index
        onClicked: currentStream = model.streamUrl
      }
      onCurrentIndexChanged: {
        currentStream = model.get(currentIndex).streamUrl
      }
    }

    Button {
      id: muteButton
      icon.name: (stream.muted) ? "player-volume-muted" : "player-volume"
      anchors {
        top: parent.top
        right: parent.right
        margins: 5
      }
      onClicked: {
        stream.muted = !stream.muted
      }
    }
  }

  Row {
    Layout.preferredWidth: 480
    Layout.preferredHeight: 270
    anchors {
      margins: 5
    }
    Label {
      Layout.fillWidth: true
      height: 40 
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      visible: !currentStream
      text: "Add at less one stream at applet configurations"
    }

    VideoOutput {
      id: v1
      width: 480
      height: 270
      anchors.centerIn: parent
      visible: currentStream 
      MediaPlayer {
        id: stream
        source: currentStream
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


