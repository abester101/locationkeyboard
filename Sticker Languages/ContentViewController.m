//
//  ContentViewController.m
//  Speakeazy
//
//  Created by Andrew Milham on 12/2/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "ContentViewController.h"
@import AVFoundation;
@import AVKit;

@interface ContentViewController ()

@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.movieFileName){
        [self setMovieFile:_movieFileName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(self.videoContainerView&&self.playerLayer){
        self.playerLayer.frame = self.videoContainerView.bounds;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapMainButton:(id)sender {
    if(self.delegate){
        [self.delegate contentViewControllerDidTapMainButton:self];
    }
}


-(void)setMovieFile:(NSString *)movieFileName{
    self.playerItem = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:movieFileName withExtension:@"mov"]];
//    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.videoContainerView.bounds;
    [self.videoContainerView.layer addSublayer:self.playerLayer];
    [self.player play];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    
    
    
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = self.playerItem;
    [p seekToTime:kCMTimeZero];
}


@end
