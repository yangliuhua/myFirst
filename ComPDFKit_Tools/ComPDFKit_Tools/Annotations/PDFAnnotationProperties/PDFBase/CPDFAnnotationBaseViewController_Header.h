//
//  CPDFAnnotationBaseViewController_Header.h
//  ComPDFKit_Tools
//
//  Created by kdanmobile_2 on 2023/4/23.
//

#ifndef CPDFAnnotationBaseViewController_Header_h
#define CPDFAnnotationBaseViewController_Header_h

#import "CPDFSampleView.h"
#import "CPDFColorSelectView.h"
#import "CPDFOpacitySliderView.h"
#import "CPDFColorPickerView.h"
#import "CAnnotStyle.h"

@interface CPDFAnnotationBaseViewController ()

@property (nonatomic, strong) CPDFSampleView *sampleView;

@property (nonatomic, strong) CPDFColorSelectView *colorView;

@property (nonatomic, strong) CPDFOpacitySliderView *opacitySliderView;

@property (nonatomic, strong) CPDFColorPickerView *colorPicker;

@property (nonatomic, strong) UIScrollView *scrcollView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@property (nonatomic, strong) UIView *sampleBackgoundView;

@property (nonatomic, strong) UIView *headerView;

- (void)commomInitTitle;

- (void)commomInitFromAnnotStyle;

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection;

@end

#endif /* CPDFAnnotationBaseViewController_Header_h */
