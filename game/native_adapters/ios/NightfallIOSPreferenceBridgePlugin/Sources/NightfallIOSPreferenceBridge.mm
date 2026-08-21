#import <Foundation/Foundation.h>

#include "NightfallIOSPreferenceBridge.h"
#include "core/object/class_db.h"

static const NSUInteger NIGHTFALL_MAX_PAYLOAD_BYTES = 16 * 1024;
static NSString *const NIGHTFALL_APP_GROUP_KEY = @"NightfallPreferenceBridgeAppGroup";
static NSString *const NIGHTFALL_RELATIVE_PATH_KEY = @"NightfallPreferenceBridgeRelativePath";
static NSString *const NIGHTFALL_DEFAULT_RELATIVE_PATH = @"nightfall-bridge/expo-preferences.v1.json";

void NightfallIOSPreferenceBridge::_bind_methods() {
	ClassDB::bind_method(D_METHOD("read_approved_payload"), &NightfallIOSPreferenceBridge::read_approved_payload);
}

String NightfallIOSPreferenceBridge::read_approved_payload() {
	@autoreleasepool {
		id configured_group = [[NSBundle mainBundle] objectForInfoDictionaryKey:NIGHTFALL_APP_GROUP_KEY];
		if (![configured_group isKindOfClass:[NSString class]]) return String();
		NSString *app_group = (NSString *)configured_group;
		if (![app_group hasPrefix:@"group."] || app_group.length < 7) return String();

		id configured_path = [[NSBundle mainBundle] objectForInfoDictionaryKey:NIGHTFALL_RELATIVE_PATH_KEY];
		NSString *relative_path = [configured_path isKindOfClass:[NSString class]] ? (NSString *)configured_path : NIGHTFALL_DEFAULT_RELATIVE_PATH;
		if ([relative_path containsString:@".."] || [relative_path hasPrefix:@"/"]) return String();

		NSURL *container_url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:app_group];
		if (container_url == nil) return String();
		NSURL *payload_url = [container_url URLByAppendingPathComponent:relative_path isDirectory:NO];
		NSNumber *file_size = nil;
		NSError *metadata_error = nil;
		if (![payload_url getResourceValue:&file_size forKey:NSURLFileSizeKey error:&metadata_error] || metadata_error != nil || file_size == nil) return String();
		if (file_size.unsignedIntegerValue == 0 || file_size.unsignedIntegerValue > NIGHTFALL_MAX_PAYLOAD_BYTES) return String();

		NSError *read_error = nil;
		NSData *payload_data = [NSData dataWithContentsOfURL:payload_url options:0 error:&read_error];
		if (payload_data == nil || read_error != nil || payload_data.length == 0 || payload_data.length > NIGHTFALL_MAX_PAYLOAD_BYTES) return String();
		NSString *payload = [[NSString alloc] initWithData:payload_data encoding:NSUTF8StringEncoding];
		return payload == nil ? String() : String::utf8(payload.UTF8String);
	}
}
