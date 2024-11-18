import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtMultimedia 5.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
  
  readonly property string defaultStream: Plasmoid.configuration.defaultStream 

  width: 480
  height: (width / 16 * 9) + 10
  Layout.minimumWidth: 480
  Layout.maximumHeight: (width / 9 * 16) + 10
  Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

  PlasmaComponents.CheckBox {
    height: 10
    id: muteCheckBox
    text: i18n("Muted")
    checked: true
    visible: defaultStream
    anchors {
      bottom: parent.bottom
      left: parent.left
      margins: 10
      bottomMargin: 20
    }
    z: 1
    font.pixelSize: 10
    onCheckedChanged: {
      stream.muted = checked
      console.log("Mute toggled:", checked ? "Muted" : "Unmuted")
    }
  }

  PlasmaComponents.Label {
    Layout.fillWidth: true
    Layout.fillHeight: true
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    visible: !defaultStream
    text: "Add at less one stream at applet configurations"
  }

  VideoOutput {
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    source: stream
    visible: defaultStream 
    MediaPlayer {
      id: stream
      source: defaultStream
      autoPlay: true
      muted: true
      onError: {
        console.error("Failed to connect to the camera:", errorString)
      }
    }
  }
  Component.onCompleted: stream.play()
}


