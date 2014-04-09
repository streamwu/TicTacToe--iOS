//
//  XImageView.m
//  TicTacToe
//
//  Created by StreamWu on 2/21/14.
//  Copyright (c) 2014 Stream Wu. All rights reserved.
//

#import "SymbolImageView.h"

@implementation SymbolImageView

/*******************************************************************************
 * @method          symbolWaitingForDrag
 * @description     Enlarger the player's symbol for 3s then return to normal
 *                  Using animation
 ******************************************************************************/
-(void) symbolWaitingForDrag{
    [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveLinear                      animations:^{
        self.transform = CGAffineTransformScale(self.transform, 2.0, 2.0);
        self.alpha = 0.5f;
    }
                     completion:^(BOOL completed) {
                         [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.transform =
                                              CGAffineTransformScale(self.transform, 0.5, 0.5);
                                              self.alpha = 1.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              NSLog(@"Animation Finished");
                                          }];
                         
                     }];
    self.userInteractionEnabled = YES;
    NSLog(@"symbolWaitingForDrag");
}


/*******************************************************************************
 * @method          symbolSetUnable
 * @description     Make the other player's symbol transparent
 ******************************************************************************/
-(void) symbolSetUnable{
    self.userInteractionEnabled = NO;
}

/*******************************************************************************
 * @method          backToXOriginalPlace, backToOOriginalPlace
 * @description
 ******************************************************************************/

-(void) backToXOriginalPlace{
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.center = CGPointMake(85, 425);
                     } completion:^(BOOL finished) {
                         NSLog(@"back");
                     }];
}
     
-(void) backToOOriginalPlace{
        
         [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.center = CGPointMake(235, 425);
                     } completion:^(BOOL finished) {
                         NSLog(@"back");
                     }];
}

-(void) getRemoved{
    [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, 2.0, 2.0);
                         self.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.8 delay:0.2 options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.transform =
                                              CGAffineTransformScale(self.transform, 0.5, 0.5);
                                              self.alpha = 0.5f;
                                          }
                                          completion:^(BOOL finished) {
                                              [self removeFromSuperview];
                                              NSLog(@"removed");
                                          }];
                         
                     }];
}

@end
