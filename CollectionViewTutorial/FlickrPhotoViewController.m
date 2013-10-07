//
//  FlickrPhotoViewController.m
//  CollectionViewTutorial
//
//  Created by George Uno on 10/7/13.
//  Copyright (c) 2013 iShoutOut. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface FlickrPhotoViewController ()
@property (weak) IBOutlet UIImageView *imageView;
-(IBAction)done:(UIButton *)sender;
@end

@implementation FlickrPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.flickrPhoto.largeImage) {
        self.imageView.image = self.flickrPhoto.largeImage;
    } else {
        self.imageView.image = self.flickrPhoto.thumbnail;
        [Flickr loadImageForPhoto:self.flickrPhoto thumbnail:NO completionBlock:^(UIImage *photoImage, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = self.flickrPhoto.largeImage;
                });
            }
        }];
    }
}

-(IBAction)done:(UIButton *)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
