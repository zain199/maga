import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';

class AppThemeData {
  static ThemeData appThemeData(BuildContext context) {
    return ThemeData(
      fontFamily: 'CeraPro',
      scaffoldBackgroundColor: Colors.white,
      textTheme: appTextTheme,
      primaryColor: AppColors.colorPrimary,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.purple,
      tabBarTheme: TabBarTheme(
        unselectedLabelStyle:
            Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
        labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
        labelColor: AppColors.colorPrimary,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }
}
