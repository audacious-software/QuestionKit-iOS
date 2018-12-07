//
//  SelectOneCardView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BEMCheckBox.h"

#import "PromptView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SelectOneCardViewDelegate
@optional
- (UIColor *) fillColor;
- (UIColor *) tintColor;
- (UIColor *) checkColor;
@end

@interface SelectOneCardView : PromptView<BEMCheckBoxDelegate>

@property NSObject<SelectOneCardViewDelegate> * delegate;

- (id) initWithPrompt:(NSDictionary *) prompt changeAction:(void (^)(NSString * key, id value)) changeAction;
- (CGFloat) heightForWidth:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
