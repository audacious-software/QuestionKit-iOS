//
//  DateRangePickerViewController.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/7/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DateRangeCardView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DateRangePickerViewControllerDelegate
- (UIColor *) fillColor;
@optional
- (UIColor *) tintColor;
- (UIColor *) checkColor;
@end


@interface DateRangePickerViewController : UIViewController

@property NSObject<DateRangePickerViewControllerDelegate> * delegate;

- (id) initWithReturnAction:(ReturnDatesAction) returnAction;
- (void) seedSelectedDate:(NSDate *) date;

@end

NS_ASSUME_NONNULL_END
