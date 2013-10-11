//
//  LKModel.h
//
//  This base model was created on 2013-10-10 by LaneKit v0.2.1.
//
// The following LaneKit command was used to generate this file:
// lanekit generate model one
//

#import "RestKit.h"

@interface LKModel : NSObject

+ (NSDictionary *)dictionaryForRequestMappings;  // Used by providers.
+ (NSDictionary *)dictionaryForResponseMappings; // Used by providers.
+ (NSString *)keyPath;                    // Used by providers. The subset of the parsed response for which the mapping is to be used.
+ (NSString *)pathPattern;                // Used by providers. The pattern that matches against URLs for which the mapping should be used.
+ (RKObjectMapping *)requestMapping;      // Used by providers. Returns the request RKObjectMapping
+ (RKObjectMapping *)responseMapping;     // Used by providers. Returns the response RKObjectMapping

@end
