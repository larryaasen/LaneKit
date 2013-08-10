//
//  Contents.h
//
//  This model was created on 2013-08-10 by LaneKit v0.1.7.
//
// The following LaneKit command was used to generate this model:
// lanekit generate model Contents contents:array:Video
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface Contents : NSObject

@property (nonatomic,strong) NSArray *contents;  // relates to: Video

+ (RKObjectMapping *)requestMapping;
+ (RKObjectMapping *)responseMapping;

@end
