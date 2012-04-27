//
//  CKPropertyGridCellController+CKDynamicLayout.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-19.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"

@interface CKPropertyGridCellController (CKDynamicLayout)

- (void)performValidationLayout;
- (CGRect)rectForValidationButtonWithCell:(UITableViewCell*)cell;

@end