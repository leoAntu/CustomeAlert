//
//  HCAlertView.h
//
//  Created by hc on 16/6/7.
//  Copyright © 2016年 hc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^HCAlertViewButtonAction)(NSInteger selectedIndex);
/**
 *  弹出一个自定义的框
 */
@interface HCAlertView : UIView
@property (nullable, strong, nonatomic) UIView *customView;//自定义的弹出视图
@property (nullable, copy, nonatomic) HCAlertViewButtonAction buttonAction;//点击按钮回调事件
/**
 *  自定义样式的alertView
 *
 *  @param image             图片，显示在最上面的图片
 *  @param title             标题
 *  @param titleIcon         标题的图标，跟文字一样高
 *  @param message           信息
 *  @param cancelButtonTitle 取消按钮
 *  @param otherButtonTitles 其他按钮
 *
 *  @return 自定义样式alertView的实例
 */
- (instancetype)initWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                    titleIcon:(nullable UIImage *)titleIcon
                      message:(nullable NSString *)message
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitles,...NS_REQUIRES_NIL_TERMINATION;

/**
 *  初始化方法
 *
 *  @param customView 自定义的弹出视图
 *
 *  @return custom alert实例
 */
- (instancetype)initWithCustomView:(nullable UIView *)customView;

- (void)show;

- (void)hide;

@end

@interface HCAlertButtonItem : UICollectionViewCell

@property (strong, nonatomic) UIButton *buttonItem;

@end

@interface HCTextAttachment : NSTextAttachment

@end

NS_ASSUME_NONNULL_END
