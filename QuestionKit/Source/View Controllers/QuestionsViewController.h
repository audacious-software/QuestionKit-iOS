//
//  SurveyViewController.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol QuestionsViewControllerDelegate
- (void) didCompleteQuestionsWithAnswers:(NSDictionary *) answers;
@optional
- (void) didNotCompleteQuestionsWithAnswers:(NSDictionary *) answers;
- (void) updateValue:(id) value forKey:(NSString *) key;
- (BOOL) supportsOperation:(NSString *) operation;
- (BOOL) evaluateValue:(id) value withOperation:(NSString *) operation;
- (UITextField *) newTextFieldForKey:(NSString *) key;
- (NSArray *) newTextViewsForKey:(NSString *) key;
- (NSDictionary *) currentAnswers; // ???
- (void) updateAnswers:(NSDictionary *) answers;

@end

@protocol QuestionsViewControllerDataSource

- (NSDictionary *) questionsDefinition;

@end

@interface QuestionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property UITableView * questionsTable;

- (id) initWithQuestions:(NSDictionary *) questions;

@property NSObject<QuestionsViewControllerDelegate> * delegate;

@end

NS_ASSUME_NONNULL_END
