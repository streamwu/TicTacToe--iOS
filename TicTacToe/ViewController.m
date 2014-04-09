//
//  ViewController.m
//  TicTacToe
//
//  Created by StreamWu on 2/21/14.
//  Copyright (c) 2014 Stream Wu. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SymbolImageView.h"

// Class Extension (Private) ///////////////////////////////////////////////////
@interface ViewController ()

@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;



@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self playBackgroundMusic];
    [self initBoard];
    [self initSymbolArea];
}

/*******************************************************************************
 * @method          initBoard
 * @description     Add 9 UIViews to the grids array
                    Add them to the tac_tic_board_imageView and set transparent
 ******************************************************************************/
-(void) initBoard{
    _count = 0;
    
    //set boardImageView
    UIImageView *board = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tic_tac_board"]];
    [board setFrame:CGRectMake(25,75,270,270)];
    [board setTag:100];
    [self.view addSubview:board];
    
    _grids = [[NSMutableArray alloc] initWithCapacity:9];
    _gridRecord = [[NSMutableArray alloc] initWithCapacity:9];
    
    for(int i = 0; i < 9; i++){
        UIView * grid = [[UIView alloc] init];
        [grid setOpaque:NO];
        grid.frame = CGRectMake(25+i%3*90, 75+i/3*90, 90, 90);
        [_grids setObject:grid atIndexedSubscript:i];
        
        //Add grid to boardView
        [board addSubview:grid];
        
        [_gridRecord setObject:[NSNumber numberWithInt:i] atIndexedSubscript:i];
    }
    NSLog(@"board initialized");
}


/*******************************************************************************
 * @method          initSymbolArea
 * @description     Load symbol X and O to correspondent position
                    Enlarger the X for 3s then return to normal
                    And make the O more transparent
 ******************************************************************************/
-(void) initSymbolArea{
    SymbolImageView *x = [self replenishSymbolX];
    SymbolImageView *o = [self replenishSymbolO];
    [x symbolWaitingForDrag];
    [o symbolSetUnable];
    _symbolForNextRound = o;
    
    NSLog(@"symbol area initialized");
}

/*******************************************************************************
 * @method          replenishSymbolX & replenishSymbolO
 * @description
 ******************************************************************************/
-(SymbolImageView*)replenishSymbolX{
    SymbolImageView *x = [[SymbolImageView alloc]initWithImage:[UIImage imageNamed:@"x"]];
    [x setFrame:CGRectMake(40, 380, 90, 90)];
    [x setTag:101];
    [self.view addSubview:x];
    [self addPanGestureRecognizer:x];
    return x;
}

-(SymbolImageView*) replenishSymbolO{
    
    SymbolImageView *o = [[SymbolImageView alloc]initWithImage:[UIImage imageNamed:@"o"]];
    [o setFrame:CGRectMake(190, 380, 90, 90)];
    [o setTag:102];
    [self.view addSubview:o];
    [self addPanGestureRecognizer:o];
    return o;
}

/*******************************************************************************
 * @method          addPanGestureRecognizer
 * @description     Add PanGestureRecognizer to a symbolImageView
 ******************************************************************************/


- (void)addPanGestureRecognizer:(UIView*)symbol{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(dragToBoard:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [symbol addGestureRecognizer:panGesture];
    
}


/*******************************************************************************
 * @method          dragToBoard
 * @description
 ******************************************************************************/
- (void)dragToBoard:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *symbol = [gestureRecognizer view];
    [[symbol superview] bringSubviewToFront:symbol];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        [self playSoundEffect:@"begin_drag"];
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRecognizer translationInView:[symbol superview]];
            [symbol setCenter:CGPointMake([symbol center].x + translation.x, [symbol center].y + translation.y)];
            [gestureRecognizer setTranslation:CGPointZero inView:[symbol superview]];
        }
    [self checkOccupationAndMatch:gestureRecognizer];
}
                                                            
/*******************************************************************************
 * @method          checkOccupation
 * @description     if the grid is empty, add the X/O, prepare for the next turn
 ******************************************************************************/
-(void) checkOccupationAndMatch:(UIPanGestureRecognizer *)gestureRecognizer{
    UIView *symbol = [gestureRecognizer view];
    CGFloat x = [symbol center].x;
    CGFloat y = [symbol center].y;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        int nGrid = ((int)(x-25))/90 + ((int)(y-75))/90 *3;
        NSLog(@"grid--%i",nGrid);
        if (nGrid > 8 || nGrid < 0) {
            if (symbol.tag == 101) {
                [(SymbolImageView*)symbol backToXOriginalPlace];
            }
            else
                [(SymbolImageView*)symbol backToOOriginalPlace];
        }
        else{
            UIView *grid = [_grids objectAtIndex:nGrid];
            
            bool occupation =
            ![[_gridRecord objectAtIndex:nGrid] isEqualToNumber:[NSNumber numberWithInt:nGrid]];
                 //if not null, occupied.
            bool match = CGRectIntersectsRect(grid.frame, symbol.frame);
            NSLog(occupation?@"occupied?yes":@"occupied?no");
            NSLog(match?@"match?yes":@"match?no");
            if (match && !occupation) {
                //Successfullly place a chess
                symbol.center = [grid center];
                [self.view addSubview:symbol];
                [self playSoundEffect:@"placed"];
                
                NSLog(@"symbol tag %ld",(long)symbol.tag);
                [_gridRecord setObject:[NSNumber numberWithInt:symbol.tag] atIndexedSubscript:nGrid];
                _count++;
                int tagOfSymbolJustPlaced = symbol.tag;
                symbol.tag = nGrid+1;
                NSLog(@"new symbol tag %ld",(long)symbol.tag);
                NSLog(@"a new symbol placed");
                
                [self checkWinOrStale:tagOfSymbolJustPlaced];

            }
            else if(match && occupation){
                [self playSoundEffect:@"back"];
                if (symbol.tag == 101) {
                    [(SymbolImageView*)symbol backToXOriginalPlace];
                }
                else
                    [(SymbolImageView*)symbol backToOOriginalPlace];
                
            }
            else if(!match){
                if (symbol.tag == 101) {
                    [(SymbolImageView*)symbol backToXOriginalPlace];
                }
                else
                    [(SymbolImageView*)symbol backToOOriginalPlace];
                
            }
        }

    }
    
    
}

/*******************************************************************************
 * @method          checkWinOrStale
 * @description     check whether a player wins everytime a X/O is added
 ******************************************************************************/
-(void) checkWinOrStale:(int)tagOfSymbolJustPlaced{
    bool win = NO;
    bool stalemate = NO;
    
    for (int i = 0; i <= 6; i = i + 3) {

        NSNumber *a1 = [_gridRecord objectAtIndex:i];
        NSNumber *a2 = [_gridRecord objectAtIndex:i+1];
        NSNumber *a3 = [_gridRecord objectAtIndex:i+2];
        
        if ([a1 isEqualToNumber:a2]&&[a2 isEqualToNumber:a3]) {
            win=YES;
            
        }
        
    }
    for (int i = 0; i <= 2; i++) {
        NSNumber *a1 = [_gridRecord objectAtIndex:i];
        NSNumber *a2 = [_gridRecord objectAtIndex:i+3];
        NSNumber *a3 = [_gridRecord objectAtIndex:i+6];
        if ([a1 isEqualToNumber:a2]&&[a2 isEqualToNumber:a3]) {
            win=YES;
        }
    }
    
    NSNumber *a0 = [_gridRecord objectAtIndex:0];
    NSNumber *a4 = [_gridRecord objectAtIndex:4];
    NSNumber *a8 = [_gridRecord objectAtIndex:8];
    if ([a0 isEqualToNumber:a4]&&[a4 isEqualToNumber:a8]) {
        win=YES;
    }
    
    NSNumber *a2 = [_gridRecord objectAtIndex:2];
    NSNumber *a6 = [_gridRecord objectAtIndex:6];
    if ([a2 isEqualToNumber:a4]&&[a4 isEqualToNumber:a6]) {
        win=YES;
    }
    
    
    if(win == NO && _count == 9){
        stalemate = YES;
    }
    
    NSLog(win?@"win?yes":@"win?no");
    NSLog(stalemate?@"stalemate?yes":@"stalemate?no");
    
    if (win == YES) {
        [self showWin];

    }
    if (stalemate == YES) {
        [self showDraw];
    }
    if (win == NO && stalemate == NO) {
        [self startNextRound:tagOfSymbolJustPlaced];
    }
}

-(void)startNextRound:(int)tagOfSymbolJustPlaced{
    //If no one wins, exchange turn and continue
    if (tagOfSymbolJustPlaced == 101) {

        //Replenish x and set unable
        SymbolImageView *x = [self replenishSymbolX];
        [x symbolSetUnable];
        
        SymbolImageView *o = _symbolForNextRound;    //Fetch symbol form symbolForNextRound
        _symbolForNextRound = x;     // Pass newly generated symbol to symbolForNextRound
        
        [o symbolWaitingForDrag];
    }
    else if(tagOfSymbolJustPlaced == 102) {
        //Replenish o and set unable
        SymbolImageView *o = [self replenishSymbolO];
        [o symbolSetUnable];
        
        SymbolImageView *x = _symbolForNextRound;    //Fetch symbol form symbolForNextRound
        _symbolForNextRound = o;     // Pass newly generated symbol to symbolForNextRound
        
        [x symbolWaitingForDrag];
    }
}

/*******************************************************************************
 * @method          showWin
 * @description     show celebration in an alertView and meanwhile play the sound
 ******************************************************************************/
-(void) showWin{
    [self playSoundEffect:@"celebration"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Win!" message:nil delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    alertView.delegate = self;
    [alertView show];
}

/*******************************************************************************
 * @method          showDraw
 * @description     show stalemate notification in an alertView and meanwhile play the sound
 ******************************************************************************/
-(void) showDraw{
    [self playSoundEffect:@"draw"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"A Draw." message:nil delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    alertView.delegate = self;
    [alertView show];
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"OK"]) {
        [self clearBoard];
        NSLog(@"board cleared");
    }
}

/*******************************************************************************
 * @method          clearBoard
 * @description     clear the board after press ok in the alertview
 ******************************************************************************/
-(void) clearBoard{
    _count = 0;
    //Get symbol removed
    UIView *symbol = _symbolForNextRound;
    [symbol removeFromSuperview];
    NSLog(@"symbol removed");
    
    //Get subviews in grids of the board removed
    for (int i = 0; i < 9; i++) {
        if (![[_gridRecord objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:i]]) {
            SymbolImageView *symbol = (SymbolImageView*)[self.view viewWithTag:i+1];
            //[symbol removeFromSuperview];
            [symbol getRemoved];
        }
    }

    [self performSelector:@selector(initBoard) withObject:self afterDelay:3.0];
    [self performSelector:@selector(initSymbolArea) withObject:self afterDelay:3.0];

}


#pragma mark - Sound Effect
/*******************************************************************************
 * @method          playSoundEffect
 * @description     Play a short sound for five differenct conditions
 ******************************************************************************/
- (void)playSoundEffect:(NSString*)soundName
{
    NSLog(@">>> Play sound named: %@",soundName);
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

/*******************************************************************************
 * @method      playBackgroundMusic
 * @description Play music using AVAudioPlayer
 *******************************************************************************/
- (void)playBackgroundMusic
{
    NSError *error;
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"The_Only_Place" ofType:@"mp3"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    
    _backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    [self.backgroundMusic prepareToPlay];
    [self.backgroundMusic play];
    NSLog(@"backgroundMusic loaded");
}

#pragma mark - Buttons

/*******************************************************************************
 * @method          tapInfoButton
 * @description     Show an alert dialogue on tap
 ******************************************************************************/

- (IBAction)tapInfoButton:(id)sender {
    
    UIActionSheet *msg = [[UIActionSheet alloc]
                          initWithTitle:
                          @"1. Drag symbole to the board.\n"
                          "2. placing three respective marks in a horizontal, vertical, or diagonal row wins the game.\n"
                          "3. Press OK to start.\n"
                          delegate:nil
                          cancelButtonTitle:nil  destructiveButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    [msg showInView:self.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
