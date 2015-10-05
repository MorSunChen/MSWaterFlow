//
//  ViewController.m
//  iOS-MS瀑布流
//
//  Created by 陈朝阳 on 15/9/29.
//  Copyright (c) 2015年 czy. All rights reserved.
//

#import "ViewController.h"
#import "MSWaterflowView.h"
#import "MSWaterflowViewCell.h"
@interface ViewController ()<MSWaterflowViewDataSource,MSWaterflowViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置waterflowView
    [self setupWaterflowView];
}
/**
 * 创建并添加waterflowView
 */
- (void)setupWaterflowView
{
    MSWaterflowView *waterflowView = [[MSWaterflowView alloc]init];
    waterflowView.frame = self.view.bounds;
    waterflowView.delegate = self;
    waterflowView.dataSource = self;
    [self.view addSubview:waterflowView];
}
- (NSUInteger)numberOfCellsInWaterflowView:(MSWaterflowView *)waterflowView
{
    return 50;
}
- (MSWaterflowViewCell *)waterflowView:(MSWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
    static NSString *ID = @"waterflowCell";
    MSWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[MSWaterflowViewCell alloc]initWithReusableIdentifier:ID];
        cell.backgroundColor = MSRandomColor;
        UILabel *lable = [[UILabel alloc]init];
        lable.tag  = 100;
        lable.frame = CGRectMake(0, 0, 50, 20);
        [cell addSubview:lable];
    }
    UILabel *lable = (UILabel *)[cell viewWithTag:100];
    lable.text = [NSString stringWithFormat:@"%zi",index];
    //NSLog(@"%zi %p",index , cell);
    return cell;
}
- (NSUInteger)numberofColumnsInWaterflowView:(MSWaterflowView *)waterflowView
{
    return 3;
}
- (CGFloat)waterflowView:(MSWaterflowView *)waterflowView heightForCellAtIndex:(NSUInteger)index
{
    switch (index%3) {
        case 0:return 80;
        case 1:return 90;
        case 2:return 100;
        default:return 110;
    }
}
- (CGFloat)waterflowView:(MSWaterflowView *)waterflowView marginForType:(MSWaterflowViewMarginType)type
{
    switch (type) {
        case MSWaterflowViewMarginTypeTop:return 30;
        case MSWaterflowViewMarginTypeBottom:return 50;
        case MSWaterflowViewMarginTypeLeft:
        case MSWaterflowViewMarginTypeRight:return 10;
        case MSWaterflowViewMarginTypeColumn:return 20;
        case MSWaterflowViewMarginTypeRow:return 5;
    }
}
- (void)waterflowView:(MSWaterflowView *)waterflowView didSelectCellAtIndex:(NSUInteger)index
{
    NSLog(@"点击了第%zi个cell",index);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.contentOffset.y);
}
@end
