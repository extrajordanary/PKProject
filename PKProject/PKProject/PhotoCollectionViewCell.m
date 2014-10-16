//
//  PhotoCollectionViewCell.m
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

//- (void)awakeFromNib {
//    // Initialization code
//    self.imageView = [[UIImageView alloc] init];
//    [self.contentView addSubview:self.imageView];
//    [self.imageView setClipsToBounds:YES];
//}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//self = [super initWithCoder:aDecoder];
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
//        self.imageView.frame.origin = CGPointMake(0.0, 0.0);
        [self.contentView addSubview:self.imageView];
        [self.imageView setClipsToBounds:YES];
    }
    return self;
}



@end
