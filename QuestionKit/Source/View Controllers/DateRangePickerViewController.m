//
//  DateRangePickerViewController.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/7/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "FSCalendar.h"

#import "DateRangePickerViewController.h"


@interface DateRangePickerViewController ()<FSCalendarDelegate, FSCalendarDataSource>

@property ReturnDatesAction returnAction;
@property FSCalendar * calendar;
@property UILabel * instructions;

@property NSMutableArray * selectedDates;

@end

@implementation DateRangePickerViewController

- (id) initWithReturnAction:(ReturnDatesAction) returnAction {
    if (self = [super init]) {
        self.returnAction = returnAction;

        self.selectedDates = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"title_select_incident_date", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_clear"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clear)];
    
    self.view.backgroundColor = [UIColor colorWithWhite:(0xee / 255.0) alpha:1.0];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectZero];

    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    
    self.calendar.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:self.calendar];
    
    self.instructions = [[UILabel alloc] initWithFrame:CGRectZero];
    self.instructions.numberOfLines = -1;
    
    [self.view addSubview:self.instructions];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    
    frame.size.height = floor(frame.size.height / 2);

    CGFloat topInset = self.navigationController.navigationBar.frame.size.height;
    
    if (@available(iOS 11.0, *)) {
        topInset += self.view.safeAreaInsets.top;
    }
    
    frame.origin.y = topInset + 12;

    self.calendar.frame = frame;
    
    [self updateLabel];
}

- (void) updateLabel {
    CGRect frame = self.calendar.frame;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

    NSMutableString * labelValue = [NSMutableString stringWithFormat:NSLocalizedString(@"instructions_select_date_range", nil)];
    
    if (self.selectedDates.count == 0) {
        [labelValue appendString:NSLocalizedString(@"instructions_select_date_range_none_selected", nil)];

        self.returnAction(nil, nil);
    } else if (self.selectedDates.count == 1) {
        [labelValue appendFormat:NSLocalizedString(@"instructions_select_date_range_one_selected", nil), [formatter stringFromDate:self.selectedDates.firstObject]];
        self.returnAction(self.selectedDates.firstObject, self.selectedDates.firstObject);
    } else {
        [labelValue appendFormat:NSLocalizedString(@"instructions_select_date_range_multiple_selected", nil),
         [formatter stringFromDate:self.selectedDates.firstObject],
         [formatter stringFromDate:self.selectedDates.lastObject]];

        self.returnAction(self.selectedDates.firstObject, self.selectedDates.lastObject);
    }

    self.instructions.text = labelValue;
    
    CGFloat top = frame.origin.y + frame.size.height + 16;
    
    CGRect textRect = [self.instructions.text boundingRectWithSize:CGSizeMake(frame.size.width - 32, 1000)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{ NSFontAttributeName: self.instructions.font }
                                                           context:nil];
    
    self.instructions.frame = CGRectMake(16, top, frame.size.width - 32, ceil(textRect.size.height));
    
    [self.calendar reloadData];
}

- (void) setReturnDatesAction:(ReturnDatesAction) action {
    self.returnAction = action;
}

- (void) seedSelectedDate:(NSDate *) date {
    if (date == nil) {
        return;
    }
    
    if ([self.selectedDates containsObject:date] == NO) {
        [self.selectedDates addObject:date];
    }
}

- (void) calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if ([self.selectedDates containsObject:date] == NO) {
        [self.selectedDates addObject:date];
    } else {
        [self.selectedDates removeObject:date];
    }

    [self.selectedDates sortUsingComparator:^NSComparisonResult(NSDate * obj1, NSDate * obj2) {
        return [obj1 compare:obj2];
    }];

    [self updateLabel];
}

- (nullable UIColor *) calendar:(FSCalendar *) calendar appearance:(FSCalendarAppearance *) appearance fillDefaultColorForDate:(NSDate *) date {
    if (self.delegate != nil && self.selectedDates.count > 0) {
        NSCalendar * cal = [NSCalendar currentCalendar];
        
        date = [cal startOfDayForDate:date];
        
        NSDate * beginning = [cal startOfDayForDate:self.selectedDates.firstObject];
        NSDate * end = [cal startOfDayForDate:self.selectedDates.lastObject];
        
        NSTimeInterval dateInterval = date.timeIntervalSince1970;
        NSTimeInterval beginningInterval = beginning.timeIntervalSince1970;
        NSTimeInterval endInterval = end.timeIntervalSince1970;

        if (dateInterval >= beginningInterval && dateInterval <= endInterval) {
            return [self.delegate fillColor];
        }
    }
    
    return [UIColor blueColor];
}

- (nullable UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    if (self.selectedDates.count > 0) {
        NSCalendar * cal = [NSCalendar currentCalendar];
        
        date = [cal startOfDayForDate:date];
        
        NSDate * beginning = [cal startOfDayForDate:self.selectedDates.firstObject];
        NSDate * end = [cal startOfDayForDate:self.selectedDates.lastObject];
        
        NSTimeInterval dateInterval = date.timeIntervalSince1970;
        NSTimeInterval beginningInterval = beginning.timeIntervalSince1970;
        NSTimeInterval endInterval = end.timeIntervalSince1970;
        
        if (dateInterval >= beginningInterval && dateInterval <= endInterval) {
            return [UIColor whiteColor];
        }
    }
    
    return nil;
}

- (void) calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    calendar.frame = (CGRect) { calendar.frame.origin, bounds.size };
}

- (void) clear {
    [self.selectedDates removeAllObjects];
    
    [self updateLabel];
}

- (NSInteger) calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    if ([self.selectedDates containsObject:date] == NO) {
        return 0;
    }
    
    return 1;
}

- (NSDate *) maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate date];
}

@end

