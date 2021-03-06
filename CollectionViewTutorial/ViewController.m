//
//  ViewController.m
//  CollectionViewTutorial
//
//  Created by George Uno on 10/7/13.
//  Copyright (c) 2013 iShoutOut. All rights reserved.
//

#import "ViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"
#import "FlickrPhotoCell.h"
#import "FlickrPhotoHeaderView.h"
#import "FlickrPhotoViewController.h"
#import <MessageUI/MessageUI.h>

@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate>

@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic,weak) IBOutlet UITextField *textField;
-(IBAction)shareButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,strong) NSMutableDictionary *searchResults;
@property (nonatomic,strong) NSMutableArray *searches;
@property (nonatomic,strong) Flickr *flickr;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) BOOL sharing;
@property (nonatomic,strong) NSMutableArray *selectedPhotos;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searches = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    self.selectedPhotos = [@[] mutableCopy];
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
}

#pragma mark - UICollectionView Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *searchTerm = self.searches[section];
    return [self.searchResults[searchTerm] count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.searches.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    cell.photo = self.searchResults[searchTerm][indexPath.row];
    
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FlickrPhotoHeaderView" forIndexPath:indexPath];
    NSString *searchTerm = self.searches[indexPath.section];
    [headerView setSearchText:searchTerm];
    return headerView;
}
 

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.sharing) {
        NSString *searchTerm = self.searches[indexPath.section];
        FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
        [self performSegueWithIdentifier:@"ShowFlickrPhoto" sender:photo];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    } else {
        // multiple selection
        NSString *searchTerm = self.searches[indexPath.section];
        FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
        [self.selectedPhotos addObject:photo];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sharing) {
        NSString *searchTerm = self.searches[indexPath.section];
        FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
        [self.selectedPhotos removeObject:photo];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchTerm = self.searches[indexPath.section];
    FlickrPhoto *photo = self.searchResults[searchTerm][indexPath.row];
    
    CGSize retVal = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retVal.height += 35;
    retVal.width += 35;
    return retVal;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
                                // TOP, LEFT, BOTTOM, RIGHT
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

#pragma mark - Storyboard Segue Prep
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFlickrPhoto"]) {
        FlickrPhotoViewController *photoVC = segue.destinationViewController;
        photoVC.flickrPhoto = sender;
    }
}

#pragma mark - Button Click
-(IBAction)shareButtonTapped:(id)sender {
    UIBarButtonItem *shareButton = (UIBarButtonItem *)sender;
    
    
    if (!self.sharing) {
        // if entering Share mode, make DONE button & allow mutli-select
        self.sharing = YES;
        [shareButton setStyle:UIBarButtonItemStyleDone];
        [shareButton setTitle:@"Done"];
        [self.collectionView setAllowsMultipleSelection:YES];
    } else {
        // if exiting share mode, Share button & disallow multi-select
        self.sharing = NO;
        [shareButton setStyle:UIBarButtonItemStyleBordered];
        [shareButton setTitle:@"Share"];
        [self.collectionView setAllowsMultipleSelection:NO];
        
        // if the user has selected photos & hit DONE, bring up email composer
        if ([self.selectedPhotos count] > 0) {
            [self showMailComposerAndSend];
        }
        
        // deselect all cells and clean up selectItems array
        for (NSIndexPath* indexPath in self.collectionView.indexPathsForSelectedItems) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        [self.selectedPhotos removeAllObjects];
    }
}

#pragma mark - EMAIL
-(void)showMailComposerAndSend {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Check out these Flickr Photos"];
        NSMutableString *emailBody = [NSMutableString string];
        
        for (FlickrPhoto *photo in self.selectedPhotos) {
            NSString *url = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
            [emailBody appendFormat:@"<div><img src='%@'></div><br>",url];
        }
        
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MAIL FAIL" message:@"You can't send mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate methods
// called when Return button hit
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.spinner startAnimating];
    // Use Flickr class to search for a term asynchronously.
    [self.flickr searchFlickrForTerm:textField.text completionBlock:^(NSString *searchTerm, NSArray *results, NSError *error) {
        if (results && results.count > 0) {
            // checks if duplicate, adds to front of array if not
            if (![self.searches containsObject:searchTerm]) {
                NSLog(@"Found %lu photos for '%@'",results.count, searchTerm);
                [self.searches insertObject:searchTerm atIndex:0];
                self.searchResults[searchTerm] = results;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // new data has been downloaded, reload collection view on main thread
                [self.collectionView reloadData];
                [self.spinner stopAnimating];
            });
        } else {
            // error occurred
            NSLog(@"Flickr Search Error: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                // request has failed, update UI on main thread
                [self.spinner stopAnimating];
            });
        }
    }];
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
