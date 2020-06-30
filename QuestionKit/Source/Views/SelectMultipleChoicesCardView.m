//
//  SelectMultipleChoicesCardView.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "SelectMultipleChoicesCardView.h"

@interface SelectMultipleChoicesCardView ()

@property NSDictionary * prompt;
@property NSMutableArray * checkBoxes;
@property (nonatomic, copy) void (^changeAction)(NSString * key, id value); //!OCLint

@property UIView * maskingView;

@property UILabel * promptLabel;

@property NSMutableArray * checkBoxLabels;
@property NSMutableArray * checkBoxValues;

@end

@implementation SelectMultipleChoicesCardView

- (id) initWithPrompt:(NSDictionary *) prompt changeAction:(void (^)(NSString * key, id value)) changeAction { //!OCLint
    if (self = [super initWithFrame:CGRectZero]) {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.checkBoxes = [NSMutableArray array];
        self.checkBoxLabels = [NSMutableArray array];
        self.checkBoxValues = [NSMutableArray array];
        
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
        
        for (NSDictionary * option in self.prompt[@"options"]) {
            BEMCheckBox * checkBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            checkBox.boxType = BEMBoxTypeSquare;
            
            checkBox.on = NO;
            
            checkBox.onAnimationType = BEMAnimationTypeFill;
            checkBox.offAnimationType = BEMAnimationTypeFill;
            
            checkBox.delegate = self;
            
            [self.maskingView addSubview:checkBox];
            [self.checkBoxes addObject:checkBox];
            
            UILabel * checkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            checkLabel.text = [self localizedValue:option[@"label"]];
            checkLabel.numberOfLines = -1;
            checkLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            [self.maskingView addSubview:checkLabel];
            
            [self.checkBoxLabels addObject:checkLabel];
            
            [self.checkBoxValues addObject:option[@"value"]];
        }
    }
    
    return self;
}

- (void) didTapCheckBox:(BEMCheckBox *) box {
    NSMutableArray * selectedValues = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < self.checkBoxes.count; i++) {
        BEMCheckBox * checkBox = self.checkBoxes[i];

        if (box == checkBox) {
            [selectedValues removeObject:self.prompt[@"options"][i][@"value"]];
            
            if (box.on) {
                [selectedValues addObject:self.prompt[@"options"][i][@"value"]];
            }
            
            NSNumber * exclusive = self.prompt[@"options"][i][@"exclusive"];
            
            if (exclusive == nil) {
                exclusive = @(NO);
            }
            
            if (exclusive.boolValue && box.on) {
                for (NSUInteger j = 0; j < self.checkBoxes.count; j++) {
                    BEMCheckBox * uncheckBox = self.checkBoxes[j];

                    if (box != uncheckBox) {
                        [selectedValues removeObject:self.prompt[@"options"][i][@"value"]];
                        uncheckBox.on = NO;
                    }
                }
            } else {
                for (NSUInteger j = 0; j < self.checkBoxes.count; j++) {
                    BEMCheckBox * uncheckBox = self.checkBoxes[j];

                    NSNumber * uncheckExclusive = self.prompt[@"options"][j][@"exclusive"];

                    if (uncheckExclusive == nil) {
                        uncheckExclusive = @(NO);
                    }

                    if (box != uncheckBox && uncheckExclusive.boolValue) {
                        [selectedValues removeObject:self.prompt[@"options"][j][@"value"]];
                        uncheckBox.on = NO;
                    }
                }
            }
        } else if (checkBox.on) {
            [selectedValues addObject:self.prompt[@"options"][i][@"value"]];
        }
    }
    
    if (self.changeAction != nil) {
        self.changeAction(self.prompt[@"key"], selectedValues);
    }

    [self updated];
}

- (CGFloat) heightForWidth:(CGFloat) width {
    CGFloat top = 10;
    
    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
    
    top += ceil(textRect.size.height);
    
    for (UILabel * checkLabel in self.checkBoxLabels) {
        top += 10;
        
        textRect = [checkLabel.text boundingRectWithSize:CGSizeMake(width - 74, 1000)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName: checkLabel.font }
                                                 context:nil];
        
        if (textRect.size.height < 44) {
            textRect.size.height = 44;
        }
        
        top += ceil(textRect.size.height);
    }
    
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
    
    for (NSUInteger i = 0; i < self.checkBoxLabels.count; i++) {
        UILabel * checkLabel = self.checkBoxLabels[i];
        
        top += 10;
        
        textRect = [checkLabel.text boundingRectWithSize:CGSizeMake(frame.size.width - 74, 1000)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName: checkLabel.font }
                                                 context:nil];
        
        if (textRect.size.height < 44) {
            textRect.size.height = 44;
        }
        
        checkLabel.frame = CGRectMake(64, top, textRect.size.width, textRect.size.height);
        
        BEMCheckBox * checkBox = self.checkBoxes[i];
        
        checkBox.frame = CGRectMake(10, top, 44, 44);

        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(fillColor)]) {
                checkBox.onFillColor = [((id<SelectMultipleChoicesCardViewDelegate>) self.delegate) fillColor];
            }
            
            if ([self.delegate respondsToSelector:@selector(tintColor)]) {
                checkBox.onTintColor = [((id<SelectMultipleChoicesCardViewDelegate>) self.delegate) tintColor];
                checkBox.tintColor = [((id<SelectMultipleChoicesCardViewDelegate>) self.delegate) tintColor];
            }
            
            if ([self.delegate respondsToSelector:@selector(checkColor)]) {
                checkBox.onCheckColor = [((id<SelectMultipleChoicesCardViewDelegate>) self.delegate) checkColor];
            }
        }

        top += ceil(textRect.size.height);
    }
    
    top += 10;
    
    self.maskingView.frame = self.bounds;
    
    [self setNeedsDisplay];
}

- (void) initializeValue:(id) value {
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray * values = (NSArray *) value;
        
        for (id valueItem in values) {
            NSInteger index = 0;
            
            for (NSDictionary * option in self.prompt[@"options"]) {
                BEMCheckBox * checkBox = self.checkBoxes[index];
                
                if ([option[@"value"] isEqual:valueItem]) {
                    checkBox.on = YES;
                }
                
                index += 1;
            }
        }
    }
}

@end

