#import "PaddleOcrPlugin.h"
#if __has_include(<paddle_ocr/paddle_ocr-Swift.h>)
#import <paddle_ocr/paddle_ocr-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "paddle_ocr-Swift.h"
#endif

@implementation PaddleOcrPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPaddleOcrPlugin registerWithRegistrar:registrar];
}
@end
