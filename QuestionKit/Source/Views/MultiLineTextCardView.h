//
//  MultilineCardView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PromptView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MultiLineTextCardView : PromptView<UITextViewDelegate>

- (id) initWithPrompt:(NSDictionary *) prompt textView:(UITextView *) textView textParentView:(UIView *) parentView changeAction:(void (^)(NSString * key, id value)) changeAction;
- (CGFloat) heightForWidth:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
