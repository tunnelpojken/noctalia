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

    readonly property real   latitude:       pluginApi?.pluginSettings?.latitude       ?? 63.8258
    readonly property real   longitude:      pluginApi?.pluginSettings?.longitude      ?? 20.2630
    readonly property string locationName:   pluginApi?.pluginSettings?.locationName   ?? "Umeå"
    readonly property bool   useCelsius:     pluginApi?.pluginSettings?.useCelsius     ?? true
    readonly property bool   showHourly:     pluginApi?.pluginSettings?.showHourly     ?? true
    readonly property int    refreshMinutes: pluginApi?.pluginSettings?.refreshMinutes ?? 15

    readonly property color cyanBright: Color.mPrimary
    readonly property color cyanDim:    Color.mSecondary
    readonly property color cyanFaint:  Color.mOutline
    readonly property color bgCard:     Color.mSurface

    readonly property real baseH: showHourly ? 230 : 160
    implicitWidth:  Math.round(320 * widgetScale)
    implicitHeight: Math.round(baseH * widgetScale)
    width:  implicitWidth
    height: implicitHeight
    showBackground: false

    property real   currentTemp:   0
    property real   feelsLike:     0
    property real   tempMin:       0
    property real   tempMax:       0
    property int    weatherCode:   0
    property real   windSpeed:     0
    property int    humidity:      0
    property bool   isLoading:     true
    property bool   hasError:      false
    property string errorMsg:      ""
    property var    hourly:        []
    property string _rawJson:      ""

    function weatherInfo(code) {
        if (code===0)               return { desc:"CLEAR SKY",    glyph:"☀"  }
        if (code===1)               return { desc:"MAINLY CLEAR", glyph:"🌤" }
        if (code===2)               return { desc:"PARTLY CLOUDY",glyph:"⛅" }
        if (code===3)               return { desc:"OVERCAST",     glyph:"☁"  }
        if (code>=45&&code<=48)     return { desc:"FOG",          glyph:"🌫" }
        if (code>=51&&code<=55)     return { desc:"DRIZZLE",      glyph:"🌦" }
        if (code>=61&&code<=65)     return { desc:"RAIN",         glyph:"🌧" }
        if (code>=71&&code<=77)     return { desc:"SNOW",         glyph:"❄"  }
        if (code>=80&&code<=82)     return { desc:"RAIN SHOWERS", glyph:"🌧" }
        if (code>=85&&code<=86)     return { desc:"SNOW SHOWERS", glyph:"❄"  }
        if (code>=95&&code<=99)     return { desc:"THUNDERSTORM", glyph:"⛈" }
        return { desc:"UNKNOWN", glyph:"◈" }
    }

    function fmtTemp(t) {
        var v = useCelsius ? t : (t * 9/5 + 32)
        return Math.round(v) + (useCelsius ? "°C" : "°F")
    }

    function fmtHour(s) {
        var h = parseInt(s.substring(11,13))
        return (h<10?"0"+h:""+h)+":00"
    }

    Process {
        id: fetchProc
        property string url: ""
        command: ["curl","-s","--max-time","10",fetchProc.url]
        stdout: StdioCollector {
            onStreamFinished: { root._rawJson=text; root.parseWeather(text) }
        }
        onExited: function(code) {
            if (code!==0) { root.isLoading=false; root.hasError=true; root.errorMsg="NETWORK ERROR" }
        }
    }

    function fetchWeather() {
        root.isLoading=true; root.hasError=false
        var url="https://api.open-meteo.com/v1/forecast"
            +"?latitude="+root.latitude+"&longitude="+root.longitude
            +"&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m"
            +"&hourly=temperature_2m,weather_code,precipitation_probability"
            +"&daily=temperature_2m_max,temperature_2m_min&forecast_days=1&timezone=auto"
        fetchProc.url=url; fetchProc.running=false; fetchProc.running=true
    }

    function parseWeather(json) {
        try {
            var d=JSON.parse(json), c=d.current
            root.currentTemp=c.temperature_2m; root.feelsLike=c.apparent_temperature
            root.weatherCode=c.weather_code; root.windSpeed=c.wind_speed_10m; root.humidity=c.relative_humidity_2m
            root.tempMin=d.daily.temperature_2m_min[0]; root.tempMax=d.daily.temperature_2m_max[0]
            var nowHour=new Date().getHours(), times=d.hourly.time, temps=d.hourly.temperature_2m
            var codes=d.hourly.weather_code, prec=d.hourly.precipitation_probability, slots=[]
            for (var i=0; i<times.length&&slots.length<5; i++) {
                var h=parseInt(times[i].substring(11,13))
                if (h>nowHour) slots.push({hour:fmtHour(times[i]),temp:temps[i],code:codes[i],prec:prec[i]})
            }
            root.hourly=slots; root.isLoading=false; root.hasError=false
        } catch(e) { root.isLoading=false; root.hasError=true; root.errorMsg="PARSE ERROR" }
    }

    Timer {
        interval: root.refreshMinutes*60*1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.fetchWeather()
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
            shadowOpacity:          0.3
            shadowHorizontalOffset: 0
            shadowVerticalOffset:   0
        }

        Rectangle {
            width:  Math.round(3 * widgetScale)
            height: Math.round(parent.height * 0.6)
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            color:  root.cyanBright; radius: Math.round(2*widgetScale)
        }

        Column {
            visible: root.isLoading; anchors.centerIn: parent; spacing: Math.round(8*widgetScale)
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "◈"; font.pixelSize: Math.round(22*widgetScale); color: root.cyanDim
                SequentialAnimation on opacity { loops: Animation.Infinite; NumberAnimation{to:0.2;duration:700}
                    NumberAnimation{to:1.0;duration:700} } }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "RETRIEVING ATMOSPHERIC DATA"; font.pixelSize: Math.round(8*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "orbitron"; color: root.cyanFaint }
        }

        Column {
            visible: !root.isLoading && root.hasError; anchors.centerIn: parent; spacing: Math.round(6*widgetScale)
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "⚠"; font.pixelSize: Math.round(20*widgetScale); color: "#e87e7e" }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.errorMsg; font.pixelSize: Math.round(9*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "orbitron"; color: "#e87e7e" }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "TAP TO RETRY"; font.pixelSize: Math.round(8*widgetScale); font.letterSpacing: Math.round(1.5*widgetScale); font.family: "orbitron"; color: root.cyanFaint }
            MouseArea { anchors.horizontalCenter: parent.horizontalCenter; width: Math.round(120*widgetScale); height: Math.round(24*widgetScale); cursorShape: Qt.PointingHandCursor; onClicked: root.fetchWeather() }
        }

        ColumnLayout {
            visible: !root.isLoading && !root.hasError
            anchors { fill: parent; margins: Math.round(20*widgetScale) }
            spacing: Math.round(8*widgetScale)

            RowLayout {
                Layout.fillWidth: true
                Text { text: "NERV  //  ATMOSPHERIC"; font.pixelSize: Math.round(8*widgetScale); font.letterSpacing: Math.round(2.5*widgetScale); font.family: "orbitron"; color: root.cyanFaint }
                Item { Layout.fillWidth: true }
                Text { text: root.locationName.toUpperCase(); font.pixelSize: Math.round(8*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "orbitron"; color: root.cyanDim }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: Math.round(12*widgetScale)
                Text { text: root.weatherInfo(root.weatherCode).glyph; font.pixelSize: Math.round(44*widgetScale); Layout.alignment: Qt.AlignVCenter }
                ColumnLayout {
                    spacing: Math.round(2*widgetScale)
                    Text { text: root.fmtTemp(root.currentTemp); font.pixelSize: Math.round(40*widgetScale); font.family: "orbitron"; font.weight: Font.Light; color: root.cyanBright }
                    Text { text: root.weatherInfo(root.weatherCode).desc; font.pixelSize: Math.round(9*widgetScale); font.letterSpacing: Math.round(2*widgetScale); font.family: "orbitron"; color: root.cyanDim }
                }
                Item { Layout.fillWidth: true }
                ColumnLayout {
                    spacing: Math.round(4*widgetScale); Layout.alignment: Qt.AlignVCenter
                    StatLine { label:"FEELS"; value:root.fmtTemp(root.feelsLike);           ws:widgetScale }
                    StatLine { label:"WIND";  value:Math.round(root.windSpeed)+" km/h";     ws:widgetScale }
                    StatLine { label:"HUMID"; value:root.humidity+"%";                       ws:widgetScale }
                    StatLine { label:"↑↓";    value:root.fmtTemp(root.tempMax)+" "+root.fmtTemp(root.tempMin); ws:widgetScale }
                }
            }

            Rectangle { visible: root.showHourly&&root.hourly.length>0; Layout.fillWidth: true; height: Math.round(1*widgetScale); color: root.cyanFaint; opacity: 0.5 }

            RowLayout {
                visible: root.showHourly&&root.hourly.length>0; Layout.fillWidth: true; spacing: 0
                Repeater {
                    model: root.hourly
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: Math.round(3*widgetScale)
                        Text { Layout.alignment: Qt.AlignHCenter; text: modelData.hour; font.pixelSize: Math.round(8*widgetScale); font.family: "orbitron"; color: root.cyanFaint }
                        Text { Layout.alignment: Qt.AlignHCenter; text: root.weatherInfo(modelData.code).glyph; font.pixelSize: Math.round(16*widgetScale) }
                        Text { Layout.alignment: Qt.AlignHCenter; text: root.fmtTemp(modelData.temp); font.pixelSize: Math.round(11*widgetScale); font.family: "orbitron"; color: root.cyanBright }
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter; width: Math.round(28*widgetScale); height: Math.round(3*widgetScale); radius: Math.round(2*widgetScale); color: root.cyanFaint; opacity: 0.4
                            Rectangle { width: Math.round(Math.max(0,Math.min(1,modelData.prec/100))*parent.width); height: parent.height; radius: parent.radius; color: root.cyanBright; opacity: 1.0 }
                        }
                    }
                }
            }
        }

        Text {
            anchors { right: parent.right; bottom: parent.bottom; rightMargin: Math.round(10*widgetScale); bottomMargin: Math.round(6*widgetScale) }
            text: "♦"; font.pixelSize: Math.round(9*widgetScale); color: root.cyanFaint; opacity: 0.7
        }
    }

    component StatLine: RowLayout {
        property string label: ""; property string value: ""; property real ws: 1.0
        spacing: Math.round(5*ws)
        Text { text: label; font.pixelSize: Math.round(7.5*ws); font.letterSpacing: Math.round(1*ws); font.family: "orbitron"; color: Color.mOutline; Layout.minimumWidth: Math.round(36*ws) }
        Text { text: value; font.pixelSize: Math.round(9*ws); font.family: "orbitron"; color: Color.mSecondary }
    }
}
