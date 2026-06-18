import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Modules.DesktopWidgets
import qs.Widgets

DraggableDesktopWidget {
    id: root
    property var pluginApi: null

    readonly property string pilotName:    pluginApi?.pluginSettings?.pilotName    ?? "REI"
    readonly property string unitNumber:   pluginApi?.pluginSettings?.unitNumber   ?? "00"
    readonly property bool   showSegments: pluginApi?.pluginSettings?.showSegments ?? true

    readonly property color cyanBright: Color.mPrimary
    readonly property color cyanDim:    Color.mSecondary
    readonly property color cyanFaint:  Color.mOutline
    readonly property color bgCard:     Color.mSurface
    readonly property color warnColor:  "#e8c77e"
    readonly property color critColor:  "#e87e7e"
    readonly property color critGlow:   "#ff4444"

    implicitWidth:  Math.round(320 * widgetScale)
    implicitHeight: Math.round(130 * widgetScale)
    width:  implicitWidth
    height: implicitHeight
    showBackground: false

    property real cpuPercent:     0
    property var  _prevIdle:      0
    property var  _prevTotal:     0
    property real displayPercent: 0

    Behavior on displayPercent {
        NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                var p=line.trim().split(/\s+/)
                var user=parseInt(p[1]),nice=parseInt(p[2]),system=parseInt(p[3]),idle=parseInt(p[4]),iowait=parseInt(p[5]),irq=parseInt(p[6]),softirq=parseInt(p[7])
                var total=user+nice+system+idle+iowait+irq+softirq
                var dTotal=total-root._prevTotal, dIdle=idle-root._prevIdle
                if (dTotal>0) { root.cpuPercent=Math.round((1-dIdle/dTotal)*100); root.displayPercent=root.cpuPercent }
                root._prevTotal=total; root._prevIdle=idle
            }
        }
    }

    Timer {
        interval: 1500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { cpuProc.running=false; cpuProc.running=true }
    }

    property color activeColor: {
        if (cpuPercent >= 85) return root.critColor
        if (cpuPercent >= 60) return root.warnColor
        return root.cyanBright
    }

    property color glowColor: {
        if (cpuPercent >= 85) return root.critGlow
        if (cpuPercent >= 60) return root.warnColor
        return root.cyanDim
    }

    property string statusText: {
        if (cpuPercent >= 85) return "CRITICAL"
        if (cpuPercent >= 60) return "ELEVATED"
        return "NOMINAL"
    }

    property real flashOpacity: 1.0

    SequentialAnimation {
        running: root.cpuPercent >= 85
        loops:   Animation.Infinite
        NumberAnimation { target: root; property: "flashOpacity"; to: 0.4; duration: 300 }
        NumberAnimation { target: root; property: "flashOpacity"; to: 1.0; duration: 300 }
    }

    Rectangle {
        anchors.fill: parent
        color:        root.bgCard
        radius:       Math.round(14 * widgetScale)
        border.width: Math.round(1  * widgetScale)
        border.color: root.cyanFaint
        opacity:      isDragging ? 0.85 : 1.0

        layer.enabled: !root.isScaling
        layer.effect: MultiEffect {
            shadowEnabled:          true
            shadowColor:            root.glowColor
            shadowBlur:             0.95
            shadowOpacity:          root.cpuPercent >= 85 ? 0.55 : 0.28
            shadowHorizontalOffset: 0
            shadowVerticalOffset:   0
        }

        Rectangle {
            width:  Math.round(3 * widgetScale)
            height: Math.round(parent.height * 0.6)
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            color:   root.activeColor
            radius:  Math.round(2 * widgetScale)
            opacity: root.flashOpacity
            Behavior on color { ColorAnimation { duration: 600 } }
        }

        ColumnLayout {
            anchors { fill: parent; margins: Math.round(18 * widgetScale) }
            spacing: Math.round(8 * widgetScale)

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(6 * widgetScale)

                Text {
                    text:               "NERV  //  SYNC RATE MONITOR"
                    font.pixelSize:     Math.round(8 * widgetScale)
                    font.letterSpacing: Math.round(2.5 * widgetScale)
                    font.family:        "monospace"
                    color:              root.cyanFaint
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width:        statusLabel.implicitWidth + Math.round(8 * widgetScale)
                    height:       Math.round(14 * widgetScale)
                    radius:       Math.round(3 * widgetScale)
                    color:        Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.15)
                    border.width: Math.round(1 * widgetScale)
                    border.color: root.activeColor
                    opacity:      root.flashOpacity
                    Behavior on border.color { ColorAnimation { duration: 600 } }

                    Text {
                        id:                 statusLabel
                        anchors.centerIn:   parent
                        text:               root.statusText
                        font.pixelSize:     Math.round(7 * widgetScale)
                        font.letterSpacing: Math.round(1.5 * widgetScale)
                        font.family:        "monospace"
                        color:              root.activeColor
                        Behavior on color { ColorAnimation { duration: 600 } }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(12 * widgetScale)

                Text { text: "UNIT-"+root.unitNumber; font.pixelSize: Math.round(10*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "monospace"; color: root.cyanFaint }
                Text { text: "/"; font.pixelSize: Math.round(10*widgetScale); font.family: "monospace"; color: root.cyanFaint; opacity: 0.4 }
                Text { text: root.pilotName; font.pixelSize: Math.round(10*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "monospace"; color: root.cyanDim }
                Item { Layout.fillWidth: true }
                Text {
                    text:           root.displayPercent.toFixed(0) + "%"
                    font.pixelSize: Math.round(28 * widgetScale)
                    font.family:    "monospace"
                    font.weight:    Font.Light
                    color:          root.activeColor
                    opacity:        root.flashOpacity
                    Behavior on color { ColorAnimation { duration: 600 } }
                }
            }

            Item {
                Layout.fillWidth: true
                height: Math.round((root.showSegments ? 18 : 10) * widgetScale)

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width:  Math.round(Math.max(0, Math.min(1, root.displayPercent/100)) * parent.width)
                    radius: Math.round(3 * widgetScale)
                    color:  Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.25)
                    Behavior on width { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 600 } }
                }

                Rectangle {
                    anchors.fill: parent; color: "transparent"; radius: Math.round(3*widgetScale)
                    border.width: Math.round(1*widgetScale); border.color: root.cyanFaint; opacity: 0.5
                }

                Row {
                    visible: root.showSegments; anchors.fill: parent; spacing: Math.round(2*widgetScale)
                    Repeater {
                        model: 20
                        Rectangle {
                            width:  Math.round((parent.parent.width - 19*Math.round(2*widgetScale))/20)
                            height: parent.height; radius: Math.round(2*widgetScale)
                            property bool active: root.displayPercent >= (index+1)*5
                            color:   active ? root.activeColor : Qt.rgba(Color.mOutline.r, Color.mOutline.g, Color.mOutline.b, 0.3)
                            opacity: active ? 1.0 : 0.4
                            Behavior on color   { ColorAnimation { duration: 400 } }
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: Math.round(4*widgetScale)
                Text { text: "CPU LOAD"; font.pixelSize: Math.round(8*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "monospace"; color: root.cyanFaint }
                Item { Layout.fillWidth: true }
                Text { text: "♦"; font.pixelSize: Math.round(8*widgetScale); color: root.cyanFaint; opacity: 0.5 }
            }
        }
    }
}
