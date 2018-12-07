//
//  SingleLineTextCardView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PromptView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SingleLineTextCardView : PromptView<UITextFieldDelegate>

@property NSDictionary * prompt;
@property UITextField * textField;
@property (nonatomic, copy) void (^changeAction)(NSString * key, id value);

- (id) initWithPrompt:(NSDictionary *) prompt textField:(UITextField *) textField changeAction:(void (^)(NSString * key, id value)) changeAction;
- (CGFloat) heightForWidth:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
