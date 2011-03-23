//
//  CKWebSource.m
//  CloudKit
//
//  Created by Fred Brunel on 11-01-14.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKWebSource.h"
#import "CKDebug.h"
#import "CKAlertView.h"
#import "CKLocalization.h"

NSString* const CKWebSourceErrorNotification = @"CKWebSourceErrorNotification";

@interface CKWebSource ()
@property (nonatomic, retain) CKWebRequest2 *request;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFetching;
@property (nonatomic, assign) NSUInteger currentIndex;
@end

@implementation CKWebSource

@synthesize request = _request;
@synthesize requestBlock = _requestBlock;
@synthesize transformBlock = _transformBlock;
@synthesize failureBlock = _failureBlock;
@dynamic hasMore;
@dynamic isFetching;
@dynamic currentIndex;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc {
	[self cancelFetch];
	[_requestBlock release];
	[_transformBlock release];
	[_failureBlock release];
	[super dealloc];
}

//

- (BOOL)fetchNextItems:(NSUInteger)batchSize {
	if ((self.isFetching == YES) || (self.hasMore == NO)
		|| (_limit > 0 && self.currentIndex >= _limit) ) 
		return NO;
	
	_requestedBatchSize = batchSize;
	self.request = _requestBlock(NSMakeRange(self.currentIndex, batchSize));
	//[_requestBlock release];
	
	if (self.request) {
		self.request.delegate = self;
		[self.request startAsynchronous];
		self.isFetching = YES;
		return YES;
	}

	return NO;
}

- (void)cancelFetch {
	[self.request cancel];
	self.request.delegate = nil;
	self.request = nil;
	[super cancelFetch];
}

- (void)reset {
	[self cancelFetch];
	[super reset];
}

#pragma mark CKWebRequestDelegate

- (void)request:(id)request didReceiveData:(NSData *)data withResponseHeaders:(NSDictionary *)headers {
	return;
}

- (void)request:(id)request didReceiveValue:(id)value {
	id newItems = _transformBlock(value);
	
	if (newItems) {	
		NSAssert([newItems isKindOfClass:[NSArray class]], @"Transformed value should be an array of items");
		[self performSelector:@selector(addItems:) withObject:newItems];
	}
	
	self.currentIndex += [newItems count];
	self.hasMore = self.hasMore && (([newItems count] < _requestedBatchSize) ? NO : YES);
	self.isFetching = NO;
	self.request = nil;
}

- (void)request:(id)request didFailWithError:(NSError *)error {
	CKDebugLog(@"%@", error);
	self.isFetching = NO;
	self.request = nil;
	
	if(_failureBlock){
		_failureBlock(error);
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CKWebSourceErrorNotification object:self];
	
	// TODO: Makes the alert optional and allow the request to be restarted.
#ifdef DEBUG
		/*CKAlertView *alertView = 
		[[[CKAlertView alloc] initWithTitle:@"Fetching Error"
									message:[NSString stringWithFormat:@"%d %@", [error code], [error localizedDescription]]
								   delegate:self
						  cancelButtonTitle:_(@"Dismiss")
						  otherButtonTitles:nil] autorelease];
		[alertView show];*/
#endif
}

@end
