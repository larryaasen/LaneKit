//
//  Video.h
//
//  This model was created on 2013-08-10 by LaneKit v0.1.7.
//
// The following LaneKit command was used to generate this model:
// lanekit generate model Video duration:string headline:string id:integer image:string location:string
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface Video : NSObject

@property (nonatomic,strong) NSString *duration;
@property (nonatomic,strong) NSString *headline;
@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) NSString *location;

+ (RKObjectMapping *)requestMapping;
+ (RKObjectMapping *)responseMapping;

@end
