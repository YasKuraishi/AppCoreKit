//
//  CKFlexibleGridLayout.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKLayoutManager.h"

@class CKLayoutView;
@interface CKFlexibleGridLayout : NSObject <CKLayoutManager>

////Layout Manager
@property (nonatomic, assign) CKLayoutView *layoutView;
@property (nonatomic, assign) UIEdgeInsets inset;
- (void)layout;

@property (nonatomic, readonly) CGSize preferedSize;
@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

////Grid
@property (nonatomic, assign) CGSize gridSize;
@property (nonatomic, assign) CGFloat minMarginSize;
@property (nonatomic, assign) BOOL changeSubviewSize;

+ (CKFlexibleGridLayout*)horizontalGridLayout;
+ (CKFlexibleGridLayout*)verticalGridLayout;
+ (CKFlexibleGridLayout*)gridLayoutWithGridSize:(CGSize)aGridSize;

@end
