# maplibre_android reaches these Flutter embedding classes through JNI by
# their original names. Without these rules R8 renames them in release builds
# and the MapLibre platform view is never created, leaving the map blank.
-keep class io.flutter.plugin.platform.PlatformView { *; }
-keep class io.flutter.plugin.platform.PlatformViewFactory { *; }
-keep class io.flutter.plugin.common.PluginRegistry { *; }
-keep class io.flutter.plugin.common.PluginRegistry$* { *; }
-keep class io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding { *; }
-keep class io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding$* { *; }
