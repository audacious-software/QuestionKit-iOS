//
//  SelectTimeCard.m
//  QuestionKit
//
//  Created by Chris Karr on 11/17/19.
//  Copyright © 2019 Audacious Software. All rights reserved.
//

#import "SelectTimeCard.h"

@interface SelectTimeCard ()

@property NSString * selectedTime;

@end

@implementation SelectTimeCard

- (id) initWithPrompt:(NSDictionary *) prompt textField:(UITextField *) textField changeAction:(void (^)(NSString * key, id value)) changeAction {
    if (self = [super initWithPrompt:prompt textField:textField changeAction:changeAction]) {
        UIDatePicker * picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeTime;
        self.textField.inputView = picker;

        [picker addTarget:self
                   action:@selector(updateSelectedTime:)
         forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (void) updateSelectedTime:(UIDatePicker *) sender {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    self.textField.text = [formatter stringFromDate:sender.date];
    
    NSDateFormatter * valueFormatter = [[NSDateFormatter alloc] init];
    valueFormatter.dateFormat = @"HH:mm";
    
    self.selectedTime = [valueFormatter stringFromDate:sender.date];

    self.changeAction(self.prompt[@"key"], self.selectedTime);
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) text {
    return YES;
}

- (void) didUpdatePosition {

}

- (void) focus {
    [self.textField becomeFirstResponder];

    [self updated];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *) textField {
    [self updated];
    
    return YES;
}

- (void) initializeValue:(id) value {
    if ([value isKindOfClass:[NSString class]]) {
        NSDateFormatter * valueFormatter = [[NSDateFormatter alloc] init];
        valueFormatter.dateFormat = @"HH:mm";
        
        NSDate * selectedDate = [valueFormatter dateFromString:value];
        
        if (selectedDate != nil) {
            self.selectedTime = [valueFormatter stringFromDate:selectedDate];
            
            UIDatePicker * picker = (UIDatePicker *) self.textField.inputView;
            
            if (picker != nil) {
                picker.date = selectedDate;
                
                [self updateSelectedTime:picker];
            }
        }
    }
}

@end
