//
//  XYZSystemAlertView.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/20.
//

#import "XYZAlertView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYZSystemAlertViewActionBtn : UIButton

@property (nonatomic, copy) dispatch_block_t action;
+ (instancetype)actionWithName:(NSString *)name clickCallback:(dispatch_block_t)action;
@end


@interface XYZSystemAlertView : XYZAlertView

@property (nonatomic, copy) NSAttributedString *attributeTitle;
@property (nonatomic, copy) NSAttributedString *attributeMessage;

- (instancetype)initWithTitle:(nullable NSString *)title msg:(nullable NSString *)msg;

// MAX = 2
- (void)addActionBtn:(XYZSystemAlertViewActionBtn *)action;
@end

NS_ASSUME_NONNULL_END
