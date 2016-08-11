//
//  ViewController.m
//  MSPayAnimation
//
//  Created by mr.scorpion on 16/8/11.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//  支付宝支付动画

#import "ViewController.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *alipayLayer; // 圆弧
@property (nonatomic, strong) CAShapeLayer *tickLayer;   // 勾
@end

@implementation ViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.开启动画
    [self startAnimation];
    
    // 2.添加单指双击复现动画
    UITapGestureRecognizer *singleFingleTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replayAnimation)];
    singleFingleTwo.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:singleFingleTwo];
}

#pragma mark - Actions
#pragma mark - 开启动画
- (void)startAnimation
{
    // 一、画圆
    // 1.先画一个圆圈的路径
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(150, 150)
                                                              radius:50.f
                                                          startAngle:M_PI * 3 / 2
                                                            endAngle:M_PI * 7 / 2
                                                           clockwise:YES];
    // 2.利用CAShapeLayer来按照指定的path绘制图形
    _alipayLayer = [CAShapeLayer layer];
    _alipayLayer.path = circlePath.CGPath;
    _alipayLayer.lineWidth = 3.f;
    _alipayLayer.fillColor = [UIColor clearColor].CGColor; // 填充色
    _alipayLayer.strokeColor =  RGBA(5, 154, 227, 1).CGColor; // [UIColor purpleColor].CGColor;
    
    // 3.添加到view的layer上
    [self.view.layer addSublayer:_alipayLayer];
    
    
    // 二、让圆形动画起来
    // 1.顺时针慢慢显示圆弧
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.fromValue = @0;
    drawAnimation.toValue = @1;
    drawAnimation.duration = 2.f;
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.removedOnCompletion = YES;
    //    [_alipayLayer addAnimation:drawAnimation forKey:@"DrawCircleAnimationKey"]; // 测试：看看这一小步的动画效果
    
    // 2.顺时针慢慢擦除圆弧
    CABasicAnimation *dismissAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    dismissAnimation.fromValue = @0;
    dismissAnimation.toValue = @1;
    dismissAnimation.duration = 2.f;
    dismissAnimation.beginTime = 2.f;   //两个动画加入动画组，要按顺序播放，这个动画需要等上一个动画结束再开始
    dismissAnimation.removedOnCompletion = YES;
    
    
    // 三、将2个动画加入一个动画组
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[drawAnimation, dismissAnimation];
    group.duration = 4;
    group.repeatCount = INFINITY;
    group.removedOnCompletion = YES;
    [_alipayLayer addAnimation:group forKey:@"DrawCircleAnimationKey"];
    
    
    // 3.1 2周圆动画结束后，执行打勾动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 3.2 停止圆弧动画
        // PS: 在开始下一个打勾动画前需要停止圆弧的动画，停止动画苹果推荐的做法是直接设置speed为0
        _alipayLayer.speed = 0;
        
        
        // 四、制作完成打勾的动画
        UIBezierPath *tickPath = [UIBezierPath bezierPath];
        [tickPath moveToPoint:CGPointMake(130, 150)];
        [tickPath addLineToPoint:CGPointMake(145, 165)];
        [tickPath addLineToPoint:CGPointMake(170, 140)];
        
        _tickLayer = [CAShapeLayer layer];
        _tickLayer.path = tickPath.CGPath;
        _tickLayer.fillColor = [UIColor clearColor].CGColor;
        _tickLayer.strokeColor = RGBA(5, 154, 227, 1).CGColor;
        _tickLayer.lineWidth = 3.f;
        [self.view.layer addSublayer:_tickLayer];
        
        CABasicAnimation *tickAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        tickAnimation.fromValue = @0;
        tickAnimation.toValue = @1;
        tickAnimation.duration = 2.f;
        [_tickLayer addAnimation:tickAnimation forKey:@"TickAnimationKey"];
        tickAnimation.removedOnCompletion = YES;
    });
}
#pragma mark - 停止动画
- (void)stopAnimation
{
    _tickLayer.speed = 0;
    [self.view.layer removeAllAnimations];
    [self.alipayLayer removeFromSuperlayer];
    self.alipayLayer = nil;
    [self.tickLayer removeFromSuperlayer];
    self.tickLayer = nil;
}
#pragma mark - 重启动画
- (void)replayAnimation
{
    [self stopAnimation];
    [self startAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
