//
//  flowViewController.h
//  flow
//
//  Created by Joost on 7/15/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFlowView.h"
@interface flowViewController : UIViewController <CustomFlowDataSource>
{
    CustomFlowView *flow;
    UILabel *current;
    UILabel *passed;
    UILabel *arrival;
}
@property (nonatomic, retain) IBOutlet CustomFlowView *flow;
@property (nonatomic, retain) IBOutlet UILabel *current;
@property (nonatomic, retain) IBOutlet UILabel *passed;
@property (nonatomic, retain) IBOutlet UILabel *arrival;

@end
