//
//  SingleLineTextCardView.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "SingleLineTextCardView.h"

@interface SingleLineTextCardView ()

@property UIView * maskingView;

@property UILabel * promptLabel;

@end

@implementation SingleLineTextCardView

- (id) initWithPrompt:(NSDictionary *) prompt textField:(UITextField *) textField changeAction:(void (^)(NSString * key, id value)) changeAction { //!OCLint
    if (self = [super initWithFrame:CGRectZero]) {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.prompt = prompt;
        self.changeAction = changeAction;
        
        self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
        self.maskingView.layer.masksToBounds = NO;
        self.maskingView.layer.cornerRadius = 5;
        self.maskingView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.maskingView];
        
        self.promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.promptLabel.text = [self localizedValue:self.prompt[@"prompt"]];
        self.promptLabel.numberOfLines = -1;
        self.promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.promptLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [self.maskingView addSubview:self.promptLabel];
        
        if (textField == nil) {
            textField = [[UITextField alloc] initWithFrame:CGRectZero]; //!OCLINT
        }
        
        NSDictionary * hint = prompt[@"hint"];
        
        if (hint != nil) {
            textField.placeholder = [self localizedValue:hint];
        }
        
        self.textField = textField;
        
        self.textField.delegate = self;
        
        [self.maskingView addSubview:self.textField];
        
        [self.textField sizeToFit];
    }
    
    return self;
}

- (CGFloat) heightForWidth:(CGFloat) width {
    CGFloat top = 10;
    
    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
    
    top += ceil(textRect.size.height);
    
    top += 10;
    
    top += ceil(self.textField.frame.size.height);
    
    top += 10;
    
    return top;
}

- (void) setFrame:(CGRect)frame {
    if (frame.size.height == 0 && frame.size.width == 0) {
        [super setFrame:frame];
        
        return;
    }
    
    CGFloat height = [self heightForWidth:frame.size.width];
    
    frame.size.height = height;
    
    [super setFrame:frame];
    
    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(frame.size.width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
    
    CGFloat top = 10;
    
    self.promptLabel.frame = CGRectMake(10, top, textRect.size.width, ceil(textRect.size.height));
    
    top += ceil(textRect.size.height);
    
    top += 10;
    
    CGRect textFrame = self.textField.frame;
    textFrame.size.width = frame.size.width - 20;
    textFrame.origin.x = 10;
    textFrame.origin.y = top;
    
    self.textField.frame = textFrame;
    
    self.maskingView.frame = self.bounds;
    
    [self setNeedsDisplay];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) text {
    if ([text isEqualToString:@"\n"]) {
        self.changeAction(self.prompt[@"key"], textField.text);

        [textField resignFirstResponder];

        [self next];

        return NO;
    }

    NSString * newValue = [textField.text stringByReplacingCharactersInRange:range withString:text];

    self.changeAction(self.prompt[@"key"], newValue);

    [self updated];

    return YES;
}

- (void) didUpdatePosition {
    if ([self position] == [self maxPosition]) {
        self.textField.returnKeyType = UIReturnKeyDone;
    } else {
        self.textField.returnKeyType = UIReturnKeyNext;
    }
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
        self.textField.text = value;
    }
}

@end
