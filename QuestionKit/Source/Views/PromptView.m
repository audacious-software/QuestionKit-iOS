//
//  PromptView.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/7/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "PromptView.h"

@interface PromptView()

@property NSInteger itemPosition;
@property NSInteger maxItemPosition;

@property (nonatomic, copy) void (^doNextAction)(void);
@property (nonatomic, copy) void (^doUpdatedAction)(NSInteger);

@end


@implementation PromptView

- (void) didUpdatePosition {
    NSLog(@"IMPLEMENT didUpdatePosition IN SUBCLASSES: %@", self.class);
}

- (void) setPosition:(NSInteger) position {
    self.itemPosition = position;
    
    [self didUpdatePosition];
}

- (void) setMaxPosition:(NSInteger) maxPosition {
    self.maxItemPosition = maxPosition;

    [self didUpdatePosition];
}

- (NSInteger) position {
    return self.itemPosition;
}

- (NSInteger) maxPosition {
    return self.maxItemPosition;
}

- (void) focus {
    NSLog(@"IMPLEMENT focus IN SUBCLASSES: %@", self.class);
}

- (void) setNextAction:(void (^)(void)) nextAction {
    self.doNextAction = nextAction;
}

- (void) next {
    if (self.doNextAction != nil) {
        self.doNextAction();
    } else {
        NSLog(@"NO NEXT ACTION");
    }
}

- (void) setUpdatedAction:(void (^)(NSInteger)) updateAction {
    self.doUpdatedAction = updateAction;
}

- (void) updated {
    if (self.doUpdatedAction != nil) {
        self.doUpdatedAction(self.itemPosition);
    } else {
        NSLog(@"NO UPDATE ACTION");
    }
}

- (id) localizedValue:(NSDictionary *) values {
    for (NSString * language in [NSLocale preferredLanguages]) {
        NSString * shortLanguage = [language substringWithRange:NSMakeRange(0, 2)];
        
        id value = values[shortLanguage];
        
        if (value != nil) {
            return value;
        }
    }
    
    return values.description;
}

- (void) initializeValue:(id) value {
    NSLog(@"IMPLEMENT IN SUBCLASS: %@.initializeValue", [self class]);
}

@end
