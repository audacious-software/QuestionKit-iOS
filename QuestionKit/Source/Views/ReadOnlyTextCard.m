//
//  ReadOnlyTextCard.m
//  QuestionKit
//
//  Created by Chris Karr on 4/30/19.
//  Copyright © 2019 Audacious Software. All rights reserved.
//

#import "ReadOnlyTextCard.h"

@interface ReadOnlyTextCard ()

@property UIView * maskingView;

@property UILabel * promptLabel;

@end

@implementation ReadOnlyTextCard

- (id) initWithPrompt:(NSDictionary *) prompt {
    if (self = [super initWithFrame:CGRectZero]) {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.prompt = prompt;
        
        self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
        self.maskingView.layer.masksToBounds = NO;
        self.maskingView.layer.cornerRadius = 5;
        self.maskingView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.maskingView];
        
        self.promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.promptLabel.text = [self localizedValue:self.prompt[@"text"]];
        self.promptLabel.numberOfLines = -1;
        self.promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.promptLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [self.maskingView addSubview:self.promptLabel];
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
        
    self.maskingView.frame = self.bounds;
    
    [self setNeedsDisplay];
}

- (void) initializeValue:(id) value {
    // Do nothing.
}

- (void) didUpdatePosition {

}

@end
