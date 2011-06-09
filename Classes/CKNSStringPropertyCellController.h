//
//  CKNSStringPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStandardCellController.h"


@interface CKNSStringPropertyCellController : CKStandardCellController<UITextFieldDelegate> {
	UITextField* _textField;
}

@property (nonatomic,retain) UITextField* textField;

@end
