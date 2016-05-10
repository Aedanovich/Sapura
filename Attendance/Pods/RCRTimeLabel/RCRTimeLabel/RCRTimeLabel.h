//
//  RCRTimeLabel.h
//
//  Created by Rich Robinson on 29/08/2014.
//  Copyright (c) 2014 Rich Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A <tt>UILabel</tt> subclass that simply displays the current date/time and keeps itself up to date.
 */
@interface RCRTimeLabel : UILabel

/**
 The date style of the label. Defaults to <tt>NSDateFormatterNoStyle</tt>.
 */
@property (nonatomic) NSDateFormatterStyle dateStyle;

/**
 The time style of the label. Defaults to <tt>NSDateFormatterShortStyle</tt>.
 */
@property (nonatomic) NSDateFormatterStyle timeStyle;

/**
 Updates the label's text 'now'. Note that there is generally little need to call this method, as the label automatically keeps itself up to date.
 */
- (void)updateText;

@end
