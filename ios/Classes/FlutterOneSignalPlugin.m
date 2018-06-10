#import "FlutterOneSignalPlugin.h"
#import <flutter_one_signal/flutter_one_signal-Swift.h>
#import <OneSignal/OneSignal.h>

@implementation FlutterOneSignalPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterOneSignalPlugin registerWithRegistrar:registrar];
}
@end
