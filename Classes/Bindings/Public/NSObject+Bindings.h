//
//  NSObject+Bindings.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKCollection.h"


/** 
 */
typedef NS_ENUM(NSInteger, CKBindingsContextPolicy){
	CKBindingsContextPolicyAdd,
	CKBindingsContextPolicyRemovePreviousBindings
} ;

/** 
 */
typedef NS_ENUM(NSInteger, CKBindingsContextOptions){
	CKBindingsContextPerformOnMainThread           = 1 << 0,
	CKBindingsContextPerformOnCurrentThread        = 1 << 2,
    CKBindingsContextWaitUntilDone                 = 1 << 4
} ;


/** Creating bindings and opening context MUST be done on the main thread yet or it will assert.
 */
@interface NSObject(CKBindingContext)

///-----------------------------------
/// @name Printing bindings description
///-----------------------------------

/**
 */
+ (NSString *)allBindingsDescription;

///-----------------------------------
/// @name Managing Contexts
///-----------------------------------

/**
 */
+ (void)beginBindingsContext:(id)context;

/**
 */
+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy;

/**
 */
+ (void)beginBindingsContext:(id)context options:(CKBindingsContextOptions)options;

/**
 */
+ (void)beginBindingsContext:(id)context policy:(CKBindingsContextPolicy)policy options:(CKBindingsContextOptions)options;

/**
 */
+ (void)endBindingsContext;

/**
 */
+ (void)removeAllBindingsForContext:(id)context;

/**
 */
- (void)beginBindingsContextByKeepingPreviousBindings;

/**
 */
- (void)beginBindingsContextByRemovingPreviousBindings;

/**
 */
- (void)beginBindingsContextByKeepingPreviousBindingsWithOptions:(CKBindingsContextOptions)options;

/**
 */
- (void)beginBindingsContextByRemovingPreviousBindingsWithOptions:(CKBindingsContextOptions)options;


/**
 */
- (void)endBindingsContext;

/**
 */
- (void)clearBindingsContext;

/**
 */
+ (void)validateCurrentBindingsContext;

/**
 */
+ (CKBindingsContextOptions)currentBindingContextOptions;

/**
 */
+ (id)currentBindingContext;

@end



/** Creating bindings and opening context MUST be done on the main thread yet or it will assert.
 */
@interface NSObject (CKBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/**
 */
- (void)bind:(NSString *)keyPath toObject:(id)object withKeyPath:(NSString *)keyPath;

/**
 */
- (void)bind:(NSString *)keyPath withBlock:(void (^)(id value))block;

/**
 */
- (void)bind:(NSString *)keyPath executeBlockImmediatly:(BOOL)execute withBlock:(void (^)(id value))block;

/**
 */
- (void)bind:(NSString *)keyPath target:(id)target action:(SEL)selector;

/**
 */
- (void)bindPropertyChangeWithBlock:(void (^)(NSString* propertyName, id value))block;


@end

//



/** Creating bindings and opening context MUST be done on the main thread yet or it will assert.
 */
@interface UIControl (CKBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/**
 */
- (void)bindEvent:(UIControlEvents)controlEvents withBlock:(void (^)())block;

/**
 */
- (void)bindEvent:(UIControlEvents)controlEvents executeBlockImmediatly:(BOOL)execute withBlock:(void (^)())block;

/**
 */
- (void)bindEvent:(UIControlEvents)controlEvents target:(id)target action:(SEL)selector;

@end

//


/** Creating bindings and opening context MUST be done on the main thread yet or it will assert.
 */
@interface NSNotificationCenter (CKBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/**
 */
- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block;

/**
 */
- (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block;

/**
 */
- (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector;

/**
 */
- (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector;

/**
 */
+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender withBlock:(void (^)(NSNotification *notification))block;

/**
 */
+ (void)bindNotificationName:(NSString *)notification withBlock:(void (^)(NSNotification *notification))block;

/**
 */
+ (void)bindNotificationName:(NSString *)notification object:(id)notificationSender target:(id)target action:(SEL)selector;

/**
 */
+ (void)bindNotificationName:(NSString *)notification target:(id)target action:(SEL)selector;

@end


typedef NS_ENUM(NSInteger, CKCollectionBindingEvents){
    CKCollectionBindingEventInsertion   = 1 << 0,
    CKCollectionBindingEventRemoval     = 1 << 1,
    CKCollectionBindingEventAll = CKCollectionBindingEventInsertion | CKCollectionBindingEventRemoval
};


/** Creating bindings and opening context MUST be done on the main thread yet or it will assert.
 */
@interface CKCollection (CKBindings)

///-----------------------------------
/// @name Bindings
///-----------------------------------

/** Events is a bitMask with the following values:
     * CKCollectionBindingEventInsertion
     * CKCollectionBindingEventRemoval
     * CKCollectionBindingEventAll
 */
- (void)bindEvent:(CKCollectionBindingEvents)events withBlock:(void(^)(CKCollectionBindingEvents event, NSArray* objects, NSIndexSet* indexes))block;


/** Events is a bitMask with the following values:
 * CKCollectionBindingEventInsertion
 * CKCollectionBindingEventRemoval
 * CKCollectionBindingEventAll
 */
- (void)bindEvent:(CKCollectionBindingEvents)events executeBlockImmediatly:(BOOL)executeBlockImmediatly withBlock:(void(^)(CKCollectionBindingEvents event, NSArray* objects, NSIndexSet* indexes))block;

@end