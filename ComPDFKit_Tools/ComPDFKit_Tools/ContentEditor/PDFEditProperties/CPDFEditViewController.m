//
//  CPDFEditViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//


#import "CPDFEditViewController.h"
#import "CPDFImagePropertyCell.h"
#import "CPDFTextPropertyCell.h"
#import "CPDFColorPickerView.h"
#import "CPDFEditFontNameSelectView.h"
#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"
#import "CPDFEditTextSampleView.h"
#import "CPDFEditImageSampleView.h"

@interface CPDFEditViewController ()<UITableViewDelegate,UITableViewDataSource,CPDFColorPickerViewDelegate,CPDFEditFontNameSelectViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIColorPickerViewControllerDelegate>

@property (nonatomic, strong) UIView      * splitView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) CPDFColorPickerView * colorPickerView;
@property (nonatomic, strong) CPDFEditFontNameSelectView * fontSelectView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) CPDFEditTextSampleView * textSampleView;
@property (nonatomic, strong) CPDFEditImageSampleView * imageSampleView;

@end

@implementation CPDFEditViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}


#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat  topPadding = 0;
    CGFloat bottomPadding = 0;
    CGFloat leftPadding = 0;
    CGFloat rightPadding = 0;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topPadding = window.safeAreaInsets.top;
        bottomPadding = window.safeAreaInsets.bottom;
        leftPadding = window.safeAreaInsets.left;
        rightPadding = window.safeAreaInsets.right;
    }
    
    self.view.frame = CGRectMake(leftPadding, [UIScreen mainScreen].bounds.size.height - bottomPadding , [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding,self.view.frame.size.height);
    // Do any additional setup after loading the view.
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    if(self.editMode == CPDFEditModeText){
        self.titleLabel.text =  NSLocalizedString(@"Text Properties", nil);
    }else{
        self.titleLabel.text =  NSLocalizedString(@"Image Properties", nil);
    }
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFEditClose" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    
    self.splitView  = [[UIView alloc] init];
    self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.view addSubview:self.splitView];
    
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
}

- (void)viewWillLayoutSubviews {
    
    if (@available(iOS 11.0, *)) {
        
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.splitView.frame = CGRectMake(self.view.safeAreaInsets.left, 51, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 1);
        self.tableView.frame = CGRectMake(self.view.safeAreaInsets.left, 52, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - 52);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        
    } else {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.splitView.frame = CGRectMake(0, 51, self.view.frame.size.width, 1);
        self.tableView.frame = CGRectMake(0, 52, self.view.frame.size.width, self.view.frame.size.height - 52);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }

}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    if(self.editMode == CPDFEditModeText){
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 300 : 600);
    }else{
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 300 : 600);
    }

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.editMode == CPDFEditModeText){
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40, 120)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
        self.textSampleView = [[CPDFEditTextSampleView alloc] init];
        self.textSampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.textSampleView.layer.borderWidth = 1.0;
        self.textSampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.textSampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, view.bounds.size.height - 30);
        
        self.textSampleView.textAlignmnet = self.pdfView.editingSelectionAlignment;
        self.textSampleView.textColor = self.pdfView.editingSelectionFontColor;
        self.textSampleView.textOpacity = [self.pdfView getCurrentOpacity];
        self.textSampleView.fontName = self.pdfView.editingSelectionFontName;
        self.textSampleView.isBold = self.pdfView.isBoldCurrentSelection;
        self.textSampleView.isItalic = self.pdfView.isItalicCurrentSelection;
        self.textSampleView.fontSize = self.pdfView.editingSelectionFontSize;
        
        [view addSubview:self.textSampleView];
        
        return view;
    } else {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40, 120)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
        self.imageSampleView = [[CPDFEditImageSampleView alloc] init];
        self.imageSampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.imageSampleView.layer.borderWidth = 1.0;
        self.imageSampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.imageSampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, view.bounds.size.height - 30);
        
        if ([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] > 0) {
            if ([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] > 90) {
                self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, M_PI);
            } else {
                self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, M_PI/2);
            }
        } else if (([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] < 0)) {
            self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, -M_PI/2);
        }
//        self.imageSampleView.transFormType = 0;
        self.imageSampleView.imageView.alpha = [self.pdfView getCurrentOpacity];
        
        [view addSubview:self.imageSampleView];
        
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.editMode == CPDFEditModeText){
        return 120;
    }else{
        return 120;
    }

}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editMode == CPDFEditModeText){
        CPDFTextPropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Textcell"];
        if (!cell) {
            cell = [[CPDFTextPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Textcell"];
        }
        cell.backgroundColor = [UIColor colorWithRed:250./255 green:252/255. blue:255/255. alpha:1.];
        
        if(self.fontSelectView.fontName.length > 0){
            cell.currentSelectFontName = self.fontSelectView.fontName;
        }else{
            cell.currentSelectFontName  = self.pdfView.editingSelectionFontName;
        }
        
        cell.pdfView = self.pdfView;
        
        cell.actionBlock = ^(CPDFTextActionType actionType) {
            if(actionType == CPDFTextActionColorSelect){
                //Add colorSelectView
                
                if (@available(iOS 14.0, *)) {
                    UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
                    picker.delegate = self;
                    [self presentViewController:picker animated:YES completion:nil];
                } else {
                    self.colorPickerView = [[CPDFColorPickerView alloc] initWithFrame:self.view.frame];
                    self.colorPickerView.delegate = self;
                    self.colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    self.colorPickerView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
                    [self.view addSubview:self.colorPickerView];
                }
                
            }else if(actionType == CPDFTextActionFontNameSelect) {
                //Add actionFontNameSelect
                self.fontSelectView = [[CPDFEditFontNameSelectView alloc] initWithFrame:self.view.bounds];
                self.fontSelectView.fontNameArr = [NSMutableArray arrayWithArray:[self.pdfView getFontList]];
                self.fontSelectView.fontName = self.textSampleView.fontName;
                self.fontSelectView.delegate = self;
                self.fontSelectView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
                
                [self.view addSubview:self.fontSelectView];
            }
        };
        
        cell.colorBlock = ^(UIColor * _Nonnull selectColor) {
            self.textSampleView.textColor = selectColor;
            [self.pdfView setEditingSelectionFontColor:selectColor];
        };
        
        cell.boldBlock = ^(BOOL isBold) {
            self.textSampleView.isBold = isBold;
            [self.pdfView setCurrentSelectionIsBold:isBold];
        };
        
        cell.italicBlock = ^(BOOL isItalic) {
            self.textSampleView.isItalic = isItalic;
            [self.pdfView setCurrentSelectionIsItalic:isItalic];
        };
        
        cell.alignmentBlock = ^(CPDFTextAlignment alignment) {
            self.textSampleView.textAlignmnet = alignment;
            [self.pdfView setCurrentSelectionAlignment:(NSTextAlignment)alignment];
        };
        
        cell.fontSizeBlock = ^(CGFloat fontSize) {
            self.textSampleView.fontSize = fontSize * 10;
            [self.pdfView setEditingSelectionFontSize:fontSize * 10];
        };
        
        cell.opacityBlock = ^(CGFloat opacity) {
            self.textSampleView.textOpacity = opacity;
            [self.pdfView setCharsFontTransparency:opacity];
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return cell;
    }else{
        CPDFImagePropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        if (!cell) {
            cell = [[CPDFImagePropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CPDFImagePropertyCell"];
        }
        cell.backgroundColor = [UIColor colorWithRed:250./255 green:252/255. blue:255/255. alpha:1.];
        cell.pdfView = self.pdfView;
        cell.rotateBlock = ^(CPDFImageRotateType rotateType, BOOL isRotated) {
            if(rotateType == CPDFImageRotateTypeLeft){
                [self.pdfView rotateEditArea:(CPDFEditImageArea*)self.pdfView.editingArea rotateAngle:-90];
                self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, -M_PI/2);
                [self.imageSampleView setNeedsLayout];
            }else if(rotateType == CPDFImageRotateTypeRight){
                [self.pdfView rotateEditArea:(CPDFEditImageArea*)self.pdfView.editingArea rotateAngle:90];
                self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, M_PI/2);
                [self.imageSampleView setNeedsLayout];
            }
        };
        
        cell.transFormBlock = ^(CPDFImageTransFormType transformType, BOOL isTransformed) {
            if(transformType == CPDFImageTransFormTypeVertical){
                [self.pdfView verticalMirrorEditArea:(CPDFEditImageArea*)self.pdfView.editingArea];
                self.imageSampleView.imageView.transform = CGAffineTransformScale(self.imageSampleView.imageView.transform, 1.0, -1.0);
                [self.imageSampleView setNeedsLayout];
            }else if(transformType == CPDFImageTransFormTypeHorizontal){
                [self.pdfView horizontalMirrorEditArea:(CPDFEditImageArea*)self.pdfView.editingArea];
                self.imageSampleView.imageView.transform = CGAffineTransformScale(self.imageSampleView.imageView.transform, -1.0, 1.0);
                [self.imageSampleView setNeedsLayout];
            }
        };
        
        cell.transparencyBlock = ^(CGFloat transparency) {
            [self.pdfView setImageTransparencyEditArea:(CPDFEditImageArea*)self.pdfView.editingArea transparency:transparency];
            self.imageSampleView.imageView.alpha = transparency;
            [self.imageSampleView setNeedsLayout];
        };
        
        cell.replaceImageBlock = ^{
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        };
        
        cell.cropImageBlock = ^{
            [self.pdfView beginCropEditArea:(CPDFEditImageArea*)self.pdfView.editingArea];
            [self controllerDismiss];
        };
        
        cell.exportImageBlock = ^{
            BOOL saved = [self.pdfView extractImageWithEditImageArea:self.pdfView.editingArea];
            if(saved){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Successfully!", nil) preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self controllerDismiss];
                }]];

                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Failed!", nil) preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self controllerDismiss];
                }]];

                [self presentViewController:alertController animated:YES completion:nil];
            }
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editMode == CPDFEditModeText){
        return 400;
    }else{
        return 380;
    }
}

#pragma mark - ColorPickerDelegate
- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.textSampleView.textColor = color;
    [self.pdfView setEditingSelectionFontColor:color];
}

#pragma mark - CPDFEditFontNameSelectViewDelegate
- (void)pickerView:(CPDFEditFontNameSelectView *)colorPickerView fontName:(NSString *)fontName{
    self.textSampleView.fontName  = fontName;
    [self.pdfView setEditingSelectionFontName:fontName];
    [self.tableView reloadData];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.textSampleView.textColor = viewController.selectedColor;
    [self.pdfView setEditingSelectionFontColor:viewController.selectedColor];
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    self.textSampleView.textOpacity = alpha;
    [self.pdfView setCharsFontTransparency:alpha];
    [self.tableView reloadData];
}

#pragma mark - setMode
- (void)setEditMode:(CPDFEditMode)editMode{
    _editMode = editMode;
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - Action
- (void)buttonItemClicked_back:(UIButton *)button {
    [self controllerDismiss];
}

#pragma mark - Accessors

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    if (@available(iOS 11.0, *)) {
        NSURL * url = info[UIImagePickerControllerImageURL];
        [self.pdfView replaceEditImageArea:(CPDFEditImageArea*)self.pdfView.editingArea imagePath:url.path];

    } else {
        NSURL * url = info[UIImagePickerControllerMediaURL];
        [self.pdfView replaceEditImageArea:(CPDFEditImageArea*)self.pdfView.editingArea imagePath:url.path];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self controllerDismiss];
}

- (void)controllerDismiss {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
