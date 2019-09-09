//
//  SelectYearCardView.m
//  QuestionKit
//
//  Created by Chris Karr on 12/20/18.
//  Copyright © 2018 Audacious Software. All rights reserved.
//

#import "SelectYearCardView.h"

@implementation SelectYearCardView

- (id) initWithPrompt:(NSDictionary *) prompt textField:(UITextField *) textField changeAction:(void (^)(NSString * key, id value)) changeAction {
    if (self = [super initWithPrompt:prompt textField:textField changeAction:changeAction]) {
        textField.keyboardType = UIKeyboardTypeNumberPad;

        UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 410, 320, 44)];
        [toolbar sizeToFit];
        
        UIBarButtonItem * spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem * done = [[UIBarButtonItem alloc] initWithTitle:[self localizedStringForKey:@"action_done_keyboard"]
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(textDone)];

        [toolbar setItems:@[spacer, done]];
        
        textField.inputAccessoryView = toolbar;
    }
    
    return self;
}

- (void) textDone {
    [self.textField resignFirstResponder];

    NSString * entered = self.textField.text;

    if (entered.length == 0) {
        return;
    }

    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];

    if ([formatter numberFromString:entered] != nil) {
        NSInteger min = NSIntegerMin;
        NSInteger max = NSIntegerMax;
        
        NSString * constraintMethod = self.prompt[@"constraint-method"];
        
        if (constraintMethod != nil) {
            NSNumber * minimum = self.prompt[@"constraint-minimum"];
            
            if (minimum != nil) {
                min = minimum.integerValue;
            }
            
            NSNumber * maximum = self.prompt[@"constraint-maximum"];
            
            if (maximum != nil) {
                max = maximum.integerValue;
            }
            
            if ([@"ago" isEqualToString:constraintMethod]) {
                NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
                
                NSInteger currentYear = components.year;
                
                min = currentYear - min;
                max = currentYear - max;
            } else if ([@"absolute" isEqualToString:constraintMethod]) {
                // Do nothing - min and max already set...
            }
            
            if (entered.integerValue < min || entered.integerValue > max) {
                UIAlertController * prompt = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"title_invalid_year"]
                                                                                 message:[NSString stringWithFormat:[self localizedStringForKey:@"message_invalid_year_range"], (int) min, (int) max]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"button_close"]
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          self.textField.text = @"";
                                                                          
                                                                          [self.textField becomeFirstResponder];
                                                                      }];
                [prompt addAction:defaultAction];
                
                if (self.promptDelegate != nil) {
                    [self.promptDelegate presentAlert:prompt];
                }
            }
        }
    } else {
        UIAlertController * prompt = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"title_invalid_year"]
                                                                         message:[NSString stringWithFormat:[self localizedStringForKey:@"message_invalid_year"], entered]
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"button_close"]
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {

                                                              }];
        [prompt addAction:defaultAction];
        
        if (self.promptDelegate != nil) {
            [self.promptDelegate presentAlert:prompt];
        }
    }
}

@end
