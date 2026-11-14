// Custom bootstrap: the default one still registers Flutter's deprecated
// service worker. scripts/build.js rewrites the bundle paths in the build
// config below to their fingerprinted names.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();
