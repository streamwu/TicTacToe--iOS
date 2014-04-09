//
//  ViewController.h
//  TicTacToe
//
//  Created by StreamWu on 2/21/14.
//  Copyright (c) 2014 Stream Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SymbolImageView.h"


@interface ViewController : UIViewController<UIGestureRecognizerDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray *grids;
@property (strong,nonatomic) NSMutableArray *gridRecord;
@property (assign,nonatomic) NSInteger count;
@property (assign,nonatomic) SymbolImageView *symbolForNextRound;

- (IBAction)tapInfoButton:(id)sender;
- (void)playSoundEffect:(NSString*)soundName;




@end
