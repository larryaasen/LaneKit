//
//  ContentsTest.m
//
//  This model test was created on 2013-08-10 by LaneKit v0.1.7.
//

#import "ContentsTest.h"
#import "ContentsFixtures.h"

@implementation ContentsTest

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

- (void)testContentsNewOne
{
  Contents *contents = ContentsFixtures.one;
  STAssertNotNil(contents, @"contents is nil");


}

- (void)testContentsNewTwo
{
  Contents *contents = ContentsFixtures.two;
  STAssertNotNil(contents, @"contents is nil");


}

- (void)testMapping
{
  RKObjectMapping *requestMapping = [Contents requestMapping];
  STAssertNotNil(requestMapping, @"[Contents requestMapping] returned nil.");
  
  RKObjectMapping *responseMapping = [Contents responseMapping];
  STAssertNotNil(responseMapping, @"[Contents responseMapping] returned nil.");
}

@end
