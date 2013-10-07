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


@interface ViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic,weak) IBOutlet UITextField *textField;
-(IBAction)shareButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,strong) NSMutableDictionary *searchResults;
@property (nonatomic,strong) NSMutableArray *searches;
@property (nonatomic,strong) Flickr *flickr;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searches = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
}
 */

-(IBAction)shareButtonTapped:(id)sender {
    
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
                NSLog(@"Found %lu photos for %@",results.count, searchTerm);
                [self.searches insertObject:searchTerm atIndex:0];
                self.searchResults[searchTerm] = results;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // new data has been downloaded, reload collection view on main thread
                [self.spinner stopAnimating];
            });
        } else {
            // error occurred
            NSLog(@"Flickr Search Error: %@\n%@", error.localizedDescription, error.localizedFailureReason);
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
