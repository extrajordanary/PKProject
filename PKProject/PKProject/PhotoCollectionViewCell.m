//
//  PhotoCollectionViewCell.m
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:self.imageView];
        [self.imageView setClipsToBounds:YES];
    }
    return self;
}

@end
