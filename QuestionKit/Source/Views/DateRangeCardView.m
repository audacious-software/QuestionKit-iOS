//
//  DateRangeCardView.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "DateRangeCardView.h"

@interface DateRangeCardView ()

@property (nonatomic, copy) ShowDatePickerAction showDateRangePicker;

@property NSDate * startDate;
@property NSDate * endDate;

@end

@implementation DateRangeCardView

- (void) setDisplayDateRangePicker:(ShowDatePickerAction) showAction {
    self.showDateRangePicker = showAction;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *) textField {
    [super textFieldShouldBeginEditing:textField];
 
    if (self.showDateRangePicker != nil) {
        self.showDateRangePicker(self.startDate, self.endDate, ^(NSDate * _Nonnull startDate, NSDate * _Nonnull endDate) {
            self.startDate = startDate;
            self.endDate = endDate;
            
            if (startDate == nil) {
                self.textField.text = nil;
                self.changeAction(self.prompt[@"key"], @[]);
            } else {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterMediumStyle;
                formatter.timeStyle = NSDateFormatterNoStyle;
                
                NSString * startString = [formatter stringFromDate:startDate];
                
                if ([startDate isEqualToDate:endDate]) {
                    self.textField.text = startString;
                    self.changeAction(self.prompt[@"key"], @[startDate]);
                } else {
                    NSString * endString = [formatter stringFromDate:endDate];
                    self.textField.text = [NSString stringWithFormat:NSLocalizedString(@"date_range", nil), startString, endString];

                    self.changeAction(self.prompt[@"key"], @[startDate, endDate]);
                }
            }
        });
    }

    return NO;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) text {
    NSLog(@"REJECTING CHANGE: %@", text);
    
    return NO;
}

@end
