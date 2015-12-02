//
//  StickerCollectionViewCell.h
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Item.h"

#import "FLAnimatedImage.h"

@interface StickerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (strong, nonatomic) Item *item;
@property (strong, nonatomic) IBOutlet UIImageView *numberImageView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;

@end
