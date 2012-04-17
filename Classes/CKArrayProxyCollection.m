//
//  CKArrayProxyCollection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKArrayProxyCollection.h"
#import "CKNSNotificationCenter+Edition.h"
#import "CKDebug.h"

@implementation CKArrayProxyCollection
@synthesize property = _property;

+ (CKArrayProxyCollection*)collectionWithArrayProperty:(CKProperty*)property{
	return [[[CKArrayProxyCollection alloc]initWithArrayProperty:property]autorelease];
}

- (id)initWithArrayProperty:(CKProperty*)theProperty{
	[super init];
	CKClassPropertyDescriptor* desc = [theProperty descriptor];
	NSAssert([NSObject isClass:desc.type kindOfClass:[NSArray class]] || [[theProperty value]isKindOfClass:[NSArray class]],@"invalid property");
	self.property = theProperty;
	return self;
}


- (NSArray*)allObjects{
	return [NSArray arrayWithArray:[_property value]];
}

- (NSInteger) count{
	return [[_property value] count];
}

- (id)objectAtIndex:(NSInteger)index{
	return [[_property value] objectAtIndex:index];
}

- (void)insertObjects:(NSArray *)theObjects atIndexes:(NSIndexSet *)indexes{
	if([theObjects count] <= 0)
		return;
	
    [_property insertObjects:theObjects atIndexes:indexes];
	self.count = [[_property value] count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsAdded:theObjects atIndexes:indexes inCollection:self];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.addObjectsBlock){
        self.addObjectsBlock(theObjects,indexes); 
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexSet{
	NSArray* toRemove = [[_property value] objectsAtIndexes:indexSet];
	
	[_property removeObjectsAtIndexes:indexSet];
	self.count = [[_property value] count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsRemoved:toRemove atIndexes:indexSet inCollection:self];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.removeObjectsBlock){
        self.removeObjectsBlock(toRemove,indexSet); 
    }
}

- (void)removeAllObjects{
	NSArray* theObjects = [NSArray arrayWithArray: [_property value]];
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[_property value] count])];
	
	[_property removeAllObjects];
	self.count = [[_property value] count];
	
	[[NSNotificationCenter defaultCenter]notifyObjectsRemoved:theObjects atIndexes:indexSet inCollection:self];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.clearBlock){
        self.clearBlock(); 
    }
}

- (BOOL)containsObject:(id)object{
	return [[_property value] containsObject:object];
}

- (void)addObserver:(id)object{
    if([_property.keyPath isKindOfClass:[NSString class]]){
        [_property.object addObserver:object forKeyPath:_property.keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    }
    else{
        CKDebugLog(@"could not observe non string keypath for array property : %@",_property);
    }
}

- (void)removeObserver:(id)object{
    if([_property.keyPath isKindOfClass:[NSString class]]){
        [_property.object removeObserver:object forKeyPath:_property.keyPath];
    }
    else{
        CKDebugLog(@"could not observe non string keypath for array property : %@",_property);
    }
}

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate{
	return [[_property value] filteredArrayUsingPredicate:predicate];
}

- (void)replaceObjectAtIndex:(NSInteger)index byObject:(id)other{
	id object = [[_property value] objectAtIndex:index];
	[[_property value] removeObjectAtIndex:index];
	[[_property value] insertObject:other atIndex:index];
	self.count = [[_property value] count];	
	
	[[NSNotificationCenter defaultCenter]notifyObjectReplaced:object byObject:other atIndex:index inCollection:self];
	
	if(self.delegate != nil && [self.delegate respondsToSelector:@selector(documentCollectionDidChange:)]){
		[self.delegate documentCollectionDidChange:self];
	}
    
    if(self.replaceObjectBlock){
        self.replaceObjectBlock(other,object,index); 
    }
}

@end