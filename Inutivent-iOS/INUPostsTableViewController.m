//
//  INUPostsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUPostsTableViewController.h"
#import "Bookmark.h"
#import "Event.h"
#import "Post.h"
#import "INUPostTableViewCell.h"
#import "INUDataManager.h"

@interface INUPostsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *editorTextView;

@end

@implementation INUPostsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _editorTextView.layer.borderWidth = 1.0f;
    _editorTextView.layer.cornerRadius = 4.0f;
    _editorTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    _editorTextView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_event.posts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INUPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell setPost:_event.posts[indexPath.row] event:_event];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)onTapPost:(id)sender
{
//    [_editorTextView resignFirstResponder];
    
    NSString *text = [_editorTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length > 0)
    {
        NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _bookmark.eventId, @"event_id",
                                    _bookmark.userId, @"user_id",
                                    @"T", @"type",
                                    text, @"data",
                                    nil];
        [[INUDataManager sharedInstance] requestFromServer:@"post.php" params:paramsDict];
        
        _editorTextView.text = @"";
        
        Post *post = [[Post alloc] init];
        post.postId = 0; //TODO
        post.userId = _bookmark.userId;
        post.type = PostTypeText;
        post.data = text;
        post.created = [[NSDate alloc] init];
        
        [_event.posts addObject:post];
        
        int row = (int)[_event.posts count] - 1;
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:row inSection:0]];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}


@end
