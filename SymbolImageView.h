//
//  XImageView.h
//  TicTacToe
//
//  Created by StreamWu on 2/21/14.
//  Copyright (c) 2014 Stream Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SymbolImageView : UIImageView<UIGestureRecognizerDelegate>

-(void) symbolWaitingForDrag;
-(void) symbolSetUnable;
-(void) backToXOriginalPlace;
-(void) backToOOriginalPlace;
-(void) getRemoved;

@end
