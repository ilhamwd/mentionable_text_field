#import "MentionableTextFieldPlugin.h"
#if __has_include(<mentionable_text_field/mentionable_text_field-Swift.h>)
#import <mentionable_text_field/mentionable_text_field-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mentionable_text_field-Swift.h"
#endif

@implementation MentionableTextFieldPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMentionableTextFieldPlugin registerWithRegistrar:registrar];
}
@end
