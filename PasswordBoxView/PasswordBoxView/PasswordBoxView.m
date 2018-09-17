//
//  PasswordBoxView.m
//  PasswordBoxView
//
//  Created by LeeJin on 2018/9/14.
//  Copyright © 2018年 psylife. All rights reserved.
//

#import "PasswordBoxView.h"
#import "NSString+Size.h"

//下标线距离左右的边距
#define Space 5
//下标线宽度
#define LineWidth (self.frame.size.width - lineNum * 2 * Space)/lineNum
//下标线高度
#define LineHeight 2
//下标线距离底部高度
#define LineBottomHeight 5
//密码风格 圆点半径
#define RADIUS 5

@interface PasswordBoxView ()<UITextFieldDelegate>
{
    //文字数姐
    NSMutableArray *textArray;
    //分割线条数
    NSInteger lineNum;
    //分割线颜色
    UIColor *lineColor;
    //字体颜色
    UIColor *textColor;
    //字体大小
    UIFont *textFont;
    //观察者
    NSObject *observer;
}

@property (nonatomic, strong) UITextField *textField;
//下标线存放数组
@property (nonatomic, strong)  NSMutableArray *underlineArray;

@end

@implementation PasswordBoxView

#pragma  mark - init
- (instancetype)initWithFrame:(CGRect)frame num:(NSInteger)num lineColor:(UIColor *)lColor textFont:(CGFloat)font {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = lColor.CGColor;
        textArray = [NSMutableArray arrayWithCapacity:num];
        lineNum = num;
        //文字和分割线的颜色相同
        lineColor = textColor = lColor;
        textFont = [UIFont boldSystemFontOfSize:font];
        //添加分割线
        [self addSpaceLine];
        _underLineAnimation = NO;
        _emptyEditEnd = NO;
        //字体行高要小于self视图的高
        NSAssert(textFont.lineHeight < self.frame.size.height, @"字体行高要小于self视图的高");
        //单击手势
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginEdit)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - private method
- (void)addSpaceLine {
    for (NSInteger i = 0; i < lineNum - 1; i ++) {
        CAShapeLayer *line = [CAShapeLayer layer];
        line.fillColor = lineColor.CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(self.frame.size.width/lineNum * (i + 1), 1, 0.5f, self.frame.size.height - 1)];
        line.path = path.CGPath;
        line.hidden = NO;
        [self.layer addSublayer:line];
    }
}

- (void)addUnderLine {
    [self.underlineArray removeAllObjects];
    for (NSInteger i = 0; i < lineNum; i ++) {
        CAShapeLayer *underLine = [CAShapeLayer layer];
        underLine.fillColor = lineColor.CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(Space * (2 * i + 1) + i * LineWidth, self.frame.size.height - LineBottomHeight, LineWidth, LineHeight)];
        underLine.path = path.CGPath;
        //有文字时隐藏下标线
        underLine.hidden = textArray.count > i;
        [self.layer addSublayer:underLine];
        [self.underlineArray addObject:underLine];
    }
    //添加下标线动画
    [self addUnderLineAnimation];
}

- (void)addUnderLineAnimation {
    if (_underLineAnimation) {
        if (textArray.count >= lineNum) {
            return;
        }
        for (NSInteger i = 0; i < _underlineArray.count; i ++) {
            CAShapeLayer *line = _underlineArray[i];
            if (i  == textArray.count) {
                [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
            }else {
                [line removeAnimationForKey:@"kOpacityAnimation"];
            }
        }
    }
}

- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.8;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}

- (void)underLineHidden {
    if (_hasUnderLine) {
        for (NSInteger i = 0; i < lineNum; i ++) {
            CAShapeLayer *obj = _underlineArray[i];
            obj.hidden = i < textArray.count;
        }
    }
}

- (void)endEdit {
    [[NSNotificationCenter defaultCenter]removeObserver:observer];
    [self.textField resignFirstResponder];
}

#pragma mark - gesture method
- (void)beginEdit {
    if (_textField == nil) {
        [self addSubview:self.textField];
    }
    [self addNotification];
    [self.textField becomeFirstResponder];
}

#pragma mark - Notification
- (void)addNotification {
    if (observer) {
        [[NSNotificationCenter defaultCenter]removeObserver:observer];
    }
    observer = [[NSNotificationCenter defaultCenter]addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        UITextField *textField = note.object;
        NSInteger length = textField.text.length;
        if (length > textArray.count) {
            [textArray addObject:[textField.text substringWithRange:NSMakeRange(textArray.count, 1)]];
        }else {
            [textArray removeLastObject];
        }
        //标记为需要重绘,调用drawRect
        [self setNeedsDisplay];
        [self underLineHidden];
        [self addUnderLineAnimation];
        
        if (length == lineNum && self.EndEditBlock) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.EndEditBlock(textField.text);
                [self emptyAndDisplay];
            });
        }
        if (length > lineNum) {
            textField.text = [textField.text substringToIndex:lineNum];
            [self emptyAndDisplay];
        }
    }];
}

- (void)emptyAndDisplay {
    [self endEdit];
    if (_emptyEditEnd) {
        _textField.text = @"";
        [textArray removeAllObjects];
        [self setNeedsDisplay];
        [self underLineHidden];
    }
    [self addUnderLineAnimation];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self endEdit];
}

#pragma mark - override method
- (void)drawRect:(CGRect)rect {
    switch (_type) {
        case PasswordBoxViewTypeDefault:
        {
            //画字
            CGContextRef context = UIGraphicsGetCurrentContext();
            for (NSInteger i = 0; i < textArray.count; i ++) {
                NSString *num = textArray[i];
                CGFloat wordWidth = [num stringSizeWithFont:textFont Size:CGSizeMake(MAXFLOAT, textFont.lineHeight)].width;
                CGFloat startX = self.frame.size.width/lineNum * i + (self.frame.size.width/lineNum - wordWidth)/2;
                [num drawInRect:CGRectMake(startX, (self.frame.size.height - textFont.lineHeight - LineBottomHeight - LineHeight)/2, wordWidth, textFont.lineHeight + 5) withAttributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor}];
            }
            CGContextDrawPath(context, kCGPathFill);
        }
            break;
        case PasswordBoxViewTypeSecret:
        {
            //画圆
            CGContextRef context = UIGraphicsGetCurrentContext();
            for (NSInteger i = 0; i < textArray.count; i ++) {
                //圆点
                CGFloat pointX = self.frame.size.width/lineNum/2 * (2 * i + 1);
                CGFloat pointY = self.frame.size.height/2;
                CGContextAddArc(context, pointX, pointY, RADIUS, 0, 2*M_PI, 0);//添加一个圆
                CGContextDrawPath(context, kCGPathFill);//绘制填充
            }
            CGContextDrawPath(context, kCGPathFill);
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter and setter

- (void)setUnderLineAnimation:(BOOL)underLineAnimation {
    _underLineAnimation = underLineAnimation;
    if (underLineAnimation && !_hasUnderLine) {
        self.hasUnderLine = YES;
    }
}

- (void)setHasUnderLine:(BOOL)hasUnderLine {
    _hasUnderLine = hasUnderLine;
    if (hasUnderLine) {
        //添加下标线
        [self addUnderLine];
    }
}

- (void)setHasSpaceLine:(BOOL)hasSpaceLine {
    _hasSpaceLine = hasSpaceLine;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.hidden = YES;
        _textField.delegate = self;
    }
    return _textField;
}

- (NSMutableArray *)underlineArray {
    if (!_underlineArray) {
        _underlineArray = [NSMutableArray array];
    }
    return _underlineArray;
}

@end
