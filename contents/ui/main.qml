import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {

  id: plasmoid

  ListModel {
    id: streamModel
  }

  property var streamsList: Plasmoid.configuration.streamsUrls
  property string currentStream: Plasmoid.configuration.defaultStream
  property bool pin: false

  hideOnWindowDeactivate: !pin

  onPinChanged: updateHideBehavior()

  function populateModel() {
    if (streamsList.length > 0) {
      const json = JSON.parse(streamsList)
      json.forEach(item => {
        streamModel.append({ streamUrl: item.streamUrl, defaultStream: item.defaultStream})
        if (item.defaultStream) {
          currentStream = item.streamUrl
        }
      })
    }
  }

  fullRepresentation: Item {
    ColumnLayout {
      id: root
      width: 480
      height: 360
      
       RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop
        ComboBox {
          id: streamComboBox
          Layout.fillWidth: true
          model: streamModel
          delegate: ItemDelegate {
            text: model.streamUrl
            highlighted: streamComboBox.currentIndex === index
            onClicked: currentStream = model.streamUrl
          }
          onCurrentIndexChanged: {
            stream.stop()
            stream.source = currentStream 
            stream.play()
          }
        }

        PlasmaComponents.Button {
          id: muteButton
          icon.name: (audio.muted) ? "player-volume-muted" : "player-volume"
          onClicked: {
            audio.muted = !audio.muted
          }
        }

        PlasmaComponents.Button {
          id: pinButton
          icon.name: "window-pin"
          checkable: true
          checked: pin
          onToggled: pin = checked
          display: PlasmaComponents.AbstractButton.IconOnly
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        Label {
          Layout.fillHeight: visible ? true : false
          visible: !streamModel.count
          text: "Add at least one stream at applet configurations"
        }

        MediaPlayer {
          id: stream
          source: currentStream
          videoOutput: v1
          audioOutput: AudioOutput {
            id: audio
            muted: true
          }
          onErrorOccurred: {
            console.error("Failed to connect to the camera:", errorString)
          }
        }
 
        VideoOutput {
          id: v1
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.maximumWidth: 480
          Layout.maximumHeight: 360
          visible: streamModel.count
       }
      }

      Connections {
        target: Plasmoid.configuration
        function onStreamsUrlsChanged(){
          streamModel.clear()
          populateModel()
        }
      }

      Connections {
        target: plasmoid
 
        function startStream() {
          stream.source = currentStream
          stream.play()
        }

        function stopStream() {
          stream.stop()
          stream.source = ""
        }
     
       function onExpandedChanged() {
          plasmoid.expanded ? startStream() : stopStream()
        }
      }

      Component.onCompleted: {
        populateModel()
      }

    }

  }
}
