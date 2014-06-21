//
//  INUVersionHistoryViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 21/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUVersionHistoryViewController.h"

@interface INUVersionHistoryViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation INUVersionHistoryViewController

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
    
    NSURL *url = [NSURL URLWithString:@"Version-History.txt" relativeToURL:[[NSBundle mainBundle] bundleURL]];
    NSString *textFromFile = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    self.textView.text = textFromFile;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
