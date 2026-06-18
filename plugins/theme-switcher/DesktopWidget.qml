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

    property string activeTheme: "lcl-deep-blue"

    readonly property var themes: [
        { id:"lcl-deep-blue", name:"LCL DEEP BLUE",  sub:"Rei Ayanami · Unit-00",    glyph:"〇", script:"apply-lcl-deep-blue.sh" },
        { id:"third-impact",  name:"THIRD IMPACT",   sub:"Instrumentality · Lilith", glyph:"◈", script:"apply-third-impact.sh"  },
        { id:"unit-01",       name:"UNIT-01",         sub:"Shinji Ikari · Yui",       glyph:"△", script:"apply-unit-01.sh"       }
    ]

    implicitWidth:  Math.round(300 * widgetScale)
    implicitHeight: Math.round(220 * widgetScale)
    width:  implicitWidth; height: implicitHeight
    showBackground: false

    Process {
        id: readActive
        command: ["cat", "/home/fested/.config/noctalia/theme-override.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { var d=JSON.parse(text); if(d.active) root.activeTheme=d.active } catch(e){}
            }
        }
    }

    Process {
        id: scriptProc; property string scriptPath:""
        command: ["bash", scriptProc.scriptPath]
    }

    function applyTheme(themeId, scriptName) {
        root.activeTheme=themeId
        scriptProc.scriptPath="/home/fested/.config/noctalia/theme-scripts/"+scriptName
        scriptProc.running=false; scriptProc.running=true
    }

    Component.onCompleted: readActive.running=true

    Rectangle {
        anchors.fill:parent; color:Color.mSurface; radius:Math.round(16*widgetScale)
        border.width:Math.round(1*widgetScale); border.color:Color.mOutline
        opacity:isDragging?0.85:1.0

        layer.enabled:!root.isScaling
        layer.effect:MultiEffect{shadowEnabled:true;shadowColor:Color.mSecondary;shadowBlur:0.85;shadowOpacity:0.25;shadowHorizontalOffset:0;shadowVerticalOffset:0}

        Rectangle {
            width:Math.round(3*widgetScale); height:Math.round(parent.height*0.6)
            anchors{left:parent.left;verticalCenter:parent.verticalCenter}
            color:Color.mPrimary; radius:Math.round(2*widgetScale)
        }

        ColumnLayout {
            anchors{fill:parent;margins:Math.round(18*widgetScale)}
            spacing:Math.round(10*widgetScale)

            Text { text:"NERV  //  THEME MATRIX"; font.pixelSize:Math.round(8*widgetScale); font.letterSpacing:Math.round(2.5*widgetScale); font.family:"monospace"; color:Color.mOutline }

            Repeater {
                model:root.themes
                delegate:ThemeButton {
                    themeDef:modelData; isActive:root.activeTheme===modelData.id
                    ws:root.widgetScale; isScalingWS:root.isScaling
                    Layout.fillWidth:true
                    onActivated:root.applyTheme(modelData.id, modelData.script)
                }
            }

            Item { Layout.fillHeight:true }

            Text { text:"♦  EVANGELION DESKTOP SYSTEM"; font.pixelSize:Math.round(7.5*widgetScale); font.letterSpacing:Math.round(1.5*widgetScale); font.family:"monospace"; color:Color.mOutline; Layout.alignment:Qt.AlignHCenter }
        }
    }

    component ThemeButton: Item {
        id: btn
        property var    themeDef:    ({})
        property bool   isActive:    false
        property real   ws:          1.0
        property bool   isScalingWS: false
        signal activated()
        height: Math.round(46*ws)

        Rectangle {
            anchors.fill:parent; radius:Math.round(10*ws)
            color:isActive ? Qt.rgba(Color.mPrimary.r,Color.mPrimary.g,Color.mPrimary.b,0.14) : hover.containsMouse ? Qt.rgba(1,1,1,0.04) : "transparent"
            border.width:Math.round(1*ws); border.color:isActive ? Color.mPrimary : Color.mOutline
            Behavior on color        { ColorAnimation{duration:300} }
            Behavior on border.color { ColorAnimation{duration:300} }

            layer.enabled:isActive&&!isScalingWS
            layer.effect:MultiEffect{shadowEnabled:true;shadowColor:Color.mPrimary;shadowBlur:0.8;shadowOpacity:0.3;shadowHorizontalOffset:0;shadowVerticalOffset:0}

            RowLayout {
                anchors{fill:parent;leftMargin:Math.round(12*ws);rightMargin:Math.round(12*ws);topMargin:Math.round(6*ws);bottomMargin:Math.round(6*ws)}
                spacing:Math.round(10*ws)

                Text { text:btn.themeDef.glyph??"◈"; font.pixelSize:Math.round(18*ws); color:Color.mPrimary; opacity:isActive?1.0:0.5; Behavior on opacity{NumberAnimation{duration:300}} }

                ColumnLayout { spacing:Math.round(1*ws)
                    Text { text:btn.themeDef.name??""; font.pixelSize:Math.round(10*ws); font.letterSpacing:Math.round(1.5*ws); font.family:"monospace"; font.weight:isActive?Font.Medium:Font.Light; color:isActive?Color.mPrimary:Color.mSecondary; Behavior on color{ColorAnimation{duration:300}} }
                    Text { text:btn.themeDef.sub??"";  font.pixelSize:Math.round(8*ws);  font.family:"monospace"; color:isActive?Color.mSecondary:Color.mOutline; Behavior on color{ColorAnimation{duration:300}} }
                }

                Item { Layout.fillWidth:true }

                Rectangle { width:Math.round(6*ws); height:Math.round(6*ws); radius:width/2; color:Color.mPrimary; opacity:isActive?1.0:0.0; Behavior on opacity{NumberAnimation{duration:300}} }
            }

            MouseArea { id:hover; anchors.fill:parent; hoverEnabled:true; cursorShape:Qt.PointingHandCursor; onClicked:btn.activated() }
        }
    }
}
