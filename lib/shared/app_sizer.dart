import 'package:flutter/material.dart';

class AppDimension {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
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
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    
    // Block sizes for responsive grid calculations
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    // Safe area paddings for notches and system UI
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    
    // Safe area block sizes
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    
    // Initialize defaultSize based on orientation
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

  // Original method names for backward compatibility
  static double getWidth(double width) {
    return getProportionateScreenWidth(width);
  }

  static double getHeight(double height) {
    return getProportionateScreenHeight(height);
  }

  // New method names
  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / 812.0) * screenHeight;
  }

  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / 375.0) * screenWidth;
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
    return _mediaQueryData.padding;
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