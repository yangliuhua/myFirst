//
//  CPDFStrikeoutViewController.h
//  ComPDFKit_Tools
//
//  Created by kdanmobile_2 on 2023/4/26.
//

#import <ComPDFKit_Tools/ComPDFKit_Tools.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFStrikeoutViewController;
@class CAnnotStyle;

@protocol CPDFStrikeoutViewControllerDelegate <NSObject>

@optional

- (void)strikeoutViewController:(CPDFStrikeoutViewController *)strikeoutViewController annotStyle:(CAnnotStyle *)annotStyle;

@end

@interface CPDFStrikeoutViewController : CPDFAnnotationBaseViewController

@property (nonatomic, weak) id<CPDFStrikeoutViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
