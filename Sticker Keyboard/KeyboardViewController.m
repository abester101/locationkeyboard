//
//  KeyboardViewController.m
//  Sticker Keyboard
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "KeyboardViewController.h"
#import <Parse/Parse.h>

#import "DataManager.h"

#import "Reachability.h"
#define APP_GROUP @"group.appsovereasy.stickerlanguages"

#import "RepeatingButton.h"

#import "StickerCollectionViewCell.h"
#import "Mixpanel.h"

#import "HorizontalPagingCollectionViewLayout.h"


@import MobileCoreServices;

@interface KeyboardViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,DataManagerDelegate,SearchKeyboardViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *nextKeyboardButton;
@property (strong, nonatomic) IBOutlet RepeatingButton *backspaceButton;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) IBOutlet UIView *shareInstructionView;
@property (strong, nonatomic) NSTimer *shareInstructionTimer;

@property (strong, nonatomic) DataManager *dataManager;

@property (nonatomic, strong) NSMutableArray *keyboardButtons;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) BOOL reachable;

@property (strong, nonatomic) IBOutlet UILabel *openAccessLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (BOOL)isOpenAccessGranted
{
    return [UIPasteboard generalPasteboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Mixpanel sharedInstanceWithToken:@"4798bff90cbd582c4ed9f9e680d2bb13"];
    [[Mixpanel sharedInstance] track:@"Launched Keyboard"];
    
    
    self.dataManager = [[DataManager alloc] init];
    self.dataManager.delegate = self;
    
    _backspaceButton.repeatTarget = self;
    _backspaceButton.repeatTargetAction = @selector(tapBackspaceButton:);
    _backspaceButton.autorepeatStartDelay = 0.7f;
    _backspaceButton.autorepeatPressDelay = 0.17f;
    
    self.searchKeyboardView = [[NSBundle mainBundle] loadNibNamed:@"SearchKeyboardView" owner:self options:nil].firstObject;
    self.searchKeyboardView.frame = self.collectionView.frame;
    self.searchKeyboardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchKeyboardView.hidden = YES;
    self.searchKeyboardView.delegate = self;
    [self.view addSubview:self.searchKeyboardView];
    
//    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:270];
//    [self.inputView addConstraint:self.heightConstraint];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.searchKeyboardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.searchKeyboardView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.searchKeyboardView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.searchKeyboardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.nextKeyboardButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]]];
    
//    HorizontalPagingCollectionViewLayout *hpCollectionViewLayout = [[HorizontalPagingCollectionViewLayout alloc] init];
//    hpCollectionViewLayout.itemSize = self.collectionView.frame.size.height/2
//    
//    [self.collectionView setCollectionViewLayout:hpCollectionViewLayout];
    
    
    if (![self isOpenAccessGranted]) {
        [self displayFullAccessMessage];
    } else {
        Reachability *reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        reach.reachableBlock = ^(Reachability*reach) {
            
            //                    _textLabelFullAccess.hidden = YES;
            //                    _textLabelFullAccess2.hidden = YES;
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.openAccessLabel.hidden = YES;
                
                for (UIButton *button in _keyboardButtons) {
                    button.hidden = YES;
                }
                [self.dataManager start];
                _reachable = YES;
            });
            
            
        };
        reach.unreachableBlock = ^(Reachability*reach) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.openAccessLabel.text = @"Please check your internet connection.";
                self.searchKeyboardView.hidden = NO;
                //                if (!_decimalKeyboardLoaded) {
                //                    [self loadDecimalKeyboard];
                //                    _decimalKeyboardLoaded = YES;
                //                }
                //                _textLabelFullAccess = [[UILabel alloc] initWithFrame:CGRectMake(12, 125, (width/2)-6, 80)];
                //                _textLabelFullAccess.text = @"Please check your internet connection.";
                //                _textLabelFullAccess.font = [UIFont systemFontOfSize:14];
                //                _textLabelFullAccess.numberOfLines = 0;
                //                [self.view addSubview:_textLabelFullAccess];
                //                self.loadingSpinner.hidden = YES;
                _reachable = NO;
            });
        };
        reach.failedBlock = ^(Reachability*reach) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayFullAccessMessage];
            });
        };
        [reach startNotifier];
    }
    
    
}

- (void)displayFullAccessMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.openAccessLabel.hidden = NO;
        self.searchKeyboardView.hidden = NO;
        //        double width = [[UIScreen mainScreen] bounds].size.width;
        //        _textLabelFullAccess = [[UILabel alloc] initWithFrame:CGRectMake(12, 125, (width/2)-6, 40)];
        //        _textLabelFullAccess.text = @"Please enable full access. See instructions in main app.";
        //        _textLabelFullAccess.numberOfLines = 0;
        //        _textLabelFullAccess.font = [UIFont systemFontOfSize:12];
//        [self.view addSubview:_textLabelFullAccess];
//        [self.view addSubview:_textLabelFullAccess2];
//        self.loadingSpinner.hidden = YES;
//        if (!_decimalKeyboardLoaded) {
//            [self loadDecimalKeyboard];
//        }
//        _decimalKeyboardLoaded = YES;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

-(BOOL)isInLandscapeMode{
    return [UIScreen mainScreen].bounds.size.width>[UIScreen mainScreen].bounds.size.height;
        
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGFloat kbHeight = 270;
    if([self isInLandscapeMode]){
        kbHeight = 180;
    }
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kbHeight];
    [self.view addConstraint:self.heightConstraint];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    //self.collectionView.pagingEnabled = YES;
    
    if(self.heightConstraint){
        if([self isInLandscapeMode]){
            self.heightConstraint.constant = 180;
        } else {
            self.heightConstraint.constant = 270;
        }
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    if([self isInLandscapeMode]){
        flowLayout.sectionInset = UIEdgeInsetsMake(4, 4, 2, 4);
        flowLayout.minimumInteritemSpacing = 3;
        flowLayout.minimumLineSpacing = 3;
    } else {
        
        flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 4, 8);
        flowLayout.minimumInteritemSpacing = 4;
        flowLayout.minimumLineSpacing = 6;
    }
    
    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (IBAction)tapNextKeyboardButton:(id)sender {
    [self hideShareInstructionView];
    [self advanceToNextInputMode];
}

- (IBAction)tapBackspaceButton:(id)sender {
    [self hideShareInstructionView];
    [self.textDocumentProxy deleteBackward];
}

- (void)insertSymbol:(id)sender {
    //UIButton *button = (UIButton *)sender;
    //int tag = (int)button.tag;
    //[self.textDocumentProxy insertText:[_symbols objectAtIndex:tag]];
}

-(void)gotLocation:(Location *)location dataManager:(DataManager *)dataManager{
    [dataManager fetchData];
}

-(void)startedUpdatingObjectsForDataManager:(DataManager *)dataManager{
    [self.activityIndicatorView startAnimating];
}

-(void)failedToGetLocationForDataManager:(DataManager *)dataManager{
    [self.activityIndicatorView stopAnimating];
    self.searchKeyboardView.hidden = NO;
}

-(void)updatedObjectsForDataManager:(DataManager *)dataManager{
    [UIView transitionWithView:self.collectionView duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.collectionView reloadData];
        self.searchKeyboardView.hidden = YES;
        
    } completion:^(BOOL finished) {
        [self.activityIndicatorView stopAnimating];
        if(dataManager.objects.count==0){
            self.openAccessLabel.hidden = NO;
            self.searchKeyboardView.hidden = NO;
            self.openAccessLabel.text = @"We don't have anything in your area yet.";
        } else {
            self.openAccessLabel.hidden = YES;
            self.searchKeyboardView.hidden = YES;
        }
    }];
    
    
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataManager.objects.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    StickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StickerCell" forIndexPath:indexPath];
    
    //cell.delegate = self;
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(StickerCollectionViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    
    Item *item = self.dataManager.objects[indexPath.item];
    
    
    if(cell.item!=item){
        cell.item = item;
        
        PFFile *imageFile = item.image;
        if(imageFile) {
            if(imageFile.isDataAvailable){
                [self loadImage:imageFile intoCell:cell];
            } else {
            [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                NSLog(@"Downloaded image");
                if (!error&&cell.item==item) {
                    [self loadImage:imageFile intoCell:cell];
                }
            }];
            }
            
            
            
        }
//        if(indexPath.item<3){
//            cell.numberImageView.hidden = NO;
//            cell.numberLabel.hidden = NO;
//            cell.numberLabel.text = [NSString stringWithFormat:@"%li",indexPath.item+1];
//        } else {
            cell.numberImageView.hidden = YES;
            cell.numberLabel.hidden = YES;
//        }
    }
    
}

-(void)loadImage:(PFFile*)imageFile intoCell:(StickerCollectionViewCell*)cell{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSData *data = imageFile.getData;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if([imageFile.name.pathExtension.uppercaseString isEqualToString:@"GIF"]){
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                [UIView transitionWithView:cell.imageView duration:0.05f options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent animations:^{
                    [cell.imageView setAnimatedImage:image];
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                UIImage *image = [UIImage imageWithData:data];
                
                [UIView transitionWithView:cell.imageView duration:0.05f options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowAnimatedContent animations:^{
                    [cell.imageView setImage:image];
                } completion:^(BOOL finished) {
                    
                }];
            }
        });
    });
    
    
}

#pragma mark - UICollectionViewDelegate Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    Item *item = self.dataManager.objects[indexPath.item];
    //StickerCollectionViewCell *cell = (StickerCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if([UIPasteboard generalPasteboard]&&item.image){
        
        [item.image getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
           
            if(!error){
                
                NSDictionary *imgDic = nil;
                
                if([item.image.name.pathExtension.uppercaseString isEqualToString:@"GIF"]){
                    imgDic = @{item.fileType:data};
                } else {
                    imgDic = @{item.fileType:data};
                }
                
                //NSDictionary *stringDic = @{(NSString*)kUTTypeUTF8PlainText:@"Sent via Speakeazy"};
                
                [[UIPasteboard generalPasteboard] setItems:@[imgDic]];
                
                self.shareInstructionView.alpha = 0.0f;
                self.shareInstructionView.hidden = NO;
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    self.shareInstructionView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    self.shareInstructionTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(hideShareInstructionView) userInfo:nil repeats:NO];
                    [[Mixpanel sharedInstance] track:@"Tapped on Image"];
                }];
                
            }
            
        }];
        
        
       
        
        
    } else {
        
        
    }
    
    item.uses++;
    [item saveEventually];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    
    CGFloat height = (collectionView.frame.size.height - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom - flowLayout.minimumLineSpacing*3) / 4;
    
    return CGSizeMake(height,height);
}



-(IBAction)tapShareInstructionView:(UITapGestureRecognizer*)recognizer{
    [self hideShareInstructionView];
}

-(void)tapView:(UITapGestureRecognizer*)recognizer{
    [self hideShareInstructionView];
}

-(void)hideShareInstructionView{
    if(!self.shareInstructionView.hidden){
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.shareInstructionView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.shareInstructionView.hidden = YES;
        }];
    }
    if(self.shareInstructionTimer){
        [self.shareInstructionTimer invalidate];
        self.shareInstructionTimer = nil;
    }
}


-(void)searchKeyboardTappedGo:(SearchKeyboardView*)searchKeyboardView{
    [self.textDocumentProxy insertText:@"\n"];
}
-(void)searchKeyboard:(SearchKeyboardView*)searchKeyboardView tappedKey:(NSString*)key{
    [self.textDocumentProxy insertText:[key isEqualToString:@"_"]?@" ":key];
}


@end
