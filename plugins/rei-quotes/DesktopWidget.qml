import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.Commons
import qs.Modules.DesktopWidgets
import qs.Widgets

DraggableDesktopWidget {
    id: root
    property var pluginApi: null

    readonly property int  rotateInterval: pluginApi?.pluginSettings?.rotateInterval ?? 30
    readonly property bool showEpisode:    pluginApi?.pluginSettings?.showEpisode    ?? true
    readonly property bool showSpeaker:    pluginApi?.pluginSettings?.showSpeaker    ?? true

    readonly property color cyanBright: Color.mPrimary
    readonly property color cyanDim:    Color.mSecondary
    readonly property color cyanFaint:  Color.mOutline
    readonly property color bgCard:     Color.mSurface

    implicitWidth:  Math.round(340 * widgetScale)
    implicitHeight: Math.round(200 * widgetScale)
    width:  implicitWidth
    height: implicitHeight
    showBackground: false

    readonly property var quotes: [
        { text: "I mustn't run away.", speaker: "Rei Ayanami", source: "Episode 01" },
        { text: "I am not a doll.", speaker: "Rei Ayanami", source: "Episode 05" },
        { text: "My life was never precious. I am a vessel. Nothing more.", speaker: "Rei Ayanami", source: "Episode 14" },
        { text: "I don't know what to do when someone is kind to me.", speaker: "Rei Ayanami", source: "Episode 06" },
        { text: "What do you mean by 'others'? I have no such concept.", speaker: "Rei Ayanami", source: "Episode 14" },
        { text: "Pain. Is this what it means to feel?", speaker: "Rei Ayanami", source: "Episode 23" },
        { text: "Everyone who lives is... going to die. I am... not afraid of dying.", speaker: "Rei Ayanami", source: "Episode 23" },
        { text: "I exist to protect Ikari-kun.", speaker: "Rei Ayanami", source: "Episode 19" },
        { text: "Existence is pain. That is the only truth I have ever known.", speaker: "Rei Ayanami", source: "The End of Evangelion" },
        { text: "I thought I was a special person. But I'm just one person of many.", speaker: "Rei Ayanami", source: "The End of Evangelion" },
        { text: "I am not the only one.", speaker: "Rei Ayanami", source: "The End of Evangelion" },
        { text: "You need light to see... but I have been in the dark for so long I forget why.", speaker: "Rei Ayanami", source: "Episode 14" },
        { text: "Are you afraid? I'm not.", speaker: "Rei Ayanami", source: "Episode 02" },
        { text: "Smile? Why would I smile?", speaker: "Rei Ayanami", source: "Episode 05" },
        { text: "I feel... like I've known you before. Like a dream I can't quite remember.", speaker: "Rei Ayanami", source: "Evangelion 1.0" },
        { text: "Commander Ikari... is he someone special to you too?", speaker: "Rei Ayanami", source: "Episode 05" },
        { text: "Even if I am replaced, I will still be... Rei.", speaker: "Rei Ayanami", source: "Episode 23" },
        { text: "The sea of LCL. A world without form or boundary.", speaker: "Rei Ayanami", source: "The End of Evangelion" },
        { text: "I am made of your father's will and your mother's soul.", speaker: "Rei Ayanami", source: "The End of Evangelion" },
        { text: "You are not alone.", speaker: "Rei Ayanami", source: "The End of Evangelion" }
    ]

    property int  currentIndex:    0
    property real textOpacity:     1.0
    property bool isTransitioning: false
    property bool pendingPrev:     false

    Timer {
        interval: root.rotateInterval * 1000
        running:  true
        repeat:   true
        onTriggered: root.nextQuote()
    }

    function nextQuote() {
        if (isTransitioning) return
        isTransitioning = true
        fadeOut.start()
    }

    function prevQuote() {
        if (isTransitioning) return
        isTransitioning = true
        pendingPrev = true
        fadeOut.start()
    }

    NumberAnimation {
        id: fadeOut
        target:   root
        property: "textOpacity"
        to:       0.0
        duration: 400
        easing.type: Easing.InQuad
        onFinished: {
            if (root.pendingPrev) {
                root.currentIndex = (root.currentIndex - 1 + root.quotes.length) % root.quotes.length
                root.pendingPrev  = false
            } else {
                root.currentIndex = (root.currentIndex + 1) % root.quotes.length
            }
            fadeIn.start()
        }
    }

    NumberAnimation {
        id: fadeIn
        target:   root
        property: "textOpacity"
        to:       1.0
        duration: 600
        easing.type: Easing.OutQuad
        onFinished: root.isTransitioning = false
    }

    function pad(n) { return n < 10 ? "0" + n : "" + n }

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
            shadowOpacity:          0.3
            shadowHorizontalOffset: 0
            shadowVerticalOffset:   0
        }

        Rectangle {
            width:  Math.round(3 * widgetScale)
            height: Math.round(parent.height * 0.55)
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            color:  root.cyanBright
            radius: Math.round(2 * widgetScale)
        }

        ColumnLayout {
            anchors { fill: parent; margins: Math.round(22 * widgetScale) }
            spacing: Math.round(10 * widgetScale)

            RowLayout {
                spacing: Math.round(6 * widgetScale)
                Layout.fillWidth: true

                Text {
                    text:               "— EVANGELION"
                    font.pixelSize:     Math.round(9 * widgetScale)
                    font.letterSpacing: Math.round(3 * widgetScale)
                    font.family:        "monospace"
                    color:              root.cyanFaint
                }

                Item { Layout.fillWidth: true }

                Text {
                    text:           pad(currentIndex + 1) + " / " + pad(quotes.length)
                    font.pixelSize: Math.round(9 * widgetScale)
                    font.family:    "monospace"
                    color:          root.cyanFaint
                }
            }

            Text {
                text:           "\u201C"
                font.pixelSize: Math.round(36 * widgetScale)
                font.family:    "serif"
                color:          root.cyanBright
                opacity:        root.textOpacity * 0.6
                Layout.topMargin: Math.round(-10 * widgetScale)
            }

            Text {
                text:              root.quotes[root.currentIndex].text
                opacity:           root.textOpacity
                wrapMode:          Text.WordWrap
                font.pixelSize:    Math.round(14 * widgetScale)
                font.family:       "sans-serif"
                font.italic:       true
                lineHeight:        1.45
                color:             root.cyanBright
                Layout.fillWidth:  true
            }

            RowLayout {
                visible:          root.showSpeaker || root.showEpisode
                opacity:          root.textOpacity
                Layout.fillWidth: true
                spacing:          Math.round(6 * widgetScale)

                Text { text: "—"; font.pixelSize: Math.round(11 * widgetScale); font.family: "monospace"; color: root.cyanDim }
                Text { visible: root.showSpeaker; text: root.quotes[root.currentIndex].speaker; font.pixelSize: Math.round(11 * widgetScale); font.letterSpacing: Math.round(1 * widgetScale); font.family: "monospace"; color: root.cyanDim }
                Text { visible: root.showEpisode && root.showSpeaker; text: "·"; font.pixelSize: Math.round(11 * widgetScale); color: root.cyanFaint }
                Text { visible: root.showEpisode; text: root.quotes[root.currentIndex].source; font.pixelSize: Math.round(10 * widgetScale); font.family: "monospace"; color: root.cyanFaint }
                Item { Layout.fillWidth: true }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(8 * widgetScale)
                Item { Layout.fillWidth: true }

                Rectangle {
                    width: Math.round(26 * widgetScale); height: Math.round(26 * widgetScale)
                    radius: Math.round(6 * widgetScale)
                    color: prevHover.containsMouse ? Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b, 0.12) : "transparent"
                    border.width: Math.round(1 * widgetScale); border.color: root.cyanFaint
                    Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: Math.round(14 * widgetScale); color: root.cyanDim }
                    MouseArea { id: prevHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.prevQuote() }
                }

                Rectangle {
                    width: Math.round(26 * widgetScale); height: Math.round(26 * widgetScale)
                    radius: Math.round(6 * widgetScale)
                    color: nextHover.containsMouse ? Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b, 0.12) : "transparent"
                    border.width: Math.round(1 * widgetScale); border.color: root.cyanFaint
                    Text { anchors.centerIn: parent; text: "›"; font.pixelSize: Math.round(14 * widgetScale); color: root.cyanDim }
                    MouseArea { id: nextHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.nextQuote() }
                }
            }
        }

        Text {
            anchors { right: parent.right; top: parent.top; rightMargin: Math.round(10 * widgetScale); topMargin: Math.round(8 * widgetScale) }
            text: "♦"; font.pixelSize: Math.round(9 * widgetScale); color: root.cyanFaint; opacity: 0.7
        }
    }
}
