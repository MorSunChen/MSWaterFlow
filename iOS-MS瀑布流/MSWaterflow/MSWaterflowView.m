//
//  MSWaterflowView.m
//  iOS-MS瀑布流
//
//  Created by 陈朝阳 on 15/9/29.
//  Copyright (c) 2015年 czy. All rights reserved.
//

#import "MSWaterflowView.h"
#import "MSWaterflowViewCell.h"
#define MSWaterflowViewDefaultColumns 3
#define MSWaterflowViewDefaultMargin 10
#define MSWaterflowViewDefaultCellH 70
@interface MSWaterflowView()
/**
 *  记录所有cell的frame
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;
/**
 *  记录界面上展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存池(保存不在屏幕上展示的的cell)
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;
@end
@implementation MSWaterflowView
#pragma mark - 初始化方法
- (NSMutableArray *)cellFrames
{
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}
- (NSMutableDictionary *)displayingCells
{
    if (!_displayingCells) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}
- (NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}
#pragma mark - 私有方法
/**
 *  返回总列数
 */
- (NSUInteger)numberOfColumns
{
    NSUInteger numberOfColumns = 0;
    if ([self.dataSource respondsToSelector:@selector(numberofColumnsInWaterflowView:)]) {
        numberOfColumns = [self.dataSource numberofColumnsInWaterflowView:self];
    }else{
        numberOfColumns = MSWaterflowViewDefaultColumns;
    }
    return numberOfColumns;
}
/**
 *  根据间距类型返回间距
 */
- (CGFloat)marginForType:(MSWaterflowViewMarginType)type
{
    CGFloat marginForType = 0;
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        marginForType = [self.delegate waterflowView:self marginForType:type];
    }else{
        marginForType = MSWaterflowViewDefaultMargin;
    }
    return marginForType;
}
/**
 * 返回index位置的cell的高
 */
- (CGFloat)waterflowCellHeightAtIndex:(NSUInteger)index
{
    CGFloat heightAtIndex = 0;
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightForCellAtIndex:)]) {
        heightAtIndex = [self.delegate waterflowView:self heightForCellAtIndex:index];
    }else{
        heightAtIndex = MSWaterflowViewDefaultCellH;
    }
    return heightAtIndex;
}
/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    //索要对应位置的cell
    //cell的总数
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i<numberOfCells; i++) {
        //取出i位置的cell的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        //索取cell,首先从显示在屏幕上的字典中取
        MSWaterflowViewCell *cell = self.displayingCells[@(i)];
        //判断cell是否在屏幕上(是否可见)
        if([self isInScreen:cellFrame]){
            if (!cell) {
                //cell为空时向数据源请求cell
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                //添加到显示的字典中
                self.displayingCells[@(i)] = cell;
            }
        }else
        {
            if (cell) {
                //不在屏幕上显示，移除cell
                [cell removeFromSuperview];
                //从显示的字典中移除
                [self.displayingCells removeObjectForKey:@(i)];
                //添加到缓存中
                [self.reusableCells addObject:cell];
            }
        }
    }
}
/**
 *  根据frame判断cell是否在屏幕上显示
 */
- (BOOL)isInScreen:(CGRect)cellFrame
{
    return ((CGRectGetMaxY(cellFrame) > self.contentOffset.y) && (CGRectGetMinY(cellFrame) < (self.contentOffset.y + self.bounds.size.height)));
}
/**
 * 在控件创建完添加到父控件后调用
 */
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}
#pragma mark - 公共接口
/**
 * 返回cell的宽度
 */
- (CGFloat)waterflowCellWidth
{
    NSUInteger numberOfColumns = [self numberOfColumns];
    CGFloat leftM   = [self marginForType:MSWaterflowViewMarginTypeLeft];
    CGFloat rightM  = [self marginForType:MSWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:MSWaterflowViewMarginTypeColumn];
    CGFloat cellW = (self.bounds.size.width - leftM - rightM - (numberOfColumns - 1)*columnM)/numberOfColumns;
    return cellW;
}
/**
 *  刷新数据
 *  计算每一个cell的frame
 */
- (void)reloadData
{
    //移除所有数据
    //清空显示在屏幕上的cell
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    //cell的总数
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    //总列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    //间距
    CGFloat topM    = [self marginForType:MSWaterflowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:MSWaterflowViewMarginTypeBottom];
    CGFloat leftM   = [self marginForType:MSWaterflowViewMarginTypeLeft];
    CGFloat columnM = [self marginForType:MSWaterflowViewMarginTypeColumn];
    CGFloat rowM    = [self marginForType:MSWaterflowViewMarginTypeRow];
    //cell的宽度
    CGFloat cellW = [self waterflowCellWidth];
    //创建一个c语言数组记录每一列最大的Y
    CGFloat maxYOfColumns[numberOfColumns];
    //初始化数组
    for (int i = 0; i<numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    //计算每一个cell的frame
    for (int i = 0;i < numberOfCells; i++) {
        //计算cell所在的列(最短的列)
        int cellColumn = 0;
        //取出上一行最短列的最大Y值，即为这个cell所在的列
        CGFloat maxYOfCellColumn = maxYOfColumns[0];
        for (int j = 1; j<numberOfColumns; j++) {
            if (maxYOfCellColumn > maxYOfColumns[j]) {
                maxYOfCellColumn = maxYOfColumns[j];
                cellColumn = j;
            }
        }
        //当前位置cell的高度
        CGFloat cellH = [self waterflowCellHeightAtIndex:i];
        CGFloat cellX = cellColumn*(cellW + columnM) + leftM;
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {
            //top行
            cellY = topM;
        }else {
            cellY = maxYOfCellColumn+rowM;
        }
        //存入数组
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        //存储当前列的最大Y
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    }
    //设置scroll的contentSize
    CGFloat contentH = maxYOfColumns[0];
    for (int i = 0; i<numberOfColumns; i++) {
        if (contentH < maxYOfColumns[i]) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH +=bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}
/**
 *  从缓存池中查找identifier的重用cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block MSWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(MSWaterflowViewCell *waterViewCell, BOOL *stop) {
        if ([waterViewCell.identifier isEqualToString:identifier]) {
            reusableCell = waterViewCell;
            *stop = YES;
        }
    }];
    //找到后一定要从缓存池中移除，否则不断滚动的时候缓存池将会出现内存爆炸
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}
#pragma mark - 触摸点击事件处理
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectCellAtIndex:)])return;
    //获取触摸点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //判断触摸点是否在某一个cell上
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, MSWaterflowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectCellAtIndex:[selectIndex unsignedIntegerValue]];
    }
}
@end
