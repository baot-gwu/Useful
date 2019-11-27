import 'package:flutter/material.dart';

const gwuBlue = const Color(0xFF004065);
const gwuMiddleBlue = const Color(0xFF0073AA);
const gwuLightBlue = const Color(0xFF0099D9);
const gwuFlax = const Color(0xFFAA9868);
const gwuBackground = const Color(0xFFE3DCCC);
const BackgroundWhite = Colors.white;
const ErrorRed = const Color(0xFFC5032B);
const Material_design_Icon_Secondary = const Color(0xFF232F34);
const MaterialDesignLightGrey = const Color(0xFFEEEEEE);

final ThemeData usefulTheme = _buildUsefulTheme();

ThemeData _buildUsefulTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: gwuMiddleBlue,
    primaryColor: gwuBlue,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: gwuLightBlue,
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: BackgroundWhite,
    cardColor: BackgroundWhite,
    textSelectionColor: gwuLightBlue,
    errorColor: ErrorRed,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
