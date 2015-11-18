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
    
    [CATransaction begin];
    [self.imageView.layer removeAllAnimations];
    self.imageView.image = nil;
    [CATransaction commit];
}

@end
