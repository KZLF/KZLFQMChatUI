//
//  QMChatBaseCell.h
//  IMSDK
//
//  Created by lishuijiao on 2020/10/19.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <KZLFLineSDK/QMLineSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface QMChatBaseCell : UITableViewCell
/**头像*/
@property (nonatomic, strong) UIImageView *iconImage;
/**时间*/
@property (nonatomic, strong) UILabel *timeLabel;
/**对话框*/
@property (nonatomic, strong) UIView *chatBackgroundView;
/**消息发送状态*/
@property (nonatomic, strong) UIImageView *sendStatus;
/**已读未读状态*/
@property (nonatomic, strong) UILabel *readStatus;
/**消息模型*/
@property (nonatomic, strong) CustomMessage *message;

@property (nonatomic, copy) void(^tapSendMessage)(NSString *message, NSString *number);

@property (nonatomic, copy) void(^didBtnAction)(BOOL isUseful, NSString *tag, NSString *remark);

@property (nonatomic, copy) void(^tapNetAddress)(NSString *);

@property (nonatomic, copy) void(^tapNumberAction)(NSString *);

@property (nonatomic, copy) void(^tapArtificialAction)(NSString *);

@property (nonatomic, strong) void(^noteSelected)(CustomMessage *message);

@property (nonatomic, copy) void(^tapCommonAction)(NSInteger);

@property (nonatomic, copy) void(^tapFlowSelectAction)(NSArray * array, BOOL isSend);

@property (nonatomic, copy) void(^tapListCardAction)(NSDictionary *listDic);

@property (nonatomic, copy) void(^needReloadCell)(CustomMessage * model);

@property (nonatomic, copy) void(^contentStartEditBlock)(CGRect frameToView);

@property (nonatomic, copy) void(^clickContactAction)(NSString *content, NSString *status);
@property (nonatomic, copy) void(^switchRobotAction)(NSString *robotId);

- (void)createUI;

- (void)setData:(CustomMessage *)message avater:(NSString *)avater;

- (void)setMessageIsRead:(NSString *)isRead;

@end

NS_ASSUME_NONNULL_END
