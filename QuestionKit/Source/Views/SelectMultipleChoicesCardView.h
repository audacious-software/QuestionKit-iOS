//
//  SelectMultipleChoicesCardView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

@import UIKit;
@import BEMCheckBox;

#import "PromptView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectMultipleChoicesCardViewDelegate
@optional
- (UIColor *) fillColor;
- (UIColor *) tintColor;
- (UIColor *) checkColor;
@end

@interface SelectMultipleChoicesCardView : PromptView<BEMCheckBoxDelegate>

@property NSObject<SelectMultipleChoicesCardViewDelegate> * delegate;

- (id) initWithPrompt:(NSDictionary *) prompt changeAction:(void (^)(NSString * key, id value)) changeAction;
- (CGFloat) heightForWidth:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
