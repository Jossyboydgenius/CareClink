package com.careclink.app

import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.ViewTreeObserver
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
                flutterEngine?.renderer?.let { renderer ->
                    renderer.surfaceHolder?.surface?.let { surface ->
                        if (surface.isValid) {
                            // This forces the surface to redraw
                            val surfaceView = flutterView.findViewById<android.view.View>(
                                io.flutter.R.id.flutter_surface_view
                            )
                            surfaceView?.requestLayout()
                        }
                    }
                }
            }, 100)
        }
    }
}

