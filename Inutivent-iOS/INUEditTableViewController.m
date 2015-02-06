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
#import "Contact.h"
#import "UIImage+Utils.h"
#import "UIImageView+WebCache.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    _nameCell.textField.text = [INUDataManager sharedInstance].userContact.name;
    
    _mailCell.textField.placeholder = NSLocalizedString(@"Enter your e-mail address", nil);
    _mailCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _mailCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _mailCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _mailCell.textField.text = [INUDataManager sharedInstance].userContact.mail;
    
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // correct table header size
    CGFloat neededHeight = self.view.frame.size.width * 3 / 8;
    if (neededHeight != self.tableView.tableHeaderView.frame.size.height)
    {
        CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, neededHeight);
        self.tableView.tableHeaderView.frame = newFrame;
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // update default user
    [INUDataManager sharedInstance].userContact.name = _nameCell.textField.text;
    [INUDataManager sharedInstance].userContact.mail = _mailCell.textField.text;
    [[INUDataManager sharedInstance].userContact saveUserDefaults];
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
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                // default image
                self.imageView.image = [UIImage imageNamed:@"default_header.jpg"];
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
        CGFloat height = [_detailsCell requiredCellHeightForWidth:self.tableView.bounds.size.width];
        return MAX(88, height);
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_bookmarkToEdit) ? 3 : 4;
}

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
//    [actionSheet showInView:sender];
    [actionSheet showFromRect:self.titleLabel.frame inView:self.tableView.tableHeaderView animated:YES];
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Gallery
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self showImagePicker:imagePicker];
    }
    else if (buttonIndex == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // Camera
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)showImagePicker:(UIImagePickerController *)imagePicker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:self.titleLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = [self scaledImage:image];
    
    self.imageView.image = image;
    self.selectedCoverImage = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

            _spinnerView = [INUSpinnerView addNewSpinnerToView:self.navigationController.view transparent:YES];

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

            _spinnerView = [INUSpinnerView addNewSpinnerToView:self.navigationController.view transparent:YES];
            
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

#pragma mark - Image Utils

- (UIImage *)scaledImage:(UIImage *)sourceImage
{
    //scale down
    CGFloat scaleX = INUConfigCoverMaxWidth / sourceImage.size.width;
    CGFloat scaleY = INUConfigCoverMaxHeight / sourceImage.size.height;
    CGFloat scale = MAX(scaleX, scaleY);
    
    if (scale < 1.0)
    {
        CGSize size = CGSizeMake(sourceImage.size.width * scale, sourceImage.size.height * scale);
        UIImage *scaledImage = [sourceImage resizedImageWithSize:size];
        return scaledImage;
    }
    return sourceImage;
}

@end
