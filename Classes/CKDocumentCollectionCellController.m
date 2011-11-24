//
//  CKDocumentCollectionViewCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentCollectionCellController.h"
#import "CKFeedSource.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKObjectCarouselViewController.h"
#import "CKDocumentCollection.h"
#import "CKDocumentCollectionViewCellController+Style.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKTableViewCellController+Style.h"

#import "CKStyleManager.h"

#define ACTIVITY_INDICATOR_TAG 98634
#define LABEL_TAG 938459837

@interface CKDocumentCollectionViewCellController()
@property (nonatomic,retain,readwrite) UILabel* label;
@property (nonatomic,retain,readwrite) UIActivityIndicatorView* activityIndicator;
@end

@implementation CKDocumentCollectionViewCellController
@synthesize label = _label;
@synthesize activityIndicator = _activityIndicator;

- (void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[_label release];
	[_activityIndicator release];
	[super dealloc];
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	UIView* view = [[[UIView alloc] initWithFrame:cell.contentView.bounds] autorelease];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	NSMutableDictionary* theStyle = [self controllerStyle];
	
	
	self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:theStyle.indicatorStyle] autorelease];
	_activityIndicator.center = cell.center;
	_activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _activityIndicator.tag = ACTIVITY_INDICATOR_TAG;
	_activityIndicator.hidden = YES;
	
	[view addSubview:_activityIndicator];
	
	self.label = [[[UILabel alloc] initWithFrame:CGRectInset(view.bounds,10,0)] autorelease];
	_label.textAlignment = UITextAlignmentCenter;
	_label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.tag = LABEL_TAG;
	[view addSubview:_label];
	
	[cell.contentView addSubview:view];
}

//FIXME : UGLY TEMPORARY HACK
- (BOOL)forceHidden{
	if([self.parentController isKindOfClass:[CKObjectCarouselViewController class]])
		return YES;
	else if([self.parentController isKindOfClass:[CKTableViewController class]]){
		CKTableViewController* tableViewController = (CKTableViewController*)self.parentController ;
		return tableViewController.tableView.pagingEnabled;
	}
	return NO;
}

- (void)update:(UIView*)view{
	if(view == nil)
		return;
	
	CKDocumentCollection* collection = (CKDocumentCollection*)self.value;
	CKFeedSource* source = collection.feedSource;
	
	_activityIndicator.hidden = [self forceHidden] || !source.isFetching || !source.hasMore || view.frame.size.width <= 0 || view.frame.size.height <= 0;
	if(!_activityIndicator.hidden){
		[_activityIndicator startAnimating];
	}
	else{
		[_activityIndicator stopAnimating];
	}
	
	NSMutableDictionary* theStyle = [self controllerStyle];
	
	_label.hidden = !_activityIndicator.hidden;	
	switch([collection count]){
		case 0:{
			_label.text = _(theStyle.noItemsMessage);
			break;
		}
		case 1:{
			_label.text = _(theStyle.oneItemMessage);
			break;
		}
		default:{
			_label.text = [NSString stringWithFormat:_(theStyle.manyItemsMessage),[collection count]];
			break;
		}
	}
}

- (void)internalUpdate:(id)value{
	[self update:self.tableViewCell];
}
- (void)internalUpdateWithNotification:(NSNotification*)notification{
	if([notification documentCollection] == self.value){
		[self update:self.tableViewCell];
	}
}

- (UITableViewCell*)loadCell{
	return [super loadCell];
}

- (void)setupCell:(UITableViewCell *)cell{
    //In case of reuse
    self.label = (UILabel*)[cell.contentView viewWithTag:LABEL_TAG];
    self.activityIndicator = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ACTIVITY_INDICATOR_TAG];
    
	[super setupCell:cell];
	
	CKDocumentCollection* collection = (CKDocumentCollection*)self.value;
	CKFeedSource* source = collection.feedSource;
	
	[self update:cell.contentView];
	
	_activityIndicator.hidden = _activityIndicator.hidden || [self forceHidden];
	
	//TODO REGISTER ON NOTIF TO KNOW IF THE COLLECTION IS UPDATED !!!
	
	[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self] policy:CKBindingsContextPolicyRemovePreviousBindings];
	[source bind:@"isFetching" target:self action:@selector(internalUpdate:)];
	[source bind:@"hasMore" target:self action:@selector(internalUpdate:)];
	[source bind:@"currentIndex" target:self action:@selector(internalUpdate:)];
	[[NSNotificationCenter defaultCenter] bindNotificationName:CKEditionObjectAddedNotification target:self action:@selector(internalUpdateWithNotification:)];
	[[NSNotificationCenter defaultCenter] bindNotificationName:CKEditionObjectRemovedNotification target:self action:@selector(internalUpdateWithNotification:)];
	[NSObject endBindingsContext];
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	if([params pagingEnabled])
		return [NSValue valueWithCGSize:CGSizeMake(-1,-1)];
	return [NSValue valueWithCGSize:CGSizeMake(320,44)];
}


+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}

@end
