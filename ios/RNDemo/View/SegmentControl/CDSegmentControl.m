//
//  CDSegmentControl.m
//  CodoonSport
//
//  Created by lian on 14-6-18.
//  Copyright (c) 2014年 codoon.com. All rights reserved.
//

#import "CDSegmentControl.h"
#import "NSString+Size.h"

@interface CDSegmentControl()
@property (nonatomic, strong) UIView *bottomLineView;

@property (readwrite, nonatomic, assign) NSInteger previousIndex;
@property (readwrite, nonatomic, assign) NSInteger nextIndex;

@property(nonatomic, copy) NSString *lastSelectedPageAddress;
@end

@implementation CDSegmentControl
+(instancetype)showSegmentControlWithFrame:(CGRect)frame
                          inViewController:(UIViewController *)viewController
                           viewControllers:(NSArray *)viewControllers{
    CDSegmentControl *segmentControl = [[CDSegmentControl alloc] initWithFrame:frame];
    segmentControl.containerViewController = viewController;
    [segmentControl setViewControllers:viewControllers];
    return segmentControl;
}

+(instancetype)showSegmentControlWithFrame:(CGRect)frame
                          inViewController:(UIViewController *)viewController
                             containerView:(UIView *)containerView
                           viewControllers:(NSArray *)viewControllers
                             selectedIndex:(NSInteger)selectedIndex
                                  butttons:(NSArray *)buttons
                          didClickCallback:(void (^)(NSInteger index))didClickCallback{
    CDSegmentControl *segmentControl = [[CDSegmentControl alloc] initWithFrame:frame];
    segmentControl.containerViewController = viewController;
    segmentControl.containerView = containerView;
    [segmentControl setViewControllers:viewControllers];
    segmentControl.selectedIndex = selectedIndex;
    segmentControl.buttonsArray = buttons;
    segmentControl.didClickCallback = didClickCallback;
    [segmentControl setBackgroundColor:[UIColor whiteColor]];
    return segmentControl;
}

#pragma mark layout
- (void)layoutSubviews{
    NSUInteger buttonsCount = self.buttonsArray.count;
    
    CGFloat buttonWidth = self.frame.size.width / buttonsCount;
    for (int i = 0; i < buttonsCount; i++) {
        CGFloat buttonHeight = self.frame.size.height;
        CGFloat buttonOriginX = buttonWidth * i;
        
        UIButton *button = self.buttonsArray[i];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        button.frame = CGRectMake(buttonOriginX, 0, buttonWidth, buttonHeight);
    }
    [self transformBottomLine];
}

#pragma mark - Reload Contents
- (void)cleanContents{
    [_viewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)reloadContents{
    [self cleanContents];
    [self updateButtons];
    [self willAppearViewControllerAtIndex:self.selectedIndex];
    self.didClickCallback?self.didClickCallback(self.selectedIndex):nil;
}

- (void)updateButtons{
    [self.buttonsArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.selected = NO;
    }];
    
    if([self.buttonsArray count] <= self.selectedIndex){return;}
    UIButton *selectedButton = self.buttonsArray[self.selectedIndex];
    [selectedButton setSelected:YES];
    [self transformBottomLine];
}

#pragma mark Setter
-(void)setButtonsArray:(NSArray *)buttonsArray{
    [_buttonsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _buttonsArray = buttonsArray;
    
    [_buttonsArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [self addSubview:button];
        [button addTarget:self action:@selector(segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [self updateButtons];
}

#pragma mark IBAction
- (void)segmentButtonClicked: (id)sender{
    UIButton *clickedButton = (UIButton *)sender;
    self.selectedIndex = [self.buttonsArray indexOfObject:clickedButton];
    [self updateButtons];
    self.didClickCallback?self.didClickCallback(self.selectedIndex):nil;
}

-(void)transformBottomLine{
    if([self.buttonsArray count] <= self.selectedIndex){return;}
    UIButton *selectedButton_ = [self.buttonsArray objectAtIndex:self.selectedIndex];
    
    CGFloat titleWidth_ = [selectedButton_.titleLabel.text
                           sizeOfFont:selectedButton_.titleLabel.font].width;
    CGFloat lineWidth_ = MIN(titleWidth_+5, selectedButton_.frame.size.width);
    CGFloat origin_x_ = selectedButton_.frame.origin.x+(selectedButton_.frame.size.width-lineWidth_)/2;
    
    if(!self.bottomLineView){
        self.bottomLineView = [[UIView alloc] initWithFrame:
                               CGRectMake(origin_x_,
                                          self.frame.size.height-2,
                                          lineWidth_,
                                          2)];
        [self.bottomLineView setBackgroundColor:[UIColor redColor]];
        [self addSubview:self.bottomLineView];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomLineView.frame = CGRectMake(origin_x_,
                                                   self.bottomLineView.frame.origin.y,
                                                   lineWidth_,
                                                   self.bottomLineView.frame.size.height);
            
        }];
    }
}

#pragma mark - Container Scroll View Did Scroll
-(void)willScrollPreviousIndex:(NSInteger)previousIndex nextIndex:(NSInteger)nextIndex{
    if(self.previousIndex != previousIndex) {
        if(previousIndex < self.previousIndex) {
            [self willAppearViewControllerAtIndex:previousIndex];
        } else {
            [self willDisappearViewControllerAtIndex:self.previousIndex];
        }
        
        self.previousIndex = previousIndex;
    }
    
    if(self.nextIndex != nextIndex) {
        if(nextIndex > self.nextIndex) {
            [self willAppearViewControllerAtIndex:nextIndex];
        }else{
            [self willDisappearViewControllerAtIndex:self.nextIndex];
        }
        self.nextIndex = nextIndex;
    }
}

-(void)didEndScrollWithIndex:(NSInteger)index{
    if(self.selectedIndex != index) {
        self.selectedIndex = index;
        [self updateButtons];
        self.didClickCallback?self.didClickCallback(index):nil;
    }
}

#pragma mark - View appear & disappear
- (UIViewController *)willAppearViewControllerAtIndex:(NSInteger)index{
    if([self.viewControllers count] <= index){return nil;}
    
    UIViewController *viewController = [_viewControllers objectAtIndex:index];

    if(![self.containerView.subviews containsObject:viewController.view]){
        [self.containerView addSubview:viewController.view];
    }
    
    if(![self.containerViewController.childViewControllers containsObject:viewController]){
        [viewController beginAppearanceTransition:YES animated:NO];
        [self.containerViewController addChildViewController:viewController];
        [viewController didMoveToParentViewController:self.containerViewController];
        [viewController endAppearanceTransition];
        
        self.lastSelectedPageAddress = [NSString stringWithFormat:@"%p",viewController];
    }
    return viewController;
}

- (UIViewController *)willDisappearViewControllerAtIndex:(NSInteger)index{
    if([self.viewControllers count] <= index){return nil;}
    
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    if([self.containerView.subviews containsObject:viewController.view]){
        [viewController.view removeFromSuperview];
    }
    if([self.containerViewController.childViewControllers containsObject:viewController]){
        [viewController beginAppearanceTransition:NO animated:NO];
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
        [viewController endAppearanceTransition];
    }
    return viewController;
}

@end
