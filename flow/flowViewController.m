//
//  flowViewController.m
//  flow
//
//  Created by Joost on 7/15/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import "flowViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation flowViewController
@synthesize flow;
@synthesize current;
@synthesize passed;
@synthesize arrival;

- (void)dealloc
{
    [flow release];
    [current release];
    [passed release];
    [arrival release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

const static float kAnimationTime = 0.5f;
const static float kScale = 1.7;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    flow.dataSource = self;
    flow.willArriveAt = ^(int index){
        UIView * _t = [flow viewAtIndex: index];
        CABasicAnimation * scaleAnimation =[CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.duration=kAnimationTime;
        scaleAnimation.fromValue=[NSValue valueWithCATransform3D:CATransform3DIdentity];
        scaleAnimation.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeScale(kScale,kScale,1.0f)];
        [_t.layer setTransform:CATransform3DMakeScale(kScale,kScale,1.0f)];
        
        CABasicAnimation *theAnimation =[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=kAnimationTime;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.5];
        [_t.layer setOpacity: 1.0f];
        
        [_t.layer addAnimation:scaleAnimation forKey: @"scaleUp"];
        [_t.layer addAnimation:theAnimation forKey:@"lightOn"];
        arrival.text = [NSString stringWithFormat:@"arrival %d", index];
        
    };
    flow.passedItem = ^(int index)
    {
        
        UIView * _t = [flow viewAtIndex: index];
        [_t.layer removeAnimationForKey:@"scaleUp"];
        [_t.layer removeAnimationForKey:@"lightOn"];
        
        CABasicAnimation *theAnimation =[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=kAnimationTime;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.5];
        [_t.layer setOpacity: 0.5f];
        
        CABasicAnimation * scaleAnimation =[CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.duration=kAnimationTime;
        scaleAnimation.fromValue=[NSValue valueWithCATransform3D:CATransform3DMakeScale(kScale,kScale,1.0f)];
        scaleAnimation.toValue=[NSValue valueWithCATransform3D:CATransform3DIdentity];
        
        [_t.layer setTransform:CATransform3DIdentity];
        
        
        [_t.layer addAnimation:scaleAnimation forKey: @"scaleDown"];
        [_t.layer addAnimation: theAnimation forKey:@"lightOff"];
        passed.text = [NSString stringWithFormat:@"passed %d", index];
    };
    flow.selectionChanged =^(int seletion)
    {
       
        current.text = [NSString stringWithFormat:@"selection %d", seletion];
    };
    [flow reloadData];
}



- (void)viewDidUnload
{
    [self setFlow:nil];
    [self setCurrent:nil];
    [self setPassed:nil];
    [self setArrival:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
#pragma mark
#pragma mark
- (NSInteger)numberOfItems:(CustomFlowView*) flowView
{
    return 70;
}
- (CGSize) sizeOfItem:(CustomFlowView*) flowView
{
    return CGSizeMake(30, 50);
}
- (UIView *) viewForIndex:(NSInteger) index InView:(CustomFlowView*) flowView
{
    UILabel * _label = [[UILabel alloc] initWithFrame: CGRectZero];
    _label.text = [NSString stringWithFormat:@"%d",index];
    _label.font= [UIFont systemFontOfSize: 17];
    [_label autorelease];
    return _label;
}
@end
