//
//  CKUIGradientView.m
//  GroupedTableStyled
//
//  Created by Olivier Collet on 11-04-07.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKGradientView.h"
#import "CKUIColorAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIImage+Transformations.h"

#import "CKNSObject+Bindings.h"

@implementation CKGradientViewUpdater
@synthesize view = _view;

- (void)frameChanged:(id)value{
	if(_size.width != self.view.bounds.size.width
	   || _size.height != self.view.bounds.size.height){
		_size = self.view.bounds.size;
		[self.view setNeedsDisplay];
	}
}

- (id)initWithView:(UIView*)theView{
	if(self = [super init]){
		self.view = theView;
		_size = self.view.bounds.size;
		[NSObject beginBindingsContext:[NSValue valueWithNonretainedObject:self]];
		[theView bind:@"frame" target:self action:@selector(frameChanged:)];
		[NSObject endBindingsContext];
	}
	return self;
}

- (void)dealloc{
	[NSObject removeAllBindingsForContext:[NSValue valueWithNonretainedObject:self]];
	[super dealloc];
}

@end

@interface CKGradientView () 
@property(nonatomic,retain)CKGradientViewUpdater* updater;
@property(nonatomic,retain)UIColor* fillColor;
@end



@implementation CKGradientView

@synthesize gradientColors = _gradientColors;
@synthesize gradientColorLocations = _gradientColorLocations;
@synthesize image = _image;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;
@synthesize updater = _updater;
@synthesize borderStyle = _borderStyle;
@synthesize fillColor = _fillColor;
@synthesize imageContentMode = _imageContentMode;

- (void)postInit {
	self.borderColor = [UIColor clearColor];
	self.borderWidth = 1;
	self.borderStyle = CKRoundedCornerViewTypeNone;
	self.updater = [[[CKGradientViewUpdater alloc]initWithView:self]autorelease];
	self.fillColor = [UIColor clearColor];
	self.imageContentMode = UIViewContentModeScaleToFill;
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self postInit];
	}
	return self;
}

//HACK to control how to paint using the background color !
- (void)setBackgroundColor:(UIColor *)color{
	self.fillColor = color;
	[super setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc {
	[_updater release]; _updater = nil;
	[_image release]; _image = nil;
	[_gradientColors release]; _gradientColors = nil;
	[_gradientColorLocations release]; _gradientColorLocations = nil;
	[_borderColor release]; _borderColor = nil;
	[_fillColor release]; _fillColor = nil;
	[super dealloc];
}

- (CGMutablePathRef)generateBorderPath{
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
		case CKRoundedCornerViewTypeNone:
			roundedCorners = 0;
			break;
		default:
			break;
	}
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	CGFloat radius = self.roundedCornerSize;
	CGMutablePathRef path = CGPathCreateMutable ();
	
	if(_borderStyle & CKGradientViewBorderTypeLeft){
		//draw arc from bottom to left or move to bottom left
		if((roundedCorners & UIRectCornerBottomLeft) && (_borderStyle & CKGradientViewBorderTypeBottom)){
			CGPathMoveToPoint (path, nil, radius, height);
			CGPathAddArcToPoint (path, nil, 0, height, 0, height - radius, radius);
		}
		else{
			CGPathMoveToPoint (path, nil, 0, (roundedCorners & UIRectCornerBottomLeft) ? (height - radius) : height);
		}
		
		//draw left line
		CGPathAddLineToPoint (path, nil, 0, (roundedCorners & UIRectCornerTopLeft) ? radius : 0);
		
		//draw arc from left to top
		if((roundedCorners & UIRectCornerTopLeft) && (_borderStyle & CKGradientViewBorderTypeTop)){
			CGPathAddArcToPoint (path, nil, 0, 0, radius, 0, radius);
		}
	}
	
	//draw top
	if(_borderStyle & CKGradientViewBorderTypeTop){
		CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerTopLeft) ? radius : 0, 0);
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerTopRight) ? (width - radius) : width, 0);
	}
	
	//draw right
	if(_borderStyle & CKGradientViewBorderTypeRight){
		//draw arc from top to right or move to top right
		if((roundedCorners & UIRectCornerTopRight) && (_borderStyle & CKGradientViewBorderTypeTop)){
			CGPathMoveToPoint (path, nil, width - radius, 0);
			CGPathAddArcToPoint (path, nil, width, 0, width, radius, radius);
		}
		else{
			CGPathMoveToPoint (path, nil, width, (roundedCorners & UIRectCornerTopRight) ? radius : 0);
		}
		
		//draw right line
		CGPathAddLineToPoint (path, nil, width, (roundedCorners & UIRectCornerBottomRight) ? (height - radius) : height);
		
		//draw arc from right to bottom
		if((roundedCorners & UIRectCornerBottomRight) && (_borderStyle & CKGradientViewBorderTypeBottom)){
			CGPathAddArcToPoint (path, nil, width, height, width - radius, height, radius);
		}
	}
	
	//draw bottom
	if(_borderStyle & CKGradientViewBorderTypeBottom){
		CGPathMoveToPoint (path, nil, (roundedCorners & UIRectCornerBottomRight) ? (width - radius) : width, height);
		CGPathAddLineToPoint (path, nil, (roundedCorners & UIRectCornerBottomLeft) ? radius : 0, height);
	}
	
	return path;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef gc = UIGraphicsGetCurrentContext();
	
	UIRectCorner roundedCorners = UIRectCornerAllCorners;
	switch (self.corners) {
		case CKRoundedCornerViewTypeTop:
			roundedCorners = (UIRectCornerTopLeft | UIRectCornerTopRight);
			break;
		case CKRoundedCornerViewTypeBottom:
			roundedCorners = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
			break;
			
		default:
			break;
	}
	
	CGPathRef clippingPath = nil;
	if (self.corners != CKRoundedCornerViewTypeNone) {
		clippingPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundedCorners cornerRadii:CGSizeMake(self.roundedCornerSize,self.roundedCornerSize)]CGPath];
	}
	
	if(self.gradientColors == nil){
		if(self.fillColor != nil){
			[self.fillColor setFill];
			if(clippingPath != nil){
				CGContextAddPath(gc, clippingPath);
			}
			CGContextFillPath(gc);
		}
		else{
			[[UIColor clearColor] setFill];
			if(clippingPath != nil){
				CGContextAddPath(gc, clippingPath);
			}
			CGContextFillPath(gc);
		}
	}
	
	
	if(_image){
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
			CGContextClip(gc);
		}
		
		//self.imageContentMode
		//[_image drawInRect:self.bounds];
		
		BOOL clip = NO;
		CGRect originalRect = rect;
		if (_image.size.width != rect.size.width || _image.size.height != rect.size.height) {
			if (_imageContentMode == UIViewContentModeLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTop) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeBottom) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeCenter) {
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - _image.size.width/2),
								  rect.origin.y + floor(rect.size.height/2 - _image.size.height/2),
								  _image.size.width, _image.size.height);
			} else if (_imageContentMode == UIViewContentModeBottomLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y + floor(rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeBottomRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y + (rect.size.height - _image.size.height),
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTopLeft) {
				rect = CGRectMake(rect.origin.x,
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeTopRight) {
				rect = CGRectMake(rect.origin.x + (rect.size.width - _image.size.width),
								  rect.origin.y,
								  _image.size.width, _image.size.height);
				clip = YES;
			} else if (_imageContentMode == UIViewContentModeScaleAspectFill) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				} else {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
			} else if (_imageContentMode == UIViewContentModeScaleAspectFit) {
				CGSize imageSize = _image.size;
				if (imageSize.height < imageSize.width) {
					imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
					imageSize.width = rect.size.width;
				} else {
					imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
					imageSize.height = rect.size.height;
				}
				rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
								  rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
								  imageSize.width, imageSize.height);
			}
		}
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		if (clip) {
			CGContextSaveGState(context);
			CGContextAddRect(context, originalRect);
			CGContextClip(context);
		}
		
		[_image drawInRect:rect];
		
		if (clip) {
			CGContextRestoreGState(context);
		}
	}	
						  
	if(self.gradientColors){
		if(clippingPath != nil){
			CGContextAddPath(gc, clippingPath);
			CGContextClip(gc);
		}
		
		CGFloat colorLocations[self.gradientColorLocations.count];
		int i = 0;
		for (NSNumber *n in self.gradientColorLocations) {
			colorLocations[i++] = [n floatValue];
		}
		
		NSMutableArray *colors = [NSMutableArray array];
		for (UIColor *color in self.gradientColors) {
			[colors addObject:(id)([[color RGBColor]CGColor])];
		}
		
		CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)colors, colorLocations);
		CGContextDrawLinearGradient(gc, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0, self.bounds.size.height), 0);
	}
	
	if(_borderColor!= nil && _borderColor != [UIColor clearColor]){
		[_borderColor setStroke];
		CGContextSetLineWidth(gc, self.borderWidth);
		CGMutablePathRef path = [self generateBorderPath];
		CGContextAddPath(gc, path);
		CGContextStrokePath(gc);
	}
}

@end