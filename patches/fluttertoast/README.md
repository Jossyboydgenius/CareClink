# Fluttertoast Fix

This is a temporary fix for the fluttertoast package that fails with errors like:

```
e: file:///Users/dreytech/.pub-cache/hosted/pub.dev/fluttertoast-8.2.8/android/src/main/kotlin/io/github/ponnamkarthik/toast/fluttertoast/FlutterToastPlugin.kt:9:48 Unresolved reference: Registrar
e: file:///Users/dreytech/.pub-cache/hosted/pub.dev/fluttertoast-8.2.8/android/src/main/kotlin/io/github/ponnamkarthik/toast/fluttertoast/MethodCallHandlerImpl.kt:18:24 Unresolved reference: FlutterMain
e: file:///Users/dreytech/.pub-cache/hosted/pub.dev/fluttertoast-8.2.8/android/src/main/kotlin/io/github/ponnamkarthik/toast/fluttertoast/MethodCallHandlerImpl.kt:74:35 Unresolved reference: FlutterMain
e: file:///Users/dreytech/.pub-cache/hosted/pub.dev/fluttertoast-8.2.8/android/src/main/kotlin/io/github/ponnamkarthik/toast/fluttertoast/MethodCallHandlerImpl.kt:90:39 Unresolved reference: FlutterMain
```

To fix this issue, you have two options:
1. Downgrade to fluttertoast: ^8.2.2 (which we did in pubspec.yaml)
2. If you still encounter issues, you may need to manually patch the Kotlin files in fluttertoast's Android directory

## Manual fix (if needed):
If the error persists after downgrading, you can run:

```bash
cd ~/.pub-cache/hosted/pub.dev/fluttertoast-<version>/android
```

And update the Kotlin files to use the newer Flutter embedding API.

Alternatively, consider using another toast package like another_fluttertoast or oktoast that's compatible with the latest Flutter versions.
