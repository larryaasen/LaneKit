//
//  OneTest.m
//
//  This model test was created on 2013-10-10 by LaneKit v0.2.1.
//
// The following LaneKit command was used to generate this file:
// lanekit generate model one
//

#import "OneTest.h"
#import "OneFixtures.h"

@implementation OneTest

- (void)setUp
{
  [super setUp];
  
  // Set-up code here.
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}

- (void)testOneNewOne
{
  One *one = OneFixtures.one;
  STAssertNotNil(one, @"one is nil");

}

- (void)testOneNewTwo
{
  One *one = OneFixtures.two;
  STAssertNotNil(one, @"one is nil");

}

- (void)testMapping
{
  RKObjectMapping *requestMapping = [One requestMapping];
  STAssertNotNil(requestMapping, @"[One requestMapping] returned nil.");
  
  RKObjectMapping *responseMapping = [One responseMapping];
  STAssertNotNil(responseMapping, @"[One responseMapping] returned nil.");
}

@end
