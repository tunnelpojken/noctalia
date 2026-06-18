import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.Commons
import qs.Modules.DesktopWidgets
import qs.Widgets

DraggableDesktopWidget {
    id: root
    property var pluginApi: null

    readonly property bool showSeconds:  pluginApi?.pluginSettings?.showSeconds  ?? true
    readonly property bool showDate:     pluginApi?.pluginSettings?.showDate     ?? true
    readonly property bool showHEXTime:  pluginApi?.pluginSettings?.showHEXTime  ?? true
    readonly property bool use24Hour:    pluginApi?.pluginSettings?.use24Hour    ?? true

    readonly property color cyanBright: Color.mPrimary
    readonly property color cyanDim:    Color.mSecondary
    readonly property color cyanFaint:  Color.mOutline
    readonly property color bgCard:     Color.mSurface

    readonly property real baseH: showDate ? (showHEXTime ? 190 : 162) : (showHEXTime ? 148 : 120)
    implicitWidth:  Math.round(340 * widgetScale)
    implicitHeight: Math.round(baseH * widgetScale)
    width:  implicitWidth
    height: implicitHeight
    showBackground: false

    property var now: new Date()

    Timer {
        interval: showSeconds ? 1000 : 10000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    function pad(n) { return n < 10 ? "0" + n : "" + n }

    function timeString() {
        var h = now.getHours()
        var m = now.getMinutes()
        var s = now.getSeconds()
        if (!use24Hour) { h = h % 12; if (h === 0) h = 12 }
        return pad(h) + ":" + pad(m) + (showSeconds ? ":" + pad(s) : "")
    }

    function dateString() {
        var days   = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
        var months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        return days[now.getDay()] + "  " + pad(now.getDate()) + " " + months[now.getMonth()] + " " + now.getFullYear()
    }

    function hexTimeString() {
        return "#" + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds())
    }

    function hexTimeColor() {
        var r = Math.round(20  + (now.getHours()   / 23) * 40)
        var g = Math.round(120 + (now.getMinutes() / 59) * 80)
        var b = Math.round(160 + (now.getSeconds() / 59) * 80)
        return Qt.rgba(r/255, g/255, b/255, 1.0)
    }

    Rectangle {
        anchors.fill: parent
        color:        root.bgCard
        radius:       Math.round(16 * widgetScale)
        border.width: Math.round(1  * widgetScale)
        border.color: root.cyanFaint
        opacity:      isDragging ? 0.85 : 1.0

        layer.enabled: !root.isScaling
        layer.effect: MultiEffect {
            shadowEnabled:          true
            shadowColor:            root.cyanDim
            shadowBlur:             0.9
            shadowOpacity:          0.35
            shadowHorizontalOffset: 0
            shadowVerticalOffset:   0
        }

        Rectangle {
            width:  Math.round(3 * widgetScale)
            height: Math.round(parent.height * 0.6)
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            color:  root.cyanBright
            radius: Math.round(2 * widgetScale)
        }

        ColumnLayout {
            anchors { fill: parent; margins: Math.round(22 * widgetScale) }
            spacing: Math.round(6 * widgetScale)

            Text {
                text:               "NERV LOCAL TIME"
                font.pixelSize:     Math.round(8  * widgetScale)
                font.letterSpacing: Math.round(3.5 * widgetScale)
                font.family:        "orbitron"
                color:              root.cyanFaint
            }

            Text {
                text:           root.timeString()
                font.pixelSize: Math.round(58 * widgetScale)
                font.family:    "orbitron"
                font.weight:    Font.Light
                color:          root.cyanBright
                Layout.alignment: Qt.AlignHCenter

                SequentialAnimation on opacity {
                    running: false
                    loops:   Animation.Infinite
                    NumberAnimation { to: 0.75; duration: 100 }
                    NumberAnimation { to: 1.0;  duration: 400 }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height:           Math.round(1 * widgetScale)
                color:            root.cyanFaint
                opacity:          0.6
                visible:          showDate || showHEXTime
            }

            Text {
                visible:            root.showDate
                text:               root.dateString()
                font.pixelSize:     Math.round(12 * widgetScale)
                font.letterSpacing: Math.round(2  * widgetScale)
                font.family:        "monospace"
                color:              root.cyanDim
                Layout.alignment:   Qt.AlignHCenter
            }

            RowLayout {
                visible:          root.showHEXTime
                Layout.alignment: Qt.AlignHCenter
                spacing:          Math.round(8 * widgetScale)

                Rectangle {
                    width:        Math.round(12 * widgetScale)
                    height:       Math.round(12 * widgetScale)
                    radius:       Math.round(3  * widgetScale)
                    color:        root.hexTimeColor()
                    border.width: Math.round(1  * widgetScale)
                    border.color: Qt.rgba(1,1,1,0.15)
                }

                Text {
                    text:               root.hexTimeString()
                    font.pixelSize:     Math.round(11 * widgetScale)
                    font.letterSpacing: Math.round(1.5 * widgetScale)
                    font.family:        "monospace"
                    color:              root.hexTimeColor()
                }
            }
        }

        Text {
            anchors {
                right:        parent.right
                bottom:       parent.bottom
                rightMargin:  Math.round(10 * widgetScale)
                bottomMargin: Math.round(6  * widgetScale)
            }
            text:           "♦"
            font.pixelSize: Math.round(9 * widgetScale)
            color:          root.cyanFaint
            opacity:        0.7
        }
    }
}
