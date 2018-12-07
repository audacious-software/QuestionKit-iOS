//
//  PhotoCard.m
//  Enviromonitor
//
//  Created by Chris Karr on 11/5/18.
//  Copyright © 2018 CACHET. All rights reserved.
//

#import "PhotoCard.h"

@implementation PhotoCard

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSLog(@"PHOTO FRAME: %@", NSStringFromCGRect(frame));
        
        self.contentView.backgroundColor = [UIColor blueColor];
    }
    
    return self;
}

@end
