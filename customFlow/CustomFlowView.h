//
//  CustomFlowView.h
//  carGallery
//
//  Created by Joost on 7/4/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomFlowView;
@protocol CustomFlowDataSource <NSObject>

- (NSInteger)numberOfItems:(CustomFlowView*) flowView;
- (CGSize) sizeOfItem:(CustomFlowView*) flowView;
- (UIView *) viewForIndex:(NSInteger) index InView:(CustomFlowView*) flowView;
@optional
- (CGFloat) spaceBetweenItems:(CustomFlowView*) flowView;

@end
#pragma mark
@interface CustomFlowView : UIView<UIScrollViewDelegate>
{
    UIScrollView * scrollView;
    NSMutableArray * items;
    NSRange  _visibleItems;
    void (^selectionChanged)(int buttonIndex);
    NSInteger selectIndex;
    NSInteger _currentIndex;
    NSInteger _numberOfItems;
    NSInteger _maxCountPerScreen;
    CGSize _itemsSize;
    CGFloat _itemSpace;
    id<CustomFlowDataSource> dataSource;
    void (^willArriveAt)(int index);
    void (^passedItem)(int index);
    
}
@property (nonatomic,copy) void (^selectionChanged)(int buttonIndex);
@property (nonatomic,assign) NSInteger selectIndex;
@property (nonatomic,assign)IBOutlet  id<CustomFlowDataSource> dataSource;
@property (nonatomic,readonly) NSInteger numberOfItems;
@property (nonatomic,copy) void (^willArriveAt)(int index);
@property (nonatomic,copy)  void (^passedItem)(int index);

- (UIView *) viewAtIndex:(int) index;
- (void) reloadData;
- (CGRect)rectForItemAtIndex:(NSInteger) index;
@end
