//
//  CKItemViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKCallback.h"

enum{
	CKItemViewFlagNone = 1UL << 0,
	CKItemViewFlagSelectable = 1UL << 1,
	CKItemViewFlagEditable = 1UL << 2,
	CKItemViewFlagRemovable = 1UL << 3,
	CKItemViewFlagMovable = 1UL << 4,
	CKItemViewFlagAll = CKItemViewFlagSelectable | CKItemViewFlagEditable | CKItemViewFlagRemovable | CKItemViewFlagMovable
};
typedef NSUInteger CKItemViewFlags;

@interface CKItemViewController : NSObject {
	NSString *_name;
	id _value;
	id _target;
	SEL _action;
	SEL _accessoryAction;
	
	NSIndexPath *_indexPath;
	UIViewController* _parentController;
	
	CKCallback* _initCallback;
	CKCallback* _setupCallback;
	CKCallback* _selectionCallback;
	CKCallback* _accessorySelectionCallback;
	CKCallback* _becomeFirstResponderCallback;
	CKCallback* _resignFirstResponderCallback;
	
	UIView* _view;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) id value;
@property (nonatomic, retain, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) UIViewController* parentController;
@property (nonatomic, assign) UIView *view;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) SEL accessoryAction;

@property (nonatomic, retain) CKCallback* initCallback;
@property (nonatomic, retain) CKCallback* setupCallback;
@property (nonatomic, retain) CKCallback* selectionCallback;
@property (nonatomic, retain) CKCallback* accessorySelectionCallback;
@property (nonatomic, retain) CKCallback* becomeFirstResponderCallback;
@property (nonatomic, retain) CKCallback* resignFirstResponderCallback;

- (NSString*)identifier;

- (UIView *)loadView;
- (void)setupView:(UIView *)view;
- (void)rotateView:(UIView*)view withParams:(NSDictionary*)params animated:(BOOL)animated;

- (void)applyStyle;

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params;

- (void)viewDidAppear:(UIView *)view;
- (void)viewDidDisappear;

- (NSIndexPath *)willSelect;
- (void)didSelect;
- (void)didSelectAccessoryView;

- (void)initView:(UIView*)view;
- (void)didBecomeFirstResponder;
- (void)didResignFirstResponder;

@end
