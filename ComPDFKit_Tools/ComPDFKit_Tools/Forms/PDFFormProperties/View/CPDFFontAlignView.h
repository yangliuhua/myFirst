//
//  CPDFFontAlignView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFFontAlignView;

@protocol CPDFFontAlignViewDelegate <NSObject>

@optional
- (void)CPDFFontAlignView:(CPDFFontAlignView *)view algnment:(NSTextAlignment)textAlignment;
@end


@interface CPDFFontAlignView : UIView

@property (nonatomic, strong) UILabel * alignmentLabel;

@property (nonatomic, weak) id<CPDFFontAlignViewDelegate> delegate;

@property (nonatomic, assign) NSTextAlignment alignment;

@end
