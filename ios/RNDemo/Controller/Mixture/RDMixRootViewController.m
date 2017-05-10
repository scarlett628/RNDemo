//
//  RDMixRootViewController.m
//  RNDemo
//
//  Created by masijia on 2017/5/10.
//  Copyright © 2017年 codoon. All rights reserved.
//

#import "RDMixRootViewController.h"
#import "RDMixRNViewController.h"
#import "RDMixNativeViewController.h"
#import "CDSegmentControl.h"

#define kLightTextColor         COLOR_WITH_HEX(0x7c7c83, 1.0f)  //R:124 G:124  B:131
#define kCodoonGreenColor       COLOR_WITH_HEX(0x2aba66, 1.0f)  //R:42  G:186 B:102

@interface RDMixRootViewController ()<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIView *segmentBgView;
@property (nonatomic, strong) CDSegmentControl *segmentControl;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) RDMixRNViewController *rnViewController;
@property (nonatomic, strong) RDMixNativeViewController *nativeViewController;
@end

@implementation RDMixRootViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.rnViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([RDMixRNViewController class])];
    self.nativeViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([RDMixNativeViewController class])];
 
    UIButton *rnButton = [self segmentButtonWithTitle:@"React Native"];
    UIButton *nativeButton = [self segmentButtonWithTitle:@"Native"];
    
    CGFloat segmentWidth = [UIScreen mainScreen].bounds.size.width*0.7;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width-segmentWidth)/2;
    CGRect segmentControlFrame =
    CGRectMake(x,0,segmentWidth,44);
    __weak typeof(self) weakSelf = self;
    self.segmentControl =
    [CDSegmentControl showSegmentControlWithFrame:segmentControlFrame
                                 inViewController:self
                                    containerView:self.scrollView
                                  viewControllers:@[self.rnViewController,self.nativeViewController]
                                    selectedIndex:0
                                         butttons:@[rnButton,nativeButton]
                                 didClickCallback:^(NSInteger index) {
                                     [weakSelf segmentControlClickedIndex:index];
                                 }];
    [self.segmentControl reloadContents];
    [self.segmentBgView addSubview:self.segmentControl];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.contentSize = CGSizeMake(screenWidth*2, self.view.frame.size.height);
    self.rnViewController.view.frame = CGRectMake(0, 0,screenWidth,_scrollView.frame.size.height);
    self.nativeViewController.view.frame = CGRectMake(screenWidth,0,screenWidth, _scrollView.frame.size.height);
}

- (void)segmentControlClickedIndex:(NSInteger)index{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [_scrollView setContentOffset:CGPointMake(index*width, 0) animated:YES];
    switch (index) {
            case 0:{
                break;
            }
            case 1:{
                break;
            }
        default:
            break;
    }
}

- (UIButton *)segmentButtonWithTitle:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    button.backgroundColor = [UIColor clearColor];
    button.titleEdgeInsets =  UIEdgeInsetsMake(button.titleEdgeInsets.top + 4, button.titleEdgeInsets.right, button.titleEdgeInsets.bottom, button.titleEdgeInsets.left);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    return button;
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    NSInteger previousIndex = (NSInteger)(scrollView.contentOffset.x + 1)/width;
    NSInteger nextIndex = (NSInteger)(width + scrollView.contentOffset.x - 1)/width;
    [self.segmentControl willScrollPreviousIndex:previousIndex nextIndex:nextIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self didEndScrolling];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self didEndScrolling];
}

- (void)didEndScrolling {
    CGRect bounds = _scrollView.bounds;
    NSInteger index = (int)(floorf(CGRectGetMidX(bounds)/CGRectGetWidth(bounds)));
    [self.segmentControl didEndScrollWithIndex:index];
}


@end
