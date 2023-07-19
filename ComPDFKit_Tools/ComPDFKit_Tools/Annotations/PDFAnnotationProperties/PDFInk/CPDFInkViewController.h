//
//  CPDFInkViewController.h
//  ;-tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <ComPDFKit_Tools/ComPDFKit_Tools.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFInkViewController;
@class CAnnotStyle;

@protocol CPDFInkViewControllerDelegate <NSObject>

@optional

- (void)inkViewController:(CPDFInkViewController *)inkViewController annotStyle:(CAnnotStyle *)annotStyle;

- (void)inkViewControllerDimiss:(CPDFInkViewController *)inkViewController;

@end

@interface CPDFInkViewController : CPDFAnnotationBaseViewController

@property (nonatomic, weak) id<CPDFInkViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
