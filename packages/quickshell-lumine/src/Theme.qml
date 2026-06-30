pragma Singleton
import QtQuick

QtObject {

  // Dimensions and Spacing
  property int barHeight: 32
  property int spacing: 8
  property int padding: 20
  property int radius: 10

  property int unreadDotSize: 8
  property int menuWidth: 400
  property int popupWidth: 380
  property int notifIconSize: 36

  // Typography
  property string fontFamilyMain: "DejaVuSansMono"
  property string fontFamilyAlt: "Inter"

  property int fontSizeSmall: 12
  property int fontSizeMedium: 16
  property int fontSizeLarge: 18
  property int fontSizeTitle: 20

  property font mainFont: Qt.font({
                                    family: fontFamilyMain,
                                    pixelSize: fontSizeMedium
                                  })

  property font smallFont: Qt.font({
                                     family: fontFamilyMain,
                                     pixelSize: fontSizeSmall
                                   })

  property font titleFont: Qt.font({
                                     family: fontFamilyMain,
                                     pixelSize: fontSizeTitle,
                                     bold: true
                                   })

  property font cardTitleFont: Qt.font({
                                         family: fontFamilyAlt,
                                         pixelSize: fontSizeMedium,
                                         bold: true
                                       })

  // Threshold and logic
  readonly property int tempOk: 60
  readonly property int tempWarn: 70
  readonly property int tempErr: 80
  readonly property int tempCrit: 90

  readonly property color colNormal: colText
  readonly property color colOk: colGreen
  readonly property color colWarn: colYellow
  readonly property color colErr: colMaroon
  readonly property color colCrit: colRed

  // Used Colors
  property color background: colBase
  property color text: colText
  property color primary: colPeach
  property color secondary: colLavender
  property color dim: colOverlay0

  // Palette - Catppuccin Mocha
  property color colRosewater: "#f5e0dc"
  property color colFlamingo: "#f2cdcd"
  property color colPink: "#f5c2e7"
  property color colMauve: "#cba6f7"
  property color colRed: "#f38ba8"
  property color colMaroon: "#eba0ac"
  property color colPeach: "#fab387"
  property color colYellow: "#f9e2af"
  property color colGreen: "#a6e3a1"
  property color colTeal: "#94e2d5"
  property color colSky: "#89dceb"
  property color colSapphire: "#74c7ec"
  property color colBlue: "#89b4fa"
  property color colLavender: "#b4befe"

  property color colText: "#cdd6f4"
  property color colSubtext1: "#bac2de"
  property color colSubtext0: "#a6adc8"
  property color colOverlay2: "#9399b2"
  property color colOverlay1: "#7f849c"
  property color colOverlay0: "#6c7086"

  property color colSurface2: "#585b70"
  property color colSurface1: "#45475a"
  property color colSurface0: "#313244"
  property color colBase: "#1e1e2e"
  property color colMantle: "#181825"
  property color colCrust: "#11111b"
}
