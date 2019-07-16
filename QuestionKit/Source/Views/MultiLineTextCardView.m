//
//  MultilineCardView.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#include <objc/message.h>

#import "MultiLineTextCardView.h"

@interface MultiLineTextCardView ()

@property NSDictionary * prompt;

@property UIView * maskingView;

@property UILabel * promptLabel;

@property UIView * parentView;
@property UITextView * textView;

@property (nonatomic, copy) void (^changeAction)(NSString * key, id value);

@end

@implementation MultiLineTextCardView

- (id) initWithPrompt:(NSDictionary *) prompt textView:(UITextView *) textView textParentView:(UIView *) parentView changeAction:(void (^)(NSString * key, id value)) changeAction {
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
        
        if (textView == nil || parentView == nil) {
            textView = [[UITextView alloc] initWithFrame:CGRectZero];
            parentView = textView;
        }

        self.textView = textView;
        self.parentView = parentView;

        self.textView.delegate = self;

        if (self.prompt[@"hint"] != nil && [self.parentView respondsToSelector:@selector(setPlaceholder:)]) {
            typedef void (*set_placeholder)(id, SEL, NSString *);

            set_placeholder setFunction = (set_placeholder) objc_msgSend;
            setFunction(parentView, @selector(setPlaceholder:), [self localizedValue:self.prompt[@"hint"]]);
        }

        [self.maskingView addSubview:self.parentView];

        if ([self.parentView respondsToSelector:@selector(sizeToFit)]) {
            [self.parentView sizeToFit];
        } else {
            [self.textView sizeToFit];
        }
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

    top += ceil(self.parentView.frame.size.height);
    
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
    
    CGFloat top = 10;

    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(frame.size.width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
        
    self.promptLabel.frame = CGRectMake(10, top, textRect.size.width, ceil(textRect.size.height));
    
    top += ceil(textRect.size.height);
    
    top += 10;
    
    CGRect textFrame = self.parentView.frame;
    textFrame.size.width = frame.size.width - 20;
    textFrame.origin.x = 10;
    textFrame.origin.y = top;

    self.parentView.frame = textFrame;
    
    [self.parentView setNeedsDisplay];
    [self.parentView setNeedsLayout];

    top += textFrame.size.height;
    
    top += 10;
    
    self.maskingView.frame = self.bounds;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"TEXT: %@", textView.text);
    
    self.changeAction(self.prompt[@"key"], textView.text);
    
    [self updated];
}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        [self next];

        return NO;
    }

    [self updated];

    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self updated];

    return YES;
}

- (void) didUpdatePosition {
    if ([self position] == [self maxPosition]) {
        self.textView.returnKeyType = UIReturnKeyDone;
    } else {
        self.textView.returnKeyType = UIReturnKeyNext;
    }
}

- (void) focus {
    [self.textView becomeFirstResponder];
    
    [self updated];
}

- (void) initializeValue:(id) value {
    if ([value isKindOfClass:[NSString class]]) {
        self.textView.text = value;
    }
}

@end
