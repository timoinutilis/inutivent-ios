//
//  INUEditTableViewController.m
//  Gromf
//
//  Created by Timo Kloss on 22/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEditTableViewController.h"
#import "INUUtils.h"
#import "INUInputTableViewCell.h"
#import "INUDateTableViewCell.h"
#import "INUTextTableViewCell.h"
#import "Event.h"
#import "INUDataManager.h"
#import "INUSpinnerView.h"
#import "Bookmark.h"
#import "INUConstants.h"
#import "INUConfig.h"

@interface INUEditTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet INUDateTableViewCell *whenCell;
@property (weak, nonatomic) IBOutlet INUTextTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *mailCell;

@property INUSpinnerView *spinnerView;
@property UIImage *selectedCoverImage;

@end

@implementation INUEditTableViewController

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
    
    [INUUtils initNavigationBar:self.navigationController.navigationBar];
    [INUUtils initBackground:self.tableView];
    
    _titleLabel.layer.shadowOpacity = 1;
    _titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.layer.shadowRadius = 1.5;
    
    _titleCell.textField.placeholder = NSLocalizedString(@"Example: Birthday Party", nil);
    
    _whenCell.datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(60 * 60)];
    _whenCell.datePicker.maximumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(365 * 24 * 60 * 60)];
    NSDate *defaultDate = [INUUtils dateAfter:_whenCell.datePicker.minimumDate atHour:20 minute:0];
    _whenCell.currentDate = defaultDate;
    
    _detailsCell.parentTableView = self.tableView;
    _detailsCell.textView.font = [UIFont systemFontOfSize:18];
    
    _nameCell.textField.placeholder = NSLocalizedString(@"Enter your name", nil);
    _nameCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _mailCell.textField.placeholder = NSLocalizedString(@"Enter your e-mail address", nil);
    _mailCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _mailCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _mailCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if (_bookmarkToEdit)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Event", nil);
        
        Event *event = [[INUDataManager sharedInstance] getEventById:_bookmarkToEdit.eventId];
        
        _titleCell.textField.text = event.title;
        _whenCell.currentDate = event.time;
        _detailsCell.textView.text = event.details;
        
        [self updateCoverImageWithEvent:event];
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Event", nil);
        [self updateCoverImageWithEvent:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeSpinner
{
    if (_spinnerView)
    {
        [_spinnerView removeFromSuperview];
        _spinnerView = nil;
    }
}

- (void)updateCoverImageWithEvent:(Event *)event
{
    if (event && event.cover && ![event.cover isEqualToString:@""])
    {
        NSString *path = [NSString stringWithFormat:@"%@/uploads/%@/%@", INUConfigSiteURL, event.eventId, event.cover];
        NSURL *url = [NSURL URLWithString:path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError)
            {
                // default image
                self.imageView.image = [UIImage imageNamed:@"default_header.jpg"];
            }
            else
            {
                UIImage *image = [UIImage imageWithData:data];
                
                dispatch_async( dispatch_get_main_queue(), ^(void) {
                    self.imageView.image = image;
                });
            }
        }];
    }
    else
    {
        self.imageView.image = [UIImage imageNamed:@"default_header.jpg"];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        CGFloat height = [_detailsCell requiredCellHeight];
        return MAX(88, height);
    }
    return UITableViewAutomaticDimension;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_bookmarkToEdit) ? 3 : 4;
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

#pragma mark - Actions

- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onChangePhoto:(id)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", @"Take Photo", nil];
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", nil];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Gallery
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
//        [INUUtils initNavigationBar:imagePicker.navigationBar];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Camera
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
//        [INUUtils initNavigationBar:imagePicker.navigationBar];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    self.selectedCoverImage = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender
{
    [self.view endEditing:YES];
    
    if ([self validateUserInput])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString *date = [formatter stringFromDate:_whenCell.currentDate];

        formatter.dateFormat = @"HH:mm";
        NSString *hour = [formatter stringFromDate:_whenCell.currentDate];
            
        if (_bookmarkToEdit)
        {
            // Save changes to event

            _spinnerView = [INUSpinnerView addNewSpinnerToView:self.view];

            Event *event = [[INUDataManager sharedInstance] getEventById:_bookmarkToEdit.eventId];
            event.title = _titleCell.textField.text;
            event.time = _whenCell.currentDate;
            event.details = _detailsCell.textView.text;
            
            [[INUDataManager sharedInstance] updateBookmarksForEvent:event];
            [[INUDataManager sharedInstance] notifyEventUpdate];
            
            NSDictionary *params = @{@"event_id": _bookmarkToEdit.eventId,
                                     @"user_id": _bookmarkToEdit.userId,
                                     @"title": event.title,
                                     @"date": date,
                                     @"hour": hour,
                                     @"details": event.details};
            // Photo upload
            NSDictionary *uploadDataDict = nil;
            if (self.selectedCoverImage)
            {
                NSData *imageData = UIImageJPEGRepresentation(self.selectedCoverImage, 0.8);
                uploadDataDict = @{@"cover":imageData};
            }

            [[INUDataManager sharedInstance] requestFromServer:INUServiceUpdateEvent params:params info:nil uploadData:uploadDataDict onError:^BOOL(ServiceError *error) {
                [self removeSpinner];
                return NO;
            }];
        }
        else
        {
            // Create new event

            _spinnerView = [INUSpinnerView addNewSpinnerToView:self.view];
            
            NSDictionary *params = @{@"name": _nameCell.textField.text,
                                     @"mail": _mailCell.textField.text,
                                     @"title": _titleCell.textField.text,
                                     @"date": date,
                                     @"hour": hour,
                                     @"details": _detailsCell.textView.text};
            
            // Photo upload
            NSDictionary *uploadDataDict = nil;
            if (self.selectedCoverImage)
            {
                NSData *imageData = UIImageJPEGRepresentation(self.selectedCoverImage, 0.8);
                uploadDataDict = @{@"cover":imageData};
            }

            NSDictionary *info = @{@"title": _titleCell.textField.text,
                                   @"time": _whenCell.currentDate};
            
            [[INUDataManager sharedInstance] requestFromServer:INUServiceCreateEvent params:params info:info uploadData:uploadDataDict onError:^BOOL(ServiceError *error) {
                [self removeSpinner];
                return NO;
            }];
        }
    }
}

- (BOOL)validateUserInput
{
    // trim inputs
    _titleCell.textField.text = [_titleCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _detailsCell.textView.text = [_detailsCell.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!_bookmarkToEdit)
    {
        _nameCell.textField.text = [_nameCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _mailCell.textField.text = [_mailCell.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    // check
    if (   [_titleCell.textField.text length] == 0
        || [_detailsCell.textView.text length] == 0
        || (!_bookmarkToEdit && [_nameCell.textField.text length] == 0)
        || (!_bookmarkToEdit && [_mailCell.textField.text length] == 0) )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill out all fields.", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUEventCreatedNotification)
    {
        Bookmark *bookmark = notification.userInfo[@"bookmark"];

        [self dismissViewControllerAnimated:YES completion:^(void) {
            [[INUDataManager sharedInstance] notifyNewEventViewClosed:bookmark];
        }];
    }
    else if (notification.name == INUEventSavedNotification)
    {
        NSString *filename = notification.userInfo[@"filename"];
        if (filename && ![filename isEqualToString:@""])
        {
            Event *event = [[INUDataManager sharedInstance] getEventById:_bookmarkToEdit.eventId];
            event.cover = filename;
            [[INUDataManager sharedInstance] notifyEventUpdate];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
