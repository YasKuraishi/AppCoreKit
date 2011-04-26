//
//  CKUITableView+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIView+Style.h"

extern NSString* CKTableViewStyle;

@interface NSMutableDictionary (CKUITableViewStyleStyle)

- (UITableViewStyle)tableViewStyle;

@end

@interface UITableView (CKStyle)

@end