//
//  DateRangeCardView.h
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SingleLineTextCardView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ReturnDatesAction)(NSDate * _Nullable start, NSDate * _Nullable end);
typedef void (^ShowDatePickerAction)(NSDate * _Nullable start, NSDate * _Nullable end, ReturnDatesAction);

@interface DateRangeCardView : SingleLineTextCardView

- (void) setDisplayDateRangePicker:(ShowDatePickerAction) showAction;

@end

NS_ASSUME_NONNULL_END
