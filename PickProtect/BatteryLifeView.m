//
//  BatteryLifeView.m
//  Protecto
//
//  Created by Shak on 1/17/14.
//  Copyright (c) 2014 Shak. All rights reserved.
//

#import "BatteryLifeView.h"

@implementation BatteryLifeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.batteryPercent = 0.0;
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //Draw the battery outline
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-0.1*CGRectGetWidth(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-0.1*CGRectGetWidth(rect), CGRectGetMinY(rect)+0.3*CGRectGetHeight(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect)+0.3*CGRectGetHeight(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect)+0.7*CGRectGetHeight(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-0.1*CGRectGetWidth(rect), CGRectGetMinY(rect)+0.7*CGRectGetHeight(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-0.1*CGRectGetWidth(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextFillPath(ctx);
    //Draw how full it is
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+self.batteryPercent*CGRectGetWidth(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+self.batteryPercent*CGRectGetWidth(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(ctx);
    if(self.batteryPercent > 0.200) CGContextSetRGBFillColor(ctx, 121.0/255.0, 245.0/255.0, 129.0/255.0, 1.0);
    else CGContextSetRGBFillColor(ctx, 240.0/255.0, 21.0/255.0, 80.0/255.0, 1.0);
    CGContextFillPath(ctx);
}


@end
