//
//  LKDetailViewController.h
//

#import <UIKit/UIKit.h>

@interface LKDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
