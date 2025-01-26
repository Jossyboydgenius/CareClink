import 'package:flutter/material.dart';

class AppDimension {
  static late MediaQueryData mediaQuery;
  static late double screenHeight;
  static late double screenWidth;
  static late double defaultSize;
  static late Orientation orientation;
  static late bool isSmall;
  static late bool isTablet;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  
  static void init(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    screenHeight = mediaQuery.size.height;
    screenWidth = mediaQuery.size.width;
    orientation = mediaQuery.orientation;
    
    // Block sizes for responsive grid calculations
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    // Safe area paddings for notches and system UI
    _safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    _safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    
    // Safe area block sizes
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    
    // Default size for scaling (based on iPhone 12/13)
    defaultSize = orientation == Orientation.landscape 
        ? screenHeight * 0.024
        : screenWidth * 0.024;
    
    // Device type detection
    isSmall = screenHeight < 700 || screenWidth < 375;
    isTablet = screenWidth > 600;
  }

  static double getScaledSize(double size) {
    return size * defaultSize;
  }

  static double getHeight(double height) {
    double screenHeight = mediaQuery.size.height;
    // Scale height proportionally to screen height
    return (height / 812.0) * screenHeight;
  }

  static double getWidth(double width) {
    double screenWidth = mediaQuery.size.width;
    // Scale width proportionally to screen width
    return (width / 375.0) * screenWidth;
  }

  static double getFontSize(double size) {
    // Base size on the smaller screen dimension for consistent text
    double minSize = screenWidth < screenHeight ? screenWidth : screenHeight;
    double scaleFactor = minSize / 375.0; // Base scale on iPhone 12/13
    
    // Clamp the scale factor to prevent text from getting too large or small
    scaleFactor = scaleFactor.clamp(0.8, 1.2);
    
    return size * scaleFactor;
  }

  static EdgeInsets getSafeAreaPadding() {
    return mediaQuery.padding;
  }

  static double getResponsiveValue({
    required double forShortScreen,
    required double forNormalScreen,
    required double forTablet,
  }) {
    if (isTablet) return forTablet;
    if (isSmall) return forShortScreen;
    return forNormalScreen;
  }
} 