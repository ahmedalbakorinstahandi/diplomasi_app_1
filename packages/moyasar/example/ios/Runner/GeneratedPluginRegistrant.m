//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<moyasar/SwiftPlugin.h>)
#import <moyasar/SwiftPlugin.h>
#else
@import moyasar;
#endif

#if __has_include(<pay_ios/PayPlugin.h>)
#import <pay_ios/PayPlugin.h>
#else
@import pay_ios;
#endif

#if __has_include(<webview_flutter_wkwebview/WebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/WebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [SwiftPlugin registerWithRegistrar:[registry registrarForPlugin:@"SwiftPlugin"]];
  [PayPlugin registerWithRegistrar:[registry registrarForPlugin:@"PayPlugin"]];
  [WebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"WebViewFlutterPlugin"]];
}

@end
