//
//  INUPostsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUPostsTableViewController.h"
#import "INUEventTabBarController.h"
#import "Bookmark.h"
#import "Event.h"
#import "Post.h"
#import "INUPostTableViewCell.h"
#import "INUDataManager.h"
#import "INUUtils.h"
#import "INUConstants.h"
#import "User.h"
#import "Contact.h"

@interface INUPostsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *editorTextView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property INUPostTableViewCell *layoutCell;
@property BOOL notifyUserUpdateOnDisappear;

@end

@implementation INUPostsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [INUUtils initBackground:self.tableView];
    
    _editorTextView.layer.borderWidth = 1.0f;
    _editorTextView.layer.cornerRadius = 4.0f;
    _editorTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _editorTextView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    _postButton.layer.cornerRadius = 4.0f;
    UIImage *highlightImage = [INUUtils imageWithColor:[INUUtils buttonHighlightColor]];
    [_postButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    _layoutCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    INUEventTabBarController *eventTabBarController = (INUEventTabBarController *)self.parentViewController;
    _bookmark = eventTabBarController.bookmark;
    _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (INUEventTabBarController *)eventTabBarController
{
    return (INUEventTabBarController *)self.tabBarController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if (_notifyUserUpdateOnDisappear)
    {
        [[INUDataManager sharedInstance] notifyUserUpdate];
        _notifyUserUpdateOnDisappear = NO;
    }
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
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_layoutCell setPost:_event.posts[indexPath.row] event:_event];
 
    _layoutCell.bounds = CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, _layoutCell.bounds.size.height);
    [_layoutCell setNeedsLayout];
    [_layoutCell layoutIfNeeded];
    
    CGSize size = [_layoutCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
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

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat viewHeight = self.tableView.frame.size.height;
    
    CGRect rawKeyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect realKeyboardRect = [self.view.window convertRect:rawKeyboardRect toView:self.view.window.rootViewController.view];
    
    [self.tableView setContentOffset:CGPointMake(0.0f, contentHeight - viewHeight + realKeyboardRect.size.height) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

#pragma mark - Actions

- (void)onTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.tableView.tableFooterView];
        if (location.y < 0)
        {
            [self.view endEditing:YES];
        }
    }
}

- (IBAction)onTapPost:(id)sender
{
    NSString *text = [_editorTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length > 0)
    {
        NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _bookmark.eventId, @"event_id",
                                    _bookmark.userId, @"user_id",
                                    @"T", @"type",
                                    text, @"data",
                                    nil];
        [[INUDataManager sharedInstance] requestFromServer:INUServicePost params:paramsDict info:nil onError:nil];
        
        _editorTextView.text = @"";
        
        Post *post = [[Post alloc] init];
        post.postId = 0; //TODO
        post.userId = _bookmark.userId;
        post.type = PostTypeText;
        post.data = text;
        post.created = [[NSDate alloc] init];
        
        [_event.posts addObject:post];
        
        // save default name, if nothing saved yet.
        User *me = [_event getUserWithId:_bookmark.userId];
        if ([me isNameUndefined] && [INUDataManager sharedInstance].userContact.name.length > 0)
        {
            me.name = [INUDataManager sharedInstance].userContact.name;
            _notifyUserUpdateOnDisappear = YES;
            
            NSDictionary *paramsDict = @{@"event_id": _bookmark.eventId,
                                         @"user_id": _bookmark.userId,
                                         @"name": me.name};
            [[INUDataManager sharedInstance] requestFromServer:INUServiceUpdateUser params:paramsDict info:nil onError:nil];
        }
        
        int row = (int)[_event.posts count] - 1;
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:row inSection:0]];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUEventLoadedNotification || notification.name == INUUserUpdatedNotification)
    {
        _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
        [self.tableView reloadData];
    }
}

@end
