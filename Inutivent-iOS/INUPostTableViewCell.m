//
//  INUPostTableViewCell.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUPostTableViewCell.h"
#import "Post.h"
#import "Event.h"
#import "User.h"

@interface INUPostTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;

@end

@implementation INUPostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)post event:(Event *)event
{
    User *user = [event getUserWithId:post.userId];
    
    // name
    NSString *nameString = [NSString stringWithFormat:@"%@: ", user.name];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:nameString attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]}];
    
    // text
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:post.data attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}]];
    
    // date
    NSString *dateString = [NSString stringWithFormat:@"\n%@", [NSDateFormatter localizedStringFromDate:post.created dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:dateString attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor lightGrayColor]}]];
    
    _textView.attributedText = string;
    
    CGSize textViewSize = [_textView sizeThatFits:CGSizeMake([_textView frame].size.width, FLT_MAX)];
    _textHeightConstraint.constant = textViewSize.height;

}

@end
