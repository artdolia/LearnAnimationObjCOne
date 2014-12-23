//
//  ADViewController.m
//  Lesson21_HW
//
//  Created by A D on 1/6/14.
//  Copyright (c) 2014 AD. All rights reserved.
//

#import "ADViewController.h"

const NSInteger ViewSide = 40;

typedef enum {
    
    ADViewControllerViewTypeCenter          = 1 << 0,
    ADViewControllerViewTypeCorner          = 1 << 1
    
}ADViewControllerViewType;

typedef enum {
    
    ADViewControllerAnimateMaskEasyInOut    = 1 << 2,
    ADViewControllerAnimateMaskEasyIn       = 1 << 3,
    ADViewControllerAnimateMaskEasyOut      = 1 << 4,
    ADViewControllerAnimateMaskLinear       = 1 << 5
    
} ADViewControllerAnimateMask;

@interface ADViewController ()
@property (strong, nonatomic) NSMutableArray *corners;
@property (strong, nonatomic) NSMutableDictionary *cornerColors;
@end

@implementation ADViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *redColor = [UIColor redColor];
    UIColor *yelowColor = [UIColor yellowColor];
    UIColor *greenColor = [UIColor greenColor];
    UIColor *blueColor = [UIColor blueColor];
    
    NSArray *colors = [NSArray arrayWithObjects:redColor, yelowColor, greenColor, blueColor, nil];
    self.corners = [NSMutableArray arrayWithArray:[self createViewCornersArray]];
    
    for (int i = 0; i < 4; i++){
    
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(50, 100+50*i, 40, 40)];
        customView.backgroundColor = [self randomColor];
        customView.tag = ADViewControllerViewTypeCenter | 1 << (i+2); //second part to set the mask for Animation type
        customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self.view addSubview:customView];

        CGRect viewRect;
        viewRect.origin = [[self.corners objectAtIndex:i] CGPointValue];
        viewRect.size = CGSizeMake(ViewSide, ViewSide);
        
        UIView *cornerView = [[UIView alloc] initWithFrame:viewRect];
        cornerView.backgroundColor = [colors objectAtIndex:i];
        cornerView.tag = ADViewControllerViewTypeCorner;
        cornerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:cornerView];

    }
}


- (void) viewDidAppear:(BOOL)animated{
    ;
    [super viewDidAppear:animated];
    

    self.cornerColors = [NSMutableDictionary dictionaryWithDictionary:[self createColorsForCornersInDict]];
    
    NSLog(@"selfCorners = %@", self.cornerColors);
    
    
    
    for(UIView *view in self.view.subviews){
        
        if(view.tag == (ADViewControllerViewTypeCenter | ADViewControllerAnimateMaskEasyInOut)){
            
            [self animateVew:view withOptions:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut];
            
        }else if (view.tag == (ADViewControllerViewTypeCenter | ADViewControllerAnimateMaskEasyIn)){
            
            [self animateVew:view withOptions:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseIn];
            
        }else if(view.tag == (ADViewControllerViewTypeCenter | ADViewControllerAnimateMaskEasyOut)){

            [self animateVew:view withOptions:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseOut];
            
        }else if(view.tag == (ADViewControllerViewTypeCenter | ADViewControllerAnimateMaskLinear)){

            [self animateVew:view withOptions:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear];
        
        }else if(view.tag == ADViewControllerViewTypeCorner){
            
            BOOL clockwise = arc4random()%2;
            
            [self animateCornerView:view withRotation:clockwise andDelaty:1];
            

        }
    }
};

- (void) animateCornerView:(UIView*) view withRotation:(BOOL) clockwise andDelaty:(NSInteger) delay{
    
    [UIView animateWithDuration:3 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        
        CGPoint viewOrigin = CGPointMake(CGRectGetMinX(view.frame), CGRectGetMinY(view.frame));
        
        NSInteger currentIndex = [self.corners indexOfObject:[NSValue valueWithCGPoint:viewOrigin]];
        
        NSInteger nextIndex = [self nextIndexInArray:self.corners afterIndex:currentIndex withRotation:clockwise];
        
        CGPoint nextCorner = [[self.corners objectAtIndex:nextIndex] CGPointValue];
        
        CGPoint destination = CGPointMake(nextCorner.x+ViewSide/2, nextCorner.y +ViewSide/2);
        
        view.center = destination;
        
        //NSLog(@"dest = %@, color = %@", NSStringFromCGPoint(destination), [self.cornerColors objectForKey:[NSValue valueWithCGPoint:nextCorner]]);
        view.backgroundColor = [self.cornerColors objectForKey:[NSValue valueWithCGPoint:nextCorner]];
        
    } completion:^(BOOL finished) {
        CGPoint currentOrigin = CGPointMake(CGRectGetMinX(view.frame), CGRectGetMinY(view.frame));
        [self.cornerColors setObject:view.backgroundColor forKey:[NSValue valueWithCGPoint:currentOrigin]];
        [self animateCornerView:view withRotation:arc4random()%2 andDelaty:0];
    }];
    
    
}




#pragma mark - Animation -

- (void) animateVew:(UIView *) customView withOptions:(NSInteger) optionsMask{
    
    [UIView animateWithDuration:3 delay:1 options:optionsMask animations:^{
        
        customView.center = CGPointMake(CGRectGetMidX(customView.frame)+200,
                                        CGRectGetMidY(customView.frame));
        
        customView.backgroundColor = [self randomColor];
        customView.transform = CGAffineTransformMakeScale(2, 0.5);
        self.view.backgroundColor = [self randomColor];

        
    } completion:^(BOOL finished) {
    }];
    
}


#pragma  mark - colorMethods -

- (UIColor *) randomColor{
    
    CGFloat r = (float)(arc4random()%256)/255;
    CGFloat g = (float)(arc4random()%256)/255;
    CGFloat b = (float)(arc4random()%256)/255;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

- (CGFloat) randomZeroToOne{
    
    return (float)(arc4random()%256)/255;
}



#pragma mark - Rotation -
-(NSInteger) nextIndexInArray:(NSArray *) array afterIndex:(NSInteger) currentIndex withRotation:(BOOL) clockwise{
    
    NSInteger nextIndex;
    
    
    if(currentIndex == [array indexOfObject:[array lastObject]] ){
        
        nextIndex = clockwise ? 0: currentIndex-1;
        
    }else if(currentIndex == [array indexOfObject:[array firstObject]]){
        
        nextIndex = clockwise ? currentIndex+1: [array indexOfObject:[array lastObject]];
        
    }else{
        
        nextIndex = clockwise? currentIndex+1: currentIndex-1;
    }
    
    NSLog(@"curInd = %ld, nextInd = %ld, clockwise %@", (long)currentIndex, (long)nextIndex, clockwise? @"Yes":@"No");
    
    return nextIndex;
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    self.corners = [NSMutableArray arrayWithArray:[self createViewCornersArray]];
    
    
}


- (NSArray *) createViewCornersArray{
    
    CGPoint leftUpCorner = CGPointMake(CGRectGetMinX(self.view.bounds) + ViewSide, CGRectGetMinY(self.view.bounds) + ViewSide);
    CGPoint rightUpCorner = CGPointMake(CGRectGetMaxX(self.view.bounds) - ViewSide*2, CGRectGetMinY(self.view.bounds) + ViewSide);
    CGPoint leftDownCorner = CGPointMake(CGRectGetMinX(self.view.bounds) + ViewSide, CGRectGetMaxY(self.view.bounds) - ViewSide*2);
    CGPoint rightDownCorner = CGPointMake(CGRectGetMaxX(self.view.bounds) - ViewSide*2, CGRectGetMaxY(self.view.bounds) - ViewSide*2);
    
    
    
     NSArray* tempArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:leftUpCorner],
                    [NSValue valueWithCGPoint:rightUpCorner],
                    [NSValue valueWithCGPoint:rightDownCorner],
                    [NSValue valueWithCGPoint: leftDownCorner], nil];
    return tempArray;
}

- (NSDictionary*) createColorsForCornersInDict{
    
    NSMutableArray *colors = [NSMutableArray array];
    
    for(NSValue *value in self.corners){
        
        CGPoint corner = [value CGPointValue];
        
        NSLog(@"corner = %@", NSStringFromCGPoint(corner));
        
        for(UIView *view in self.view.subviews){
            
            CGPoint viewOrigin = CGPointMake(CGRectGetMinX(view.frame), CGRectGetMinY(view.frame));
            
            NSLog(@"viewOrigin = %@", NSStringFromCGPoint(viewOrigin));
            
            if(CGPointEqualToPoint(corner, viewOrigin)){
                
                NSLog(@"color = %@", view.backgroundColor);
                
                [colors addObject:view.backgroundColor];
            }
        }
    }
    
    NSLog(@"colors:%@, corners%@", colors, self.corners);
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjects:colors forKeys:[self corners]];
    return tempDict;
}


@end

