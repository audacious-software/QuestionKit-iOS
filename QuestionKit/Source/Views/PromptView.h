//
//  PromptView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/7/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PromptView : UIView

- (void) setPosition:(NSInteger) position;
- (void) setMaxPosition:(NSInteger) maxPosition;

- (NSInteger) position;
- (NSInteger) maxPosition;

- (void) focus;

- (void) setNextAction:(void (^)(void)) nextAction;
- (void) setUpdatedAction:(void (^)(NSInteger indexUpdated)) updateAction;

- (void) next;
- (void) updated;

- (id) localizedValue:(NSDictionary *) values;

- (void) initializeValue:(id) value;

@end

NS_ASSUME_NONNULL_END
