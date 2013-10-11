//
//  One.m
//
//  This model was created on 2013-10-10 by LaneKit v0.2.1.
//
// The following LaneKit command was used to generate this file:
// lanekit generate model one
//

#import "One.h"

@implementation One

// Dictionary to convert self to JSON
+ (NSDictionary *)dictionaryForRequestMappings
{
    return @{
             // source key path : destination attribute name
    };
}

// Dictionary to convert JSON to self
+ (NSDictionary *)dictionaryForResponseMappings
{
  return @{
           // source key path : destination attribute name
    };
}

+ (NSString *)keyPath
{
  return @"one";
}

@end
