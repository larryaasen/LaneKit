//
//  OneProvider.m
//
//  This provider was created on 2013-10-10 by LaneKit v0.2.1.
//
// The following LaneKit command was used to generate this file:
// lanekit generate provider one model_1 cnn.com
//

#import "OneProvider.h"
#import "Model_1.h"

@implementation OneProvider

- (id)processResult:(RKMappingResult *)mappingResult withError:(NSError **)error
{
  Model_1 *results = [mappingResult firstObject];
  id result = results;
  return result;
}

- (NSString *)baseURL
{
  return @"@cnn.com";
}

@end