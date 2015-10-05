//
//  MSWaterflowViewCell.h
//  iOS-MS瀑布流
//
//  Created by 陈朝阳 on 15/9/29.
//  Copyright (c) 2015年 czy. All rights reserved.
//  瀑布流cell

#import <UIKit/UIKit.h>

@interface MSWaterflowViewCell : UIView
/**
 * 可重用identifier
 */
@property (nonatomic, copy) NSString *identifier;
- (instancetype)initWithReusableIdentifier:(NSString *)identifier;
@end
