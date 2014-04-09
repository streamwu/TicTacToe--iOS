//
//  OImageView.m
//  TicTacToe
//
//  Created by StreamWu on 2/21/14.
//  Copyright (c) 2014 Stream Wu. All rights reserved.
//

#import "OImageView.h"

@implementation OImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = (OImageView*)[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"o"]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
