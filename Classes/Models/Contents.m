//
//  Contents.m
//
//  This model was created on 2013-08-10 by LaneKit v0.1.7.
//

#import "Contents.h"
#import "RestKit.h"
#import "Video.h"

@implementation Contents

+ (void)initialize
{
  if (self == [Contents class])
  {
  }
}

+ (NSDictionary *)dictionaryForMappings
{
    return @{
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
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Contents class]];
    [mapping addAttributeMappingsFromDictionary:[self dictionaryForMappings]];

    [mapping addRelationshipMappingWithSourceKeyPath:@"contents" mapping:[Video modelMapping]];
    return mapping;
}

@end
