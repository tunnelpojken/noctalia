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

    readonly property string diskPath: pluginApi?.pluginSettings?.diskPath ?? "/"
    readonly property bool   showBars: pluginApi?.pluginSettings?.showBars ?? true

    readonly property color cyanBright: Color.mPrimary
    readonly property color cyanDim:    Color.mSecondary
    readonly property color cyanFaint:  Color.mOutline
    readonly property color warnColor:  "#e8c77e"
    readonly property color critColor:  "#e87e7e"

    readonly property real cardW:   108
    readonly property real gap:     10
    readonly property real totalW:  cardW * 3 + gap * 2
    readonly property real totalH:  showBars ? 170 : 150

    implicitWidth:  Math.round(totalW * widgetScale)
    implicitHeight: Math.round(totalH * widgetScale)
    width:  implicitWidth
    height: implicitHeight
    showBackground: false

    property real cpuPercent:    0
    property var  _prevCpuIdle:  0
    property var  _prevCpuTotal: 0
    property real ramPercent:    0
    property real ramUsedGiB:    0
    property real ramTotalGiB:   0
    property real diskPercent:   0
    property real diskUsedGiB:   0
    property real diskTotalGiB:  0

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: function(line) {
                if (!line.startsWith("cpu ")) return
                var p = line.trim().split(/\s+/)
                var user=parseInt(p[1]),nice=parseInt(p[2]),system=parseInt(p[3]),idle=parseInt(p[4]),iowait=parseInt(p[5]),irq=parseInt(p[6]),softirq=parseInt(p[7])
                var total=user+nice+system+idle+iowait+irq+softirq
                var dTotal=total-root._prevCpuTotal, dIdle=idle-root._prevCpuIdle
                if (dTotal>0) root.cpuPercent=Math.round((1-dIdle/dTotal)*100)
                root._prevCpuTotal=total; root._prevCpuIdle=idle
            }
        }
    }

    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: function(line) {
                var p=line.split(/\s+/), key=p[0], val=parseInt(p[1])
                if (key==="MemTotal:") root.ramTotalGiB=val/1048576
                else if (key==="MemAvailable:") {
                    root.ramUsedGiB=root.ramTotalGiB-(val/1048576)
                    if (root.ramTotalGiB>0) root.ramPercent=Math.round((root.ramUsedGiB/root.ramTotalGiB)*100)
                }
            }
        }
    }

    Process {
        id: diskProc
        command: ["df", "-BG", "--output=size,used,pcent", root.diskPath]
        stdout: SplitParser {
            onRead: function(line) {
                line=line.trim()
                if (line.match(/^\d/)) {
                    var p=line.split(/\s+/)
                    if (p.length>=3) {
                        root.diskTotalGiB=parseInt(p[0])
                        root.diskUsedGiB=parseInt(p[1])
                        root.diskPercent=parseInt(p[2].replace("%",""))
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running:  true
        repeat:   true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running=false; memProc.running=false; diskProc.running=false
            cpuProc.running=true;  memProc.running=true;  diskProc.running=true
        }
    }

    function statColor(pct) {
        if (pct>=85) return root.critColor
        if (pct>=60) return root.warnColor
        return root.cyanBright
    }

    function fmtGiB(v) { return v<10 ? v.toFixed(1)+"G" : Math.round(v)+"G" }

    RowLayout {
        anchors.fill: parent
        spacing: Math.round(root.gap * widgetScale)

        MagiCard { label:"MELCHIOR";  sublabel:"CPU";  value:root.cpuPercent;  detail:root.cpuPercent+"%";                                         color1:root.statColor(root.cpuPercent);  showBar:root.showBars; ws:root.widgetScale; isScaling:root.isScaling; Layout.fillHeight:true; Layout.preferredWidth:Math.round(root.cardW*widgetScale) }
        MagiCard { label:"BALTHASAR"; sublabel:"RAM";  value:root.ramPercent;  detail:root.fmtGiB(root.ramUsedGiB)+" / "+root.fmtGiB(root.ramTotalGiB);  color1:root.statColor(root.ramPercent);  showBar:root.showBars; ws:root.widgetScale; isScaling:root.isScaling; Layout.fillHeight:true; Layout.preferredWidth:Math.round(root.cardW*widgetScale) }
        MagiCard { label:"CASPAR";    sublabel:"DISK"; value:root.diskPercent; detail:root.fmtGiB(root.diskUsedGiB)+" / "+root.fmtGiB(root.diskTotalGiB); color1:root.statColor(root.diskPercent); showBar:root.showBars; ws:root.widgetScale; isScaling:root.isScaling; Layout.fillHeight:true; Layout.preferredWidth:Math.round(root.cardW*widgetScale) }
    }

    component MagiCard: Item {
        property string label:     ""
        property string sublabel:  ""
        property real   value:     0
        property string detail:    ""
        property color  color1:    Color.mPrimary
        property bool   showBar:   true
        property real   ws:        1.0
        property bool   isScaling: false

        Rectangle {
            anchors.fill:  parent
            color:         Color.mSurface
            radius:        Math.round(12 * ws)
            border.width:  Math.round(1  * ws)
            border.color:  Color.mOutline

            layer.enabled: !isScaling
            layer.effect: MultiEffect {
                shadowEnabled:          true
                shadowColor:            color1
                shadowBlur:             0.8
                shadowOpacity:          0.18
                shadowHorizontalOffset: 0
                shadowVerticalOffset:   0
            }

            ColumnLayout {
                anchors { fill: parent; margins: Math.round(10 * ws) }
                spacing: Math.round(4 * ws)

                Text { text: label;   font.pixelSize: Math.round(7.5*ws); font.letterSpacing: Math.round(2*ws); font.family: "orbitron"; color: Color.mOutline; Layout.alignment: Qt.AlignHCenter }
                Text { text: sublabel; font.pixelSize: Math.round(9*ws); font.letterSpacing: Math.round(1.5*ws); font.family: "orbitron"; color: color1; Layout.alignment: Qt.AlignHCenter }

                Text {
                    text: Math.round(value)+"%"
                    font.pixelSize: Math.round(30*ws); font.family: "orbitron"; font.weight: Font.Light
                    color: color1; Layout.alignment: Qt.AlignHCenter
                    Behavior on color { enabled: !isScaling; ColorAnimation { duration: 800 } }
                }

                Text { text: detail; font.pixelSize: Math.round(9*ws); font.family: "orbitron"; color: Color.mSecondary; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }

                Rectangle {
                    visible: showBar; Layout.fillWidth: true; height: Math.round(4*ws); radius: Math.round(2*ws)
                    color: Qt.rgba(Color.mOutline.r, Color.mOutline.g, Color.mOutline.b, 0.4)
                    Rectangle {
                        width:  Math.round(Math.max(0,Math.min(1,value/100))*parent.width)
                        height: parent.height; radius: parent.radius; color: color1
                        Behavior on width { enabled: !isScaling; NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                        Behavior on color { enabled: !isScaling; ColorAnimation { duration: 800 } }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Math.round(3*ws)
                    Repeater {
                        model: 3
                        Rectangle {
                            width: Math.round(4*ws); height: Math.round(4*ws); radius: width/2
                            color: index < Math.ceil(value/34) ? color1 : Qt.rgba(Color.mOutline.r, Color.mOutline.g, Color.mOutline.b, 0.4)
                            Behavior on color { enabled: !isScaling; ColorAnimation { duration: 400 } }
                        }
                    }
                }
            }
        }
    }
}
