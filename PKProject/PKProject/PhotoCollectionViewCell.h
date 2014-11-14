//
//  PhotoCollectionViewCell.h
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKAnnotationCustom;
@class Spot;

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) Spot *spot;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) MKAnnotationCustom *spotMarker;

-(void)displayInfoForSpot:(Spot*)spot;
-(MKAnnotationCustom*)getMarker;

@end
