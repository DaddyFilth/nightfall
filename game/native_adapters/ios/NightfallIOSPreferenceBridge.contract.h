// Contract header for a future Godot iOS plugin. Not compiled by this repository.
// A signed Xcode export must provide this class through a .gdip + static library or .xcframework.
#import <Foundation/Foundation.h>

@interface NightfallIOSPreferenceBridge : NSObject
// Return UTF-8 JSON only from an approved, host-copied app-group or container location.
// Return an empty string for missing, oversized, or unreadable payloads.
- (NSString *)read_approved_payload;
@end

