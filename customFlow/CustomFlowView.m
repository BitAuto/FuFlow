//
//  CustomFlowView.m
//  carGallery
//
//  Created by Joost on 7/4/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import "CustomFlowView.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomFlowView(PrivateMethod) 
- (void) setUpInitialize;
- (UIView*)loadViewAtIndex:(NSInteger) index;
- (void)caculateVisibleItems;
- (void) updateVisibleItems;
- (void)endSelection;
- (void) recyleInRange:(NSRange) range;
@end


#pragma mark 
@implementation CustomFlowView
@synthesize selectionChanged;
@synthesize selectIndex;
@synthesize dataSource;
@synthesize numberOfItems = _numberOfItems;
@synthesize willArriveAt;
@synthesize passedItem;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        [self setUpInitialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpInitialize];
}
- (void)setUpInitialize
{  
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    scrollView.autoresizingMask =UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    scrollView.delegate = self;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview: scrollView];
    
    _itemSpace = 10;
    _visibleItems = NSMakeRange(NSNotFound, 0);
    _currentIndex = -1;
    selectIndex =0;
    _numberOfItems =1;
}

- (void)dealloc
{
    self.willArriveAt = nil;
    self.selectionChanged = nil;
    [items release];
    [scrollView release];
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect _t = self.frame;
    _t.origin = CGPointZero;
    if (!CGRectEqualToRect(_t, scrollView.frame)) 
    {
        scrollView.frame = _t;
    }
    CGSize _tSize = CGSizeMake((_numberOfItems -1)* (_itemsSize.width+ _itemSpace)+_t.size.width , _t.size.height);
    if (!CGSizeEqualToSize(_tSize,scrollView.contentSize)) 
    {
        scrollView.contentSize = _tSize;
    }
    
    
//    [self caculateVisibleItems];
}
- (void)caculateVisibleItems
{
    if (items.count ==0)
    {
        return;
    }
    CGRect _t = self.bounds;
    int _num =(int) floorf(_t.size.width/(_itemsSize.width + _itemSpace));
    _maxCountPerScreen = _num;
    float _tt = scrollView.contentOffset.x/(_itemsSize.width + _itemSpace);
    int _tCurrent =(int)floorf(_tt);
    _tCurrent = _tt- _tCurrent <=0.5f? _tCurrent : _tCurrent+1;
    _tCurrent = _tCurrent <0 ? 0:_tCurrent;
    _tCurrent = _tCurrent>= items.count ? items.count-1 : _tCurrent;
    if(_tCurrent != _currentIndex)
    {
        if (passedItem)
        {
            passedItem(_currentIndex);
        }
        _currentIndex = _tCurrent;
        [self loadViewAtIndex: _currentIndex];
        if (willArriveAt)
        {
            willArriveAt(_currentIndex);
        }
    }
   
    float _originPoint = self.bounds.size.width/2 - _itemsSize.width/2 ;
    float _itemRoom =_itemsSize.width+ _itemSpace;
    int _vbegin = (int)floorf(- (_originPoint- scrollView.contentOffset.x + _itemsSize.width)/_itemRoom);
    _vbegin = _vbegin<0? 0: _vbegin;
    
    int _vEnd =(int) floorf((scrollView.bounds.size.width+scrollView.contentOffset.x )/_itemRoom)+1;
    _vEnd = (_vEnd >= _numberOfItems ) ? _numberOfItems-1 : _vEnd;
//    DebugLog(@"%d %d", _vbegin,_vEnd);
    if (_visibleItems.location == _vbegin && _visibleItems.length ==0)
    {
        return;
    }
    NSRange _old = _visibleItems;
    _visibleItems.location = _vbegin;
    _visibleItems.length = _vEnd-_vbegin+1;
    int _tGuard =(_visibleItems.length+_visibleItems.location);
    
    for (int  i = _visibleItems.location;i< _tGuard ; ++i)
    {
        [self loadViewAtIndex: i];
    }
    
    ///
    NSRange _inter =  NSIntersectionRange(_old , _visibleItems);
    if (_inter.length >0)
    {
        if (NSEqualRanges(_inter, _old)) 
        {
            return;
        }else if(NSEqualRanges(_inter, _visibleItems))
        {
            NSRange _recycled1 ;
            NSRange _recycled2;
            _recycled1.location = _old.location;
            _recycled1.length = _inter.location- _old.location;
            
            _recycled2.location = _inter.location+_inter.length;
            _recycled2.length = _old.location+_old.length - _recycled2.location;
            [self recyleInRange: _recycled1];
            [self recyleInRange:_recycled2];
        }else 
        {
            NSRange _recycled;
            if(_inter.location  == _old.location)
            {
                _recycled.location = _old.location+_inter.length;
                _recycled.length = _old.length - _inter.length;
            }else if (_inter.location == _visibleItems.location)
            {
                _recycled.location = _old.location;
                _recycled.length = _old.length -_inter.length;
            }
            [self recyleInRange:_recycled];
        }
    }
    
}
- (UIView*)loadViewAtIndex:(NSInteger) index
{
//    if (index >= _numberOfItems || index<0)
//    {
//        return nil;
//    }
    UIView* _tView = [items objectAtIndex: index];
    CGRect _rct = [self rectForItemAtIndex: index];
    if ([_tView isKindOfClass:[NSNull class]])
    {
        _tView = [dataSource viewForIndex: index InView: self];
        @synchronized(items)
        {
            [items replaceObjectAtIndex: index withObject: _tView];
        }
        _tView.frame = _rct;
    }
    if (nil == _tView.superview)
    {
        [scrollView addSubview: _tView];
    }
   
    
      return _tView;
    
}
- (CGRect)rectForItemAtIndex:(NSInteger) index
{
    CGRect _t= CGRectZero;
    _t.size = _itemsSize;
    _t.origin = CGPointMake( self.bounds.size.width/2 - _itemsSize.width/2 +  index*(_itemsSize.width+ _itemSpace), (self.bounds.size.height-_itemsSize.height)/2.0f);
    return _t;
}
- (void)reloadData
{
    _itemsSize = [dataSource sizeOfItem:self];
    _numberOfItems = [dataSource numberOfItems: self];
    if ([dataSource respondsToSelector:@selector(spaceBetweenItems:)]) 
    {
        _itemSpace = [dataSource spaceBetweenItems: self];
    }
    if (nil == items)
    {
        items = [[NSMutableArray alloc] initWithCapacity: _numberOfItems];
    }
    [items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [items removeAllObjects];
    for (int i=0; i!= _numberOfItems; ++i)
    {
        [items addObject: [NSNull null]];
    }
    [self caculateVisibleItems];
    [self setNeedsDisplay];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self endSelection];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self endSelection];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self caculateVisibleItems];
}

#pragma mark
- (void)endSelection
{
    
    float _tt = scrollView.contentOffset.x/(_itemsSize.width + _itemSpace);
    int _tCurrent =(int)floorf(_tt);
    _tCurrent = _tt- _tCurrent <0.5f? _tCurrent : _tCurrent+1;
    [self setSelectIndex: _tCurrent];
   }
- (void)setSelectIndex:(NSInteger) index
{
    if (index <0 || index>= items.count)
    {
        return;
    }
    CGFloat _offsetX = index*(_itemsSize.width + _itemSpace);
    if (index != selectIndex || _offsetX != scrollView.contentOffset.x)
    {
        [scrollView setContentOffset: CGPointMake(_offsetX, scrollView.contentOffset.y) animated: YES];
        if(index != selectIndex)
        {
            selectIndex = index;
            if (selectionChanged)
            {
                selectionChanged(selectIndex);
            }
        }

    }
}
- (UIView *) viewAtIndex:(int) index
{
    if (index<0 || index>= items.count)
    {
        return nil;
    }
    UIView * _v =[self loadViewAtIndex: index];
    return _v;
}
- (void)recyleInRange:(NSRange)range
{
    if (range.location >= items.count) 
    {
        range.location = 0;
        range.length = 0;
    }
    for (int i = range.location ; (i!=range.location+range.length) && i<items.count; ++i) 
    {
        UIView *  _t =(UIView *) [items objectAtIndex: i] ;
        if([_t isKindOfClass:[UIView class]])
        {
            [_t removeFromSuperview];
        }else
        {
            continue;
        }
        
        @synchronized(items)
        {
            [items replaceObjectAtIndex: i withObject: [NSNull null]];
        }
    }
}
- (void)updateVisibleItems
{
    for (int  i = _visibleItems.location; i !=(_visibleItems.length+_visibleItems.location); ++i)
    {
        UIView * _tView = [self loadViewAtIndex: i];
        if (![_tView isKindOfClass:[UIView class]]) 
        {
            return;
        }
        CGRect _rct = [self rectForItemAtIndex: i];
        CGPoint _pos =CGPointMake(_rct.origin.x+_rct.size.width/2.0f, _rct.origin.y+_rct.size.height/2.0f);
        if (!CGPointEqualToPoint(_pos, _tView.center)  ) 
        {
            _tView.center = _pos;
            
        }

          }
}
#pragma mark
#pragma mark accessors
- (void)setFrame:(CGRect) rect
{
    if (!CGRectEqualToRect(self.frame, rect))
    {
        [super setFrame:rect];
        [self caculateVisibleItems];
        [self updateVisibleItems];
         self.selectIndex = selectIndex;
    }
}
@end
