//
//  SurveyViewController.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "QuestionsViewController.h"

#import "DateRangePickerViewController.h"

#import "PromptView.h"
#import "SelectOneCardView.h"
#import "MultiLineTextCardView.h"
#import "SingleLineTextCardView.h"
#import "DateRangeCardView.h"
#import "SelectMultipleChoicesCardView.h"
#import "ReadOnlyTextCard.h"

#define CARD_ITEM @"SurveyViewController.CARD_ITEM"

@interface QuestionsViewController()

@property NSDictionary * questions;
@property NSArray * activePrompts;
@property NSMutableArray * activePromptViews;
@property NSMutableDictionary * allPromptViews;

@property NSInteger selectedItem;

@property NSMutableDictionary * currentAnswers;

@end

@implementation QuestionsViewController

- (id) init {
    NSData * data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SampleReport"
                                                                                   ofType:@"json"]];
    
    NSError * error = nil;
    
    NSDictionary * questions = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:&error];
    if (error != nil) {
        NSLog(@"ERROR: %@", error);
    }

    if (self = [self initWithQuestions:questions]) {

    }
    
    return self;
}

#pragma mark - View controller methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.questionsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.questionsTable.allowsSelection = NO;
    self.questionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.questionsTable.delegate = self;
    self.questionsTable.dataSource = self;
    self.questionsTable.backgroundColor = [UIColor colorWithWhite:(0xe0 / 255.0) alpha:1.0];
    self.questionsTable.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubview:self.questionsTable];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
        id _obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect _keyboardFrame = CGRectNull;
        if ([_obj respondsToSelector:@selector(getValue:)]) [_obj getValue:&_keyboardFrame];
                                                      [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                                          
                                                          UIEdgeInsets insets = self.questionsTable.contentInset;
                                                          insets.bottom = _keyboardFrame.size.height;
                                                          self.questionsTable.contentInset = insets;
                                                          
                                                          [self.questionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem
                                                                                                                      inSection:0]
                                                                                  atScrollPosition:UITableViewScrollPositionTop
                                                                                          animated:YES];
                                                      } completion:nil];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{

                                                          UIEdgeInsets insets = self.questionsTable.contentInset;
                                                          insets.bottom = 0;
                                                          self.questionsTable.contentInset = insets;

                                                          [self.questionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem
                                                                                                                      inSection:0]
                                                                                  atScrollPosition:UITableViewScrollPositionTop
                                                                                          animated:YES];
                                                      } completion:nil];
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.questionsTable.frame = self.view.bounds;
    
    CGFloat bottomInset = 0;
    
    if (@available(iOS 11.0, *)) {
        bottomInset = self.view.safeAreaInsets.bottom;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activePrompts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CARD_ITEM];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CARD_ITEM];
        
        cell.contentView.backgroundColor = tableView.backgroundColor;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray * children = cell.contentView.subviews;
    
    for (UIView * child in children) {
        [child removeFromSuperview];
    }
    
    PromptView * card = self.activePromptViews[indexPath.row];
    
    [card setFrame:CGRectMake(10, 10, tableView.frame.size.width - 20, [self tableView:tableView
                                                               heightForRowAtIndexPath:indexPath])];
    
    [cell.contentView addSubview:card];
    
    [card setPosition:indexPath.row];
    [card setMaxPosition:([self activePrompts].count - 1)];
    
    [card setNextAction:^{
        [self reloadData];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self scrollAndFocusItem:(indexPath.row + 1)];
        });
    }];
    
    [card setUpdatedAction:^(NSInteger indexUpdated) {
        self.selectedItem = indexUpdated;
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self.activePromptViews[indexPath.row] heightForWidth:(tableView.frame.size.width - 20)] + 15;
    
    NSLog(@"HEIGHT FOR %@: %f", indexPath, height);
    
    return height;
}

- (void) scrollAndFocusItem:(NSInteger) itemIndex {
    if (itemIndex < self.activePromptViews.count) {
        [self.questionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:itemIndex inSection:0]
                                atScrollPosition:UITableViewScrollPositionTop
                                        animated:YES];
        
        PromptView * card = self.activePromptViews[itemIndex];
        
        if (card != nil) {
            [card focus];
        }
    }
}

#pragma mark - Survey methods

- (void) reloadData {
    self.activePrompts = [self fetchActivePrompts];
    
    NSArray * oldActivePrompts = [NSArray arrayWithArray:self.activePromptViews];
    
    [self.activePromptViews removeAllObjects];
    
    for (NSDictionary * prompt in self.activePrompts) {
        if ([@"select-one" isEqualToString:prompt[@"prompt-type"]]) {
            SelectOneCardView * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                card = [[SelectOneCardView alloc] initWithPrompt:prompt changeAction:^(NSString * key, id value) {
                    [self updateValue:value forKey:key];
                    
                    [self reloadData];
                }];
                
                self.allPromptViews[prompt[@"key"]] = card;
                
                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        } else if ([@"select-multiple" isEqualToString:prompt[@"prompt-type"]]) {
            SelectMultipleChoicesCardView * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                card = [[SelectMultipleChoicesCardView alloc] initWithPrompt:prompt changeAction:^(NSString * key, id value) {
                    [self updateValue:value forKey:key];

                    [self reloadData];
                }];
                
                self.allPromptViews[prompt[@"key"]] = card;

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        } else if ([@"multi-line" isEqualToString:prompt[@"prompt-type"]]) {
            MultiLineTextCardView * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                UITextView * textView = nil;
                UIView * parentView = nil;

                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(newTextViewsForKey:)]) {
                    NSArray * views = [self.delegate newTextViewsForKey:prompt[@"key"]];
                    
                    textView = views.firstObject;
                    parentView = views.lastObject;
                }

                card = [[MultiLineTextCardView alloc] initWithPrompt:prompt
                                                            textView:textView
                                                      textParentView:parentView
                                                        changeAction:^(NSString * key, id value) {
                                                            [self updateValue:value forKey:key];
                                                        }];

                self.allPromptViews[prompt[@"key"]] = card;

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }

            [self.activePromptViews addObject:card];
        } else if ([@"single-line" isEqualToString:prompt[@"prompt-type"]]) {
            SingleLineTextCardView * card = self.allPromptViews[prompt[@"key"]];

            if (card == nil) {
                UITextField * textField = nil;
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(newTextFieldForKey:)]) {
                    textField = [self.delegate newTextFieldForKey:prompt[@"key"]];
                }

                card = [[SingleLineTextCardView alloc] initWithPrompt:prompt
                                                            textField:textField
                                                         changeAction:^(NSString * _Nonnull key, id  _Nonnull value) {
                                                             [self updateValue:value forKey:key];
                                                         }];
                
                self.allPromptViews[prompt[@"key"]] = card;

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        } else if ([@"date-range" isEqualToString:prompt[@"prompt-type"]]) {
            DateRangeCardView * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                UITextField * textField = nil;
                
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(newTextFieldForKey:)]) {
                    textField = [self.delegate newTextFieldForKey:prompt[@"key"]];
                }
                
                card = [[DateRangeCardView alloc] initWithPrompt:prompt
                                                       textField:textField
                                                    changeAction:^(NSString * key, id value) {
                                                        [self updateValue:value forKey:key];
                                                    }];
                
                self.allPromptViews[prompt[@"key"]] = card;
                
                [card setDisplayDateRangePicker:^(NSDate * start, NSDate * end, ReturnDatesAction returnDates) {
                    DateRangePickerViewController * picker = [[DateRangePickerViewController alloc] initWithReturnAction:returnDates];
                    [picker seedSelectedDate:start];
                    [picker seedSelectedDate:end];
                    
                    [self.navigationController pushViewController:picker animated:YES];
                }];

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        } else if ([@"read-only-text" isEqualToString:prompt[@"prompt-type"]]) {
            ReadOnlyTextCard * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                card = [[ReadOnlyTextCard alloc] initWithPrompt:prompt];
                
                self.allPromptViews[prompt[@"key"]] = card;

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        } else {
            SelectOneCardView * card = self.allPromptViews[prompt[@"key"]];
            
            if (card == nil) {
                card = [[SelectOneCardView alloc] initWithPrompt:prompt changeAction:^(NSString * key, id value) {
                    [self updateValue:value forKey:key];

                    [self reloadData];
                }];
                
                self.allPromptViews[prompt[@"key"]] = card;

                [card initializeValue:self.currentAnswers[prompt[@"key"]]];
            }
            
            [self.activePromptViews addObject:card];
        }
    }
    
    if ([self.activePromptViews isEqualToArray:oldActivePrompts] == NO) {
        [self.questionsTable reloadData];
        
        if (self.selectedItem >= self.activePrompts.count) {
            self.selectedItem = self.activePrompts.count - 1;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 32), dispatch_get_main_queue(), ^{
            [self.questionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedItem
                                                                           inSection:0]
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:NO];
        });
    }

    BOOL isComplete = NO;
    
    for (NSDictionary * action in self.questions[@"completed-actions"]) {
        if ([self isComplete:action]) {
            isComplete = YES;
        }
    }
    
    if (isComplete) {
        [self didCompleteQuestions];
    } else {
        [self didNotCompleteQuestions];
    }
}

- (BOOL) isComplete:(NSDictionary *) action {
    BOOL completed = YES;
    
    for (NSDictionary * constraint in action[@"constraints"]) {
        NSString * key = constraint[@"key"];
        NSString * operation = constraint[@"operator"];
        
        id value = constraint[@"value"];
        
        id answerValue = self.currentAnswers[key];
        
        BOOL customEvaluates = NO;
        
        if (self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(supportsOperation:)] &&
                [self.delegate respondsToSelector:@selector(evaluateValue:withOperation:)]) {
                customEvaluates = [self.delegate supportsOperation:operation];
            }
        }
        
        if (customEvaluates) {
            completed = [self.delegate evaluateValue:value withOperation:operation];
        } else if (answerValue == nil) {
            completed = NO;
        } else if ([@"=" isEqualToString:operation] && [answerValue isEqual:value] == NO) {
            completed = NO;
        } else if ([@"!=" isEqualToString:operation] && [answerValue isEqual:value] == YES) {
            completed = NO;
        } else if ([@"<" isEqualToString:operation]) {
            if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                CGFloat testFloat = [value doubleValue];
                CGFloat answerFloat = [answerValue doubleValue];
                
                if (answerFloat >= testFloat) {
                    completed = NO;
                }
            } else {
                completed = NO;
            }
        } else if ([@"<=" isEqualToString:operation]) {
            if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                CGFloat testFloat = [value doubleValue];
                CGFloat answerFloat = [answerValue doubleValue];
                
                if (answerFloat > testFloat) {
                    completed = NO;
                }
            } else {
                completed = NO;
            }
        } else if ([@">" isEqualToString:operation]) {
            if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                CGFloat testFloat = [value doubleValue];
                CGFloat answerFloat = [answerValue doubleValue];
                
                if (answerFloat <= testFloat) {
                    completed = NO;
                }
            } else {
                completed = NO;
            }
        } else if ([@">=" isEqualToString:operation]) {
            if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                CGFloat testFloat = [value doubleValue];
                CGFloat answerFloat = [answerValue doubleValue];
                
                if (answerFloat < testFloat) {
                    completed = NO;
                }
            } else {
                completed = NO;
            }
        } else if ([@"in" isEqualToString:operation]) {
            if ([answerValue isKindOfClass:[NSString class]]) {
                NSString * stringAnswer = (NSString *) answerValue;
                
                if ([stringAnswer rangeOfString:[value description]].location == NSNotFound) {
                    completed = NO;
                }
            } else if ([answerValue isKindOfClass:[NSArray class]]) {
                NSArray * answerArray = (NSArray *) answerValue;
                
                if ([answerArray indexOfObject:value] == NSNotFound) {
                    completed = NO;
                }
            }
        }
    }
    
    return completed;
}

- (NSArray *) fetchActivePrompts {
    NSMutableArray * prompts = [NSMutableArray array];
    
    for (NSDictionary * prompt in self.questions[@"prompts"]) {
        if ([prompt[@"constraints"] count] == 0) {
            [prompts addObject:prompt];
        } else {
            BOOL matches = YES;
            
            for (NSDictionary * constraint in prompt[@"constraints"]) {
                NSString * key = constraint[@"key"];
                NSString * operation = constraint[@"operator"];
                
                id value = constraint[@"value"];
                
                id answerValue = self.currentAnswers[key];

                if (answerValue == nil) {
                    matches = NO;
                } else if ([@"=" isEqualToString:operation] && [answerValue isEqual:value] == NO) {
                    matches = NO;
                } else if ([@"!=" isEqualToString:operation] && [answerValue isEqual:value] == YES) {
                    matches = NO;
                } else if ([@"<" isEqualToString:operation]) {
                    if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                        CGFloat testFloat = [value doubleValue];
                        CGFloat answerFloat = [answerValue doubleValue];
                        
                        if (answerFloat >= testFloat) {
                            matches = NO;
                        }
                    } else {
                        matches = NO;
                    }
                } else if ([@"<=" isEqualToString:operation]) {
                    if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                        CGFloat testFloat = [value doubleValue];
                        CGFloat answerFloat = [answerValue doubleValue];
                        
                        if (answerFloat > testFloat) {
                            matches = NO;
                        }
                    } else {
                        matches = NO;
                    }
                } else if ([@">" isEqualToString:operation]) {
                    if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                        CGFloat testFloat = [value doubleValue];
                        CGFloat answerFloat = [answerValue doubleValue];
                        
                        if (answerFloat <= testFloat) {
                            matches = NO;
                        }
                    } else {
                        matches = NO;
                    }
                } else if ([@">=" isEqualToString:operation]) {
                    if ([value respondsToSelector:@selector(doubleValue)] && [answerValue respondsToSelector:@selector(doubleValue)]) {
                        CGFloat testFloat = [value doubleValue];
                        CGFloat answerFloat = [answerValue doubleValue];
                        
                        if (answerFloat < testFloat) {
                            matches = NO;
                        }
                    } else {
                        matches = NO;
                    }
                } else if ([@"in" isEqualToString:operation]) {
                    if ([answerValue isKindOfClass:[NSString class]]) {
                        NSString * stringAnswer = (NSString *) answerValue;
                        
                        if ([stringAnswer rangeOfString:[value description]].location == NSNotFound) {
                            matches = NO;
                        }
                    } else if ([answerValue isKindOfClass:[NSArray class]]) {
                        NSArray * answerArray = (NSArray *) answerValue;
                        
                        if ([answerArray indexOfObject:value] == NSNotFound) {
                            matches = NO;
                        }
                    }
                }
            }
            
            if (matches) {
                [prompts addObject:prompt];
            }
        }
    }
    
    return prompts;
}

- (void) didCompleteQuestions {
    if (self.delegate != nil) {
        [self.delegate didCompleteQuestionsWithAnswers:self.currentAnswers];
    }
}

- (void) didNotCompleteQuestions {
    if (self.delegate != nil) {
        [self.delegate didNotCompleteQuestionsWithAnswers:self.currentAnswers];
    }
}

- (void) updateValue:(id) value forKey:(NSString *) key {
    self.currentAnswers[key] = value;
    
    if (self.delegate != nil && [self hash] != [self.delegate hash]) {
        [self.delegate updateValue:value forKey:key];
    }
}

#pragma mark - Methods to override in subclasses

- (id) initWithQuestions:(NSDictionary *) questions {
    if (self = [super init]) {
        self.questions = questions;
        self.activePromptViews = [NSMutableArray array];
        self.allPromptViews = [NSMutableDictionary dictionary];
        
        self.currentAnswers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void) updateAnswers:(NSDictionary *) answers {
    [self.currentAnswers setValuesForKeysWithDictionary:answers];
}

@end
