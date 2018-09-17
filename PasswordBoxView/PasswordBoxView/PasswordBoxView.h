//
//  PasswordBoxView.h
//  PasswordBoxView
//
//  Created by LeeJin on 2018/9/14.
//  Copyright © 2018年 psylife. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PasswordBoxViewType){
    PasswordBoxViewTypeDefault,//数字风格
    PasswordBoxViewTypeSecret  //密码风格
};
@interface PasswordBoxView : UIView

//展示类型
@property (nonatomic, assign)PasswordBoxViewType type;
//输入完成回调
@property (nonatomic, copy) void(^EndEditBlock)(NSString *text);
//是否需要分割线
@property (nonatomic, assign) BOOL hasSpaceLine;
//是否有下标线
@property (nonatomic, assign) BOOL hasUnderLine;
//是否需要输入之后清空，再次输入使用,默认为NO
@property (nonatomic, assign) BOOL emptyEditEnd;
//是否添加下划线的动画,默认NO
@property (nonatomic, assign) BOOL underLineAnimation;

- (instancetype)initWithFrame:(CGRect)frame num:(NSInteger)num lineColor:(UIColor *)lColor textFont:(CGFloat)font;

@end
