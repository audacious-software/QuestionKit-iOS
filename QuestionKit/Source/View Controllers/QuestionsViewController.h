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
- (void) didNotCompleteQuestionsWithAnswers:(NSDictionary *) answers;
@optional
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

@interface QuestionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, QuestionsViewControllerDelegate>

@property UITableView * questionsTable;

- (id) initWithQuestions:(NSDictionary *) questions;
- (id) initWithQuestionsResource:(NSString *) jsonResource;

- (void) reloadData;

@property NSObject<QuestionsViewControllerDelegate> * delegate;
@property NSDictionary * questions;

@end

NS_ASSUME_NONNULL_END
