//
//  LKResourceProvider.m
//
//  This base provider was created on 2013-10-10 by LaneKit v0.2.1.
//
// The following LaneKit command was used to generate this file:
// lanekit generate provider one model_1 cnn.com
//

#import "LKResourceProvider.h"
#import "LKModel.h"

@implementation LKResourceProvider

- (void)downloadWithCompletionBlock:(LKResourceProviderCallbackBlock)completionBlock
{
  NSString *baseURL = self.baseURL;
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
  RKResponseDescriptor *responseDescriptor = [self responseDescriptor];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
  
  [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    NSError *error = nil;
    id result = [self processResult:mappingResult withError:&error];
    completionBlock(nil, result);
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    completionBlock(error, nil);
  }];
  [operation start];
}

// Subclasses should override this method
- (Class)modelClass
{
  return [LKModel class];
}

// Subclasses should override this method
- (id)processResult:(RKMappingResult *)mappingResult withError:(NSError **)error
{
  return nil;
}

// Subclasses may need to override this method
- (RKResponseDescriptor *)responseDescriptor
{
  NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
  return [RKResponseDescriptor responseDescriptorWithMapping:[self.modelClass responseMapping]
                                                      method:RKRequestMethodGET
                                                 pathPattern:[self.modelClass pathPattern]
                                                     keyPath:[self.modelClass keyPath]
                                                 statusCodes:statusCodes];
}

@end
