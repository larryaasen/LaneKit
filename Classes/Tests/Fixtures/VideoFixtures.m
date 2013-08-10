//
//  VideoFixtures.m
//
//  This model fixture was created on 2013-08-10 by LaneKit v0.1.7.
//

#import "VideoFixtures.h"

@implementation VideoFixtures

+ (Video *)one
{
  Video *video = Video.new;

video.duration = @"MyString";
video.headline = @"MyString";
video.id = [NSNumber numberWithInteger:1];
video.image = @"MyString";
video.location = @"MyString";

  return video;
}

+ (Video *)two
{
  Video *video = Video.new;

  video.duration = @"MyString";
  video.headline = @"MyString";
  video.id = [NSNumber numberWithInteger:1];
  video.image = @"MyString";
  video.location = @"MyString";

  return video;
}

@end
