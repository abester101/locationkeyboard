//
//  StickerCollectionViewCell.h
//  Sticker Languages
//
//  Created by Andrew Milham on 11/17/15.
//  Copyright © 2015 Apps Over Easy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Item.h"

@interface StickerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) Item *item;

@end
