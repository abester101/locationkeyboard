//
//  StickerCollectionViewCell.m
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import "StickerCollectionViewCell.h"

@implementation StickerCollectionViewCell


-(void)prepareForReuse{
    [super prepareForReuse];
    self.item = nil;
    
    self.numberImageView.hidden = YES;
    self.numberLabel.hidden = YES;
    
    [CATransaction begin];
    [self.imageView.layer removeAllAnimations];
    self.imageView.image = nil;
    [CATransaction commit];
}

-(void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted?[UIColor colorWithWhite:0.95f alpha:1.0f]:[UIColor whiteColor];
}

@end
