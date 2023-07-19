//
//  CPDFColorPickerView.h
//  ComPDFKit_Tools
//
//  Created by kdanmobile_2 on 2023/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFColorPickerView;

@protocol CPDFColorPickerViewDelegate <NSObject>

@optional

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color;

@end

@interface CPDFColorPickerView : UIView

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, weak) id<CPDFColorPickerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
