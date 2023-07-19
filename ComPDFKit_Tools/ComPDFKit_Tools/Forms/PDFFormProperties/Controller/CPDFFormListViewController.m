//
//  CPDFFormListViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormListViewController.h"

#import "CPDFColorSelectView.h"
#import "CPDFThicknessSliderView.h"
#import "CPDFFormTextFieldView.h"
#import "CPDFFormSwitchView.h"
#import "CPDFFontSettingView.h"
#import "CPDFFontAlignView.h"
#import "CPDFFormInputTextView.h"

#import <ComPDFKit/ComPDFKit.h>
#import "CAnnotationManage.h"
#import "CAnnotStyle.h"
#import "CPDFColorPickerView.h"
#import "CPDFColorUtils.h"
#import "CPDFColorPickerView.h"
#import "CPDFFontStyleTableView.h"

@interface CPDFFormListViewController ()<CPDFFormTextFiledViewDelegate,CPDFColorSelectViewDelegate,CPDFThicknessSliderViewDelegate,CPDFFormSwitchViewDelegate,UIColorPickerViewControllerDelegate,CPDFColorPickerViewDelegate,CPDFFontSettingViewDelegate,CPDFFontStyleTableViewDelegate>
@property (nonatomic, strong) CPDFColorSelectView * borderColorView;
@property (nonatomic, strong) CPDFColorSelectView * backGroundColorView;
@property (nonatomic, strong) CPDFColorSelectView * textColorView;
@property (nonatomic, strong) CPDFThicknessSliderView * sizeThickNessView;
@property (nonatomic, strong) CPDFFormTextFieldView * textFiledView;
@property (nonatomic, strong) CPDFFormSwitchView * hideFormView;
@property (nonatomic, strong) CPDFFontSettingView * fontSettingView;

@property (nonatomic, strong) CAnnotationManage * annotManage;
@property (nonatomic, strong) CPDFChoiceWidgetAnnotation * listChoiceWidget;
@property (nonatomic, strong) CPDFColorPickerView * colorPicker;
@property (nonatomic, strong) CPDFColorSelectView * currentSelectColorView;

@property (nonatomic, strong) CPDFFontStyleTableView *fontStyleTableView;

@property (nonatomic,   copy) NSString * baseName;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) CGFloat fontSize;
@end

@implementation CPDFFormListViewController

- (instancetype)initWithManage:(CAnnotationManage *)annotManage {
    if (self = [super init]) {
        self.annotManage = annotManage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.borderColorView = [[CPDFColorSelectView alloc] init];
    self.borderColorView.delegate = self;
    self.borderColorView.colorLabel.text = NSLocalizedString(@"Stroke Color", nil);
    self.borderColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.borderColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.borderColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    
    
    self.backGroundColorView = [[CPDFColorSelectView alloc] init];
    self.backGroundColorView.colorLabel.text = NSLocalizedString(@"Background Color", nil);
    self.backGroundColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.backGroundColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.backGroundColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    self.backGroundColorView.delegate = self;
    
    self.textColorView = [[CPDFColorSelectView alloc] init];
    self.textColorView.colorLabel.text = NSLocalizedString(@"Font Color", nil);
    self.textColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.textColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.textColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    self.textColorView.delegate = self;
    
    [self.scrcollView addSubview:self.borderColorView];
    [self.scrcollView addSubview:self.backGroundColorView];
    [self.scrcollView addSubview:self.textColorView];
    
    self.sizeThickNessView = [[CPDFThicknessSliderView alloc] init];
    self.sizeThickNessView.titleLabel.text = NSLocalizedString(@"Font Size", nil);
    self.sizeThickNessView.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.sizeThickNessView.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    [self.scrcollView addSubview:self.sizeThickNessView];
    self.sizeThickNessView.delegate = self;
    self.sizeThickNessView.thick = 10.;
    
    self.textFiledView = [[CPDFFormTextFieldView alloc] init];
    self.textFiledView.delegate = self;
    [self.scrcollView addSubview:self.textFiledView];
    
    self.fontSettingView = [[CPDFFontSettingView alloc] init];
    self.fontSettingView.fontNameLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.fontSettingView.fontNameLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.fontSettingView.fontNameLabel.text = NSLocalizedString(@"Font", nil);
    self.fontSettingView.delegate = self;
    [self.scrcollView addSubview:self.fontSettingView];
    
    self.fontSize = 14;
    
    self.baseName = @"Helvetica";
    self.fontSettingView.fontNameSelectLabel.text = self.baseName;
    
    self.listChoiceWidget = (CPDFChoiceWidgetAnnotation*)self.annotManage.annotStyle.annotations.firstObject;
    
}

#pragma mark - Private


- (void)analyzeFont:(NSString *)fontName {
    if(fontName == nil) {
        self.fontSettingView.isBold = NO;
        self.fontSettingView.isItalic = NO;
        return;
    }
    
    if ([fontName rangeOfString:@"Bold"].location != NSNotFound) {
       //isBold
        self.fontSettingView.isBold = YES;
        self.isBold = YES;
    } else {
        //is not bold
        self.fontSettingView.isBold = NO;
        self.isBold = NO;
    }
    if ([fontName rangeOfString:@"Italic"].location != NSNotFound || [fontName rangeOfString:@"Oblique"].location != NSNotFound) {
        //is Italic
        self.fontSettingView.isItalic = YES;
        self.isItalic = YES;
    } else {
        //is Not Italic
        self.fontSettingView.isItalic = NO;
        self.isItalic = NO;
        
    }
    if ([fontName rangeOfString:@"Helvetica"].location != NSNotFound)
    {
        self.baseName = @"Helvetica";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Courier"].location != NSNotFound)
    {
        self.baseName = @"Courier";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Times"].location != NSNotFound)
    {
        self.baseName = @"Times-Roman";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
    }
}



- (NSString *)constructionFontname:(NSString *)baseName isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    NSString *result;
    if ([baseName rangeOfString:@"Times"].location != NSNotFound) {
       if (isBold || isItalic) {
           if (isBold && isItalic) return @"Times-BoldItalic";
           if (isBold) return @"Times-Bold";
           if (isItalic) return @"Times-Italic";
       }
       else
           return @"Times-Roman";
    }
    if (isBold || isItalic) {
       result = [NSString stringWithFormat:@"%@-",baseName];
       if (isBold) result = [NSString stringWithFormat:@"%@Bold",result];
       if (isItalic) result = [NSString stringWithFormat:@"%@Oblique",result];
    }
    else return baseName;
    return result;
}

#pragma mark - Setter
- (void)setListChoiceWidget:(CPDFChoiceWidgetAnnotation *)listChoiceWidget {
    _listChoiceWidget = listChoiceWidget;
    
    
    //field Name
    self.textFiledView.contentField.text = self.listChoiceWidget.fieldName;
    //border color
    if(self.listChoiceWidget.borderColor == nil) {
        self.borderColorView.selectedColor = [UIColor clearColor];
        self.listChoiceWidget.borderColor = self.borderColorView.selectedColor;
        [self refreshUI];
    }else{
        self.borderColorView.selectedColor = self.listChoiceWidget.borderColor;
    }
    
    
    if(self.listChoiceWidget.backgroundColor == nil) {
        self.backGroundColorView.selectedColor = [UIColor clearColor];
        self.listChoiceWidget.backgroundColor = self.backGroundColorView.selectedColor;
        [self refreshUI];
    }else {
        //back groundColor
        self.backGroundColorView.selectedColor = self.listChoiceWidget.backgroundColor;
    }
    
    //Text color
    if(self.listChoiceWidget.fontColor == nil) {
        self.textColorView.selectedColor = [UIColor blackColor];
        self.listChoiceWidget.fontColor = self.textColorView.selectedColor;
    }else{
        self.textColorView.selectedColor = self.listChoiceWidget.fontColor;
    }
    
    //Text content
    [self analyzeFont:self.listChoiceWidget.font.fontName];
    
    if(!self.listChoiceWidget.font) {
        self.sizeThickNessView.defaultValue = 0.14;
    }else{
        if(self.listChoiceWidget.font.pointSize == 0){
            self.sizeThickNessView.defaultValue = 0.14;
            self.fontSize = 14;
        }else{
            self.sizeThickNessView.defaultValue = self.listChoiceWidget.font.pointSize/100. ;
            self.fontSize = self.listChoiceWidget.font.pointSize;
        }
    }
    
    //hide form
    self.hideFormView.switcher.on = self.listChoiceWidget.isHidden;
    
    
}

#pragma mark - Protect Mehtods

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"List Box", nil);
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    if ([self.colorPicker superview]) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 520);
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 320);
        }
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 600);
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 550);
    self.scrcollView.showsVerticalScrollIndicator = NO;
    
    
    if (@available(iOS 11.0, *)) {
        self.textFiledView.frame = CGRectMake(self.view.safeAreaInsets.left, 8, self.view.frame.size.width - self.view.safeAreaInsets.left, 65);
        self.borderColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.textFiledView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,74);
        self.backGroundColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.borderColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,74);
        self.textColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.backGroundColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.fontSettingView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.textColorView.frame)+8, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 30);
    
        self.sizeThickNessView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.fontSettingView.frame),self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 82);
    } else {
        self.textFiledView.frame = CGRectMake(0, 8, self.view.bounds.size.width, 60);
        self.borderColorView.frame = CGRectMake(0,CGRectGetMaxY(self.textFiledView.frame)+8, self.view.frame.size.width, 74);
        self.backGroundColorView.frame = CGRectMake(0,CGRectGetMaxY(self.borderColorView.frame)+8, self.view.frame.size.width, 74);
        self.textColorView.frame = CGRectMake(0, CGRectGetMaxY(self.backGroundColorView.frame)+8, self.view.frame.size.width, 74);
        self.fontSettingView.frame = CGRectMake(0, CGRectGetMaxY(self.textColorView.frame)+8, self.view.frame.size.width, 30);
        self.sizeThickNessView.frame = CGRectMake(0, CGRectGetMaxY(self.fontSettingView.frame), self.view.frame.size.width, 82);
//        self.hideFormView.frame = CGRectMake(0, CGRectGetMaxY(self.sizeThickNessView.frame) + 8, self.view.frame.size.width, 44);
    }
}

#pragma mark - CPDFFormTextFiledViewDelegate

- (void)SetCPDFFormTextFiledView:(CPDFFormTextFieldView *)view text:(NSString *)completedText {
    self.listChoiceWidget.fieldName = completedText;
    [self refreshUI];
}


#pragma mark - CPDFColorSelectViewDelegate
- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.currentSelectColorView = select;
    if(select == self.borderColorView) {
        self.listChoiceWidget.borderColor = color;
    }else if(select == self.backGroundColorView) {
        self.listChoiceWidget.backgroundColor = color;
    }else if(select == self.textColorView) {
        self.listChoiceWidget.fontColor = color;
    }
    [self refreshUI];
}

- (void)selectColorView:(CPDFColorSelectView *)select {
    self.currentSelectColorView = select;
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 520)];
        } else {
            // This is an iPhone or iPod touch
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 320)];
        }
        self.colorPicker.delegate = self;
        self.colorPicker.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.view addSubview:self.colorPicker];
        [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];

    }
    [self refreshUI];
}


#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    if(self.currentSelectColorView == self.borderColorView) {
        self.listChoiceWidget.borderColor = color;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        self.listChoiceWidget.backgroundColor = color;
    }else if(self.currentSelectColorView == self.textColorView) {
        self.listChoiceWidget.fontColor = color;
    }
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];

    [self refreshUI];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if(self.currentSelectColorView == self.borderColorView) {
        self.listChoiceWidget.borderColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        self.listChoiceWidget.backgroundColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.textColorView) {
        self.listChoiceWidget.fontColor = viewController.selectedColor;
    }
    [self refreshUI];
}

#pragma mark - CPDFFormSwitchViewDelegate
- (void)SwitchActionInView:(CPDFFormSwitchView *)view switcher:(UISwitch *)switcher {
    if(switcher.on) {
        if([self.annotManage.pdfListView.activeAnnotations containsObject:self.annotManage.annotStyle.annotations.firstObject]) {
            [self.annotManage.pdfListView updateActiveAnnotations:@[]];
        }
    }
    [self.listChoiceWidget setHidden:switcher.on];
    [self refreshUI];
}

#pragma mark - CPDFThicknessSliderViewDelegate
- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    self.fontSize = thickness * 10;
    [self refreshUI];
}


#pragma mark - CPDFFontSettingViewDelegate
- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isBold:(BOOL)isBold {
    self.isBold = isBold;
    [self refreshUI];
}

- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isItalic:(BOOL)isItalic {
    self.isItalic = isItalic;
    [self refreshUI];
}

- (void)CPDFFontSettingView:(CPDFFontSettingView *)view text:(NSString *)text {
}


#pragma mark - CPDFFontSettingViewDelegate
- (void)CPDFFontSettingViewFontSelect:(CPDFFontSettingView *)view {
    self.fontStyleTableView = [[CPDFFontStyleTableView alloc] initWithFrame:self.view.bounds];
    self.fontStyleTableView.delegate = self;
    self.fontStyleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fontStyleTableView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.fontStyleTableView];
    [self refreshUI];
    
}

#pragma mark - CPDFFontStyleTableViewDelegate
- (void)fontStyleTableView:(CPDFFontStyleTableView *)fontStyleTableView fontName:(NSString *)fontName {
    self.baseName = fontName;
    self.fontSettingView.fontNameSelectLabel.text = fontName;
    [self refreshUI];
}

- (void)refreshUI {
    NSString * fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    self.listChoiceWidget.font = [UIFont fontWithName:fontName size:self.fontSize];
    [self.listChoiceWidget updateAppearanceStream];
    CPDFPage *page = self.listChoiceWidget.page;
    [self.annotManage.pdfListView setNeedsDisplayForPage:page];
}


@end
