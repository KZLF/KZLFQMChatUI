//
//  QMChatRoomXbotCardView.h
//  IMSDK-OC-
//
//  Created by lishuijiao on 2019/12/24.
//  Copyright © 2019 HCF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KZLFLineSDK/QMLineSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMChatRoomXbotCardView : UIView <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, assign) QMMessageCardReadType type;
@property(nonatomic, assign) int showCount;

- (void)setCardDic:(NSDictionary *)dic;

@end

@interface QMChatRoomXbotCardShopCell : UITableViewCell

- (void)setShopDataDic:(NSDictionary *)dic cellWidth:(CGFloat)cellWidth;

@end

@interface QMChatRoomXbotCardListCell : UITableViewCell

- (void)setDataListDic:(NSDictionary *)dic cellWidth:(CGFloat)cellWidth;

@end


NS_ASSUME_NONNULL_END
