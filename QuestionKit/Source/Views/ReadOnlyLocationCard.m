//
//  ReadOnlyLocationCard.m
//  QuestionKit
//
//  Created by Chris Karr on 11/20/19.
//  Copyright © 2019 Audacious Software. All rights reserved.
//

@import MapKit;

#import "ReadOnlyLocationCard.h"

@interface ReadOnlyLocationCard ()<MKMapViewDelegate>

@property UIView * maskingView;
@property MKMapView * mapView;
@property NSMutableArray * annotations;

@property UILabel * promptLabel;

@end

@implementation ReadOnlyLocationCard

- (id) initWithPrompt:(NSDictionary *) prompt {
    if (self = [super initWithFrame:CGRectZero]) {
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.prompt = prompt;
        
        self.maskingView = [[UIView alloc] initWithFrame:CGRectZero];
        self.maskingView.layer.masksToBounds = NO;
        self.maskingView.layer.cornerRadius = 5;
        self.maskingView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.maskingView];
        
        self.promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.promptLabel.text = [self localizedValue:self.prompt[@"text"]];
        self.promptLabel.numberOfLines = -1;
        self.promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.promptLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [self.maskingView addSubview:self.promptLabel];
        
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
       
        self.annotations = [NSMutableArray array];

        for (NSDictionary * point in self.prompt[@"points"]) {
            NSNumber * latitude = point[@"latitude"];
            NSNumber * longitude = point[@"longitude"];
            
            MKPointAnnotation * annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue)];
            
            [self.annotations addObject:annotation];
        }
        
        self.mapView.mapType = MKMapTypeHybrid;
        self.mapView.zoomEnabled = YES;
        self.mapView.scrollEnabled = NO;
        self.mapView.pitchEnabled = NO;
        self.mapView.rotateEnabled = NO;
        self.mapView.delegate = self;
        
        [self.maskingView addSubview:self.mapView];
    }
    
    return self;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation { //!OCLint
    MKPinAnnotationView * pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:@""];

    return pin;
}

- (CGFloat) heightForWidth:(CGFloat) width {
    CGFloat top = 10;
    
    CGFloat height = (3 * (width - 20)) / 4;
    
    top += height + 20;
    
    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
    
    top += ceil(textRect.size.height);
    
    top += 10;
    
    return top;
}

- (void) setFrame:(CGRect)frame {
    if (frame.size.height == 0 && frame.size.width == 0) {
        [super setFrame:frame];
        
        return;
    }
    
    CGFloat height = [self heightForWidth:frame.size.width];
    
    frame.size.height = height;
    
    [super setFrame:frame];
    
    CGFloat mapHeight = (3 * (frame.size.width - 20)) / 4;
    
    self.mapView.frame = CGRectMake(10, 10, frame.size.width - 20, mapHeight);
    [self bringSubviewToFront:self.mapView];

    CGFloat minLatitude = 90;
    CGFloat maxLatitude = -90;
    CGFloat minLongitude = 180;
    CGFloat maxLongitude = -180;

    for (id<MKAnnotation> annotation in self.annotations) {
        CGFloat latitude = annotation.coordinate.latitude;
        CGFloat longitude = annotation.coordinate.longitude;

        if (latitude < minLatitude) {
            minLatitude = latitude;
        }

        if (latitude > maxLatitude) {
            maxLatitude = latitude;
        }

        if (longitude < minLongitude) {
            minLongitude = longitude;
        }

        if (longitude > maxLongitude) {
            maxLongitude = longitude;
        }
    }
    
    [self.mapView addAnnotations:self.annotations];
    
    if (minLatitude == maxLatitude) {
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(minLatitude, minLongitude);

        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);

        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        
        [self.mapView setRegion:region animated:NO];
    } else {
        MKCoordinateSpan span = MKCoordinateSpanMake(maxLatitude - minLatitude, maxLongitude - minLongitude);
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(minLatitude + ((span.latitudeDelta) / 2), minLongitude + ((span.longitudeDelta) / 2));
        
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);

        [self.mapView setRegion:region animated:NO];
    }
    
    CGRect textRect = [self.promptLabel.text boundingRectWithSize:CGSizeMake(frame.size.width - 20, 1000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{ NSFontAttributeName: self.promptLabel.font }
                                                          context:nil];
    
    CGFloat top = mapHeight + 20;
    
    self.promptLabel.frame = CGRectMake(10, top, textRect.size.width, ceil(textRect.size.height));
    
    top += ceil(textRect.size.height);
    
    top += 10;
        
    self.maskingView.frame = self.bounds;
    
    [self setNeedsDisplay];
}

- (void) initializeValue:(id) value {
    // Do nothing.
}

- (void) didUpdatePosition {

}

@end
