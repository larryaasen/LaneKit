//
//  NSObject+LKConventions.h
//
//  LaneKit is available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

@interface NSObject (LKConventions)
+ (NSSet *)allPropertyNames;
+ (NSString *)topPropertyNameByConvention;

- (id)topPropertyValueByConvention;
- (NSString *)descriptionOfTopProperty;
@end
