import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property bool isChinese: false
  readonly property string indicatorText: isChinese ? "中" : "A"
  readonly property string indicatorFontFamily: isChinese ? "Noto Sans CJK TC" : "Noto Sans"
  readonly property string tooltipTextValue: isChinese ? "中文/ㄅ" : "English"

  implicitWidth: Style.getCapsuleHeightForScreen(screen?.name)
  implicitHeight: Style.getCapsuleHeightForScreen(screen?.name)

  function refreshState() {
    if (!stateProc.running) {
      stateProc.running = true;
    }
  }

  Process {
    id: stateProc
    running: false
    command: ["sh", "-lc", "state=$(fcitx5-remote 2>/dev/null); im=$(fcitx5-remote -n 2>/dev/null); case \"$state:$im\" in 2:*bopomofo*|2:*Bopomofo*|2:mcbopomofo) printf zh ;; *) printf en ;; esac"]
    stdout: StdioCollector {
      id: stateStdout
    }
    onExited: (exitCode, exitStatus) => {
      if (exitCode === 0) {
        root.isChinese = stateStdout.text.trim() === "zh";
      }
      if (mouseArea.containsMouse) {
        TooltipService.updateText(root.tooltipTextValue);
      }
    }
  }

  Timer {
    id: pollTimer
    interval: 150
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refreshState()
  }

  Timer {
    id: delayedRefresh
    interval: 80
    repeat: false
    onTriggered: root.refreshState()
  }

  Rectangle {
    id: capsule
    width: root.implicitWidth
    height: root.implicitHeight
    anchors.centerIn: parent
    radius: Style.radiusL
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Text {
      anchors.centerIn: parent
      text: root.indicatorText
      font.family: root.indicatorFontFamily
      font.weight: Font.Normal
      font.pointSize: Math.max(1, Math.round(Style.getBarFontSizeForScreen(root.screen?.name) * 0.9))
      font.letterSpacing: root.isChinese ? 0 : 0.4
      color: mouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
      renderType: Text.NativeRendering
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton

    onEntered: {
      TooltipService.show(root, root.tooltipTextValue, BarService.getTooltipDirection(root.screen?.name));
    }
    onExited: {
      TooltipService.hide();
    }
    onClicked: {
      Quickshell.execDetached(["fcitx5-remote", "-t"]);
      delayedRefresh.restart();
    }
  }
}
