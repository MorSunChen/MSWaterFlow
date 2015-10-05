//
//  MSWaterflowView.h
//  iOS-MS瀑布流
//
//  Created by 陈朝阳 on 15/9/29.
//  Copyright (c) 2015年 czy. All rights reserved.
//

#import <UIKit/UIKit.h>
/**cell间距的类型*/
typedef NS_ENUM(NSUInteger, MSWaterflowViewMarginType) {
    MSWaterflowViewMarginTypeTop,
    MSWaterflowViewMarginTypeBottom,
    MSWaterflowViewMarginTypeLeft,
    MSWaterflowViewMarginTypeRight,
    MSWaterflowViewMarginTypeColumn,
    MSWaterflowViewMarginTypeRow
};
@class MSWaterflowViewCell,MSWaterflowView;
/**
 *  数据源方法
 */
@protocol MSWaterflowViewDataSource <NSObject>
@required
/**
 *  一共有多少个数据
 */
- (NSUInteger)numberOfCellsInWaterflowView:(MSWaterflowView *)waterflowView;
/**
 *  返回index位置的cell
 */
- (MSWaterflowViewCell *)waterflowView:(MSWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;
@optional
/**
 *  返回总列数
 */
- (NSUInteger)numberofColumnsInWaterflowView:(MSWaterflowView *)waterflowView;
@end
/**
 *  代理方法
 */
@protocol MSWaterflowViewDelegate <NSObject,UIScrollViewDelegate>
@optional
/**
 *  点击了index位置的cell
 */
- (void)waterflowView:(MSWaterflowView *)waterflowView didSelectCellAtIndex:(NSUInteger)index;
/**
 *  点返回index位置的cell的高度
 */
- (CGFloat)waterflowView:(MSWaterflowView *)waterflowView heightForCellAtIndex:(NSUInteger)index;
/**
 *  返回不同类型的间距
 */
- (CGFloat)waterflowView:(MSWaterflowView *)waterflowView marginForType:(MSWaterflowViewMarginType)type;
@end
/**
 *  瀑布流控件
 */
@interface MSWaterflowView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic, weak) id<MSWaterflowViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic, weak) id<MSWaterflowViewDelegate> delegate;
/**
 *  刷新数据(执行这个数据，会向数据源和代理请求数据)
 */
- (void)reloadData;
/**
 *  返回cell的宽度
 */
- (CGFloat)waterflowCellWidth;
/**
 *  根据identifier去缓存池查找可重利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
