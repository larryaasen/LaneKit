//
//  Video.m
//
//  This model was created on 2013-08-10 by LaneKit v0.1.7.
//

#import "Video.h"
#import "RestKit.h"

@implementation Video

+ (void)initialize
{
  if (self == [Video class])
  {
  }
}

+ (NSDictionary *)dictionaryForMappings
{
    return @{
        @"duration": @"duration",
        @"headline": @"headline",
        @"id": @"id",
        @"image": @"image",
        @"location": @"location"
    };
}

// Returns the request RKObjectMapping
+ (RKObjectMapping *)requestMapping
{
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:[self dictionaryForMappings]];
    return requestMapping;
}

// Returns the response RKObjectMapping
+ (RKObjectMapping *)responseMapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Video class]];
    [mapping addAttributeMappingsFromDictionary:[self dictionaryForMappings]];
    return mapping;
}

@end
