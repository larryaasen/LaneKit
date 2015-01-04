//
//  NSObject+LKConventions.m
//
//  LaneKit is available under the MIT license. See the LICENSE file for more info.
//
//  Example:
//    cell.textLabel.text = [model descriptionOfTopProperty];

//

#import "NSObject+LKConventions.h"
#import<objc/runtime.h>

@implementation NSObject (LKConventions)

// Returns an array of all of property names in this class.
+ (NSSet *)allPropertyNames
{
  unsigned count;
  objc_property_t *propertyList = class_copyPropertyList([self class], &count);
  
  NSMutableSet *properties = NSMutableSet.set;
  
  for (unsigned zz=0; zz<count; zz++)
  {
    objc_property_t property = propertyList[zz];
    NSString *name = [NSString stringWithUTF8String:property_getName(property)];
    [properties addObject:name];
  }
  
  free(propertyList);
  
  return [properties copy];
}

// Returns the name of one of these properties searched in this order: name, title, headline, displayName, id.
+ (NSString *)topPropertyNameByConvention
{
  NSArray *conventionalNames = @[@"name", @"title", @"headline", @"displayname", @"id"];
  
  NSSet *propertyNames = [self allPropertyNames];
  NSString *topName = nil;
  for (NSString *name in conventionalNames)
  {
    if ([propertyNames containsObject:name])
    {
      topName = name;
      break;
    }
  }
  
  return topName;
}

// Returns the value of the +[self topPropertyNameByConvention] property, or -[self description].
- (id)topPropertyValueByConvention
{
  id propertyValue = nil;
  NSString *propertyName = [[self class] topPropertyNameByConvention];
  if (propertyName)
  {
    propertyValue = [self valueForKey:propertyName];
  }
  else
  {
    propertyValue = [self description];
  }
  return propertyValue;
}

// Returns the value of one of these properties name, title, headline, displayName, id, or description.
- (NSString *)descriptionOfTopProperty
{
  id value = [self topPropertyValueByConvention];
  NSString *description = [NSString stringWithFormat:@"%@", value];
  return description;
}

@end