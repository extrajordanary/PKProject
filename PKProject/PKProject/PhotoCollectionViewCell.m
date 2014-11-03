//
//  PhotoCollectionViewCell.m
//  PKProject
//
//  Created by Jordan on 10/15/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "Spot+Extended.h"

@implementation PhotoCollectionViewCell

// ??? - below not even used
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:self.imageView];
        [self.imageView setClipsToBounds:YES];
        
        // TODO: put default loading image here?
        self.imageView.image = [UIImage imageNamed:@"loadingSpotPhoto.jpg"];
    }
    return self;
}

// assign a spot to the cell and initiate the image updating
-(void)displayInfoForSpot:(Spot*)spot {
    // assign spot to self
    self.spot = spot;
    
    // asynch calls to get display data from spot
    // image
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        UIImage *image = [self.spot getThumbnail]; // returns image for first Photo object
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self displayImage:image];
        });
    });
    // TODO: number of favorites
    // TODO: if this user has favorited it or saved it
}

-(void)displayImage:(UIImage*)image {
    self.imageView.image = image;
}

@end
