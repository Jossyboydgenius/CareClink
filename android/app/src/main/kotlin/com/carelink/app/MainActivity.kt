package com.careclink.app

import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.SurfaceView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun onResume() {
        super.onResume()
        
        // Fix for Samsung devices running Android 14 where the screen turns black
        // when app is resumed from background
        // See GitHub issue: https://github.com/flutter/flutter/issues/139630
        if (Build.VERSION.SDK_INT >= 34 && 
            Build.MANUFACTURER.equals("samsung", ignoreCase = true)) {
            
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    // Try to find the Flutter surface view and request a layout
                    val flutterView = findViewById<SurfaceView>(
                        resources.getIdentifier("flutter_surface_view", "id", "io.flutter")
                    )
                    flutterView?.requestLayout()
                } catch (e: Exception) {
                    // Log error but allow app to continue
                    println("Error refreshing Flutter surface: ${e.message}")
                }
            }, 100)
        }
    }
}

