//
//  ViewController.m
//  CollectionViewTutorial
//
//  Created by George Uno on 10/7/13.
//  Copyright (c) 2013 iShoutOut. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic,weak) IBOutlet UITextField *textField;
-(IBAction)shareButtonTapped:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
}

-(IBAction)shareButtonTapped:(id)sender {
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
