//
//  CallOutView.m
//  Protecto
//
//  Created by Shak on 1/16/14.
//  Copyright (c) 2014 Shak. All rights reserved.
//

#import "CallOutView.h"

@implementation CallOutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextClosePath(ctx);
    CGContextSetRGBFillColor(ctx, 0.0, 157.0/255.0, 223.0/255.0, 1.0);
    CGContextFillPath(ctx);
}


@end
