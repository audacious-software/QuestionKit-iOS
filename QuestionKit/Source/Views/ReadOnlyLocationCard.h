//
//  ReadOnlyLocationCard.h
//  QuestionKit
//
//  Created by Chris Karr on 11/20/19.
//  Copyright © 2019 Audacious Software. All rights reserved.
//

@import UIKit;

#import "PromptView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReadOnlyLocationCard : PromptView

@property NSDictionary * prompt;

- (id) initWithPrompt:(NSDictionary *) prompt;
- (CGFloat) heightForWidth:(CGFloat) width;

@end

NS_ASSUME_NONNULL_END
