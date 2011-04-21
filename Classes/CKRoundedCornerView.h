//
//  BackgroundView.h
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-08.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	CKRoundedCornerViewTypeNone = 0,
	CKRoundedCornerViewTypeTop,
	CKRoundedCornerViewTypeBottom,
	CKRoundedCornerViewTypeAll
} CKRoundedCornerViewType;

@interface CKRoundedCornerView : UIView {
	CKRoundedCornerViewType _corners;
	CGSize _roundedCornerSize;
}

@property (nonatomic,assign) CKRoundedCornerViewType corners;
@property (nonatomic,assign) CGSize roundedCornerSize;

@end