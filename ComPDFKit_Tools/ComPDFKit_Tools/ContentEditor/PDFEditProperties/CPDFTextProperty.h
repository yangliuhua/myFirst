//
//  CPDFTextProperty.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CPDFEditTextAlignment) {
    CPDFEditTextAlignmentLeft,
    CPDFEditTextAlignmentCenter,
    CPDFEditTextAlignmentRighht,
    CPDFEditTextAlignmentNone
};

NS_ASSUME_NONNULL_BEGIN

@interface CPDFTextProperty : NSObject

@property (nonatomic, strong) UIColor *fontColor;

@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, assign) BOOL isBold;

@property (nonatomic, assign) BOOL isItalic;

@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) CPDFEditTextAlignment textAlignment;

@end

NS_ASSUME_NONNULL_END
