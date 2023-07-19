//
//  CPDFFormListOptionVC.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFView;
@class CPDFFormListOptionVC;
@class CPDFAnnotation;

@protocol CPDFFormListOptionControllerDelegate <NSObject>

@optional

- (void)CPDFFormListOptionVC:(CPDFFormListOptionVC *)listOptionVC pageIndex:(NSInteger)pageIndex;

@end

@interface CPDFFormListOptionVC : UIViewController

@property (nonatomic, readonly) CPDFView *pdfView;

@property (nonatomic, readonly) CPDFAnnotation *annotation;

@property (nonatomic, weak) id<CPDFFormListOptionControllerDelegate> delegate;

- (instancetype)initWithPDFView:(CPDFView *)pdfView andAnnotation:(CPDFAnnotation*)annotation;


@end

