//
//  FlickrPhotoCell.h
//  CollectionViewTutorial
//
//  Created by George Uno on 10/7/13.
//  Copyright (c) 2013 iShoutOut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class FlickrPhoto;

@interface FlickrPhotoCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) FlickrPhoto *photo;
@end
