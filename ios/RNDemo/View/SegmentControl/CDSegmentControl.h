//
//  CDSegmentControl.h
//  CodoonSport
//
//  Created by lian on 14-6-18.
//  Copyright (c) 2014年 codoon.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CDSegmentControlDidClick)(NSInteger index);

@interface CDSegmentControl : UIControl

@property (nonatomic, strong) NSArray *buttonsArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) UIViewController *containerViewController;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, copy) CDSegmentControlDidClick didClickCallback;

@property (readonly) UIView *bottomLineView;

+(instancetype)showSegmentControlWithFrame:(CGRect)frame
                          inViewController:(UIViewController *)viewController
                             containerView:(UIView *)containerView
                           viewControllers:(NSArray *)viewControllers
                             selectedIndex:(NSInteger)selectedIndex
                                  butttons:(NSArray *)buttons
                          didClickCallback:(void (^)(NSInteger index))didClickCallback;

-(void)reloadContents;

-(void)willScrollPreviousIndex:(NSInteger)previousIndex nextIndex:(NSInteger)nextIndex;
-(void)didEndScrollWithIndex:(NSInteger)index;
@end
