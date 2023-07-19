//
//  CSignatureTextField.m
//  ComPDFKit_Tools
//
//  Created by kdanmobile_2 on 2023/6/7.
//

#import "CSignatureTextField.h"

@implementation CSignatureTextField

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x+150, bounds.origin.y, bounds.size.width, bounds.size.height);
         return inset;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    return inset;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
         return inset;
}

@end
