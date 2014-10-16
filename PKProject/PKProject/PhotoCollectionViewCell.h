//
//  PhotoCollectionViewCell.h
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Spot;

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) Spot *spot;

@end
