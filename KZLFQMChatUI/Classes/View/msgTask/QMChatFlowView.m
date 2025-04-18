//
//  QMChatFlowView.m
//  IMSDK
//
//  Created by lishuijiao on 2020/10/27.
//

#import "QMChatFlowView.h"
#import "QMCustomLayout.h"
#import "QMChatShowImageViewController.h"
#import "MLEmojiLabel.h"
#import "QMHeader.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
@interface QMChatFlowView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, MLEmojiLabelDelegate> {
    
    // 内容高度
    CGFloat height;
    
    // 内容宽度
    CGFloat width;

    // 链接集合
    NSMutableArray *srcArrs;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UILabel *headerLabel;

@property (nonatomic, strong) UILabel *lineLabel;

@property (nonatomic, strong) QMCustomLayout *layout;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

//上下左右的间距
static CGFloat topGap = 10;
static CGFloat leftGap = 10;
static CGFloat rightGap = 10;
static CGFloat lineSpace = 10.f;
static CGFloat InteritemSpace = 10.f;

@implementation QMChatFlowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        srcArrs = [NSMutableArray array];
    }
    return  self;
}

- (void)setDarkModeColor {
    self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _lineLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    _pageControl.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    [_collectionView reloadData];
}

- (void)createUI {
        
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.frame), 10)];
    _pageControl.numberOfPages = 3;
    _pageControl.currentPage = 0;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:isDarkStyle ? @"8E8E8E" : QMColor_News_Custom];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:isDarkStyle ? @"#353535" : @"#C0C0C0"];
    [self addSubview:_pageControl];

    [self.collectionView registerClass:[QMChatRobotFlowCollectionCell class] forCellWithReuseIdentifier:@"FlowCollectionCell"];

    _lineLabel = [[UILabel alloc] init];
    _lineLabel.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
    [self addSubview:_lineLabel];

}

- (void)setDate {
    height = 10;
    
    [srcArrs removeAllObjects];
    for (id itme in self.subviews) {
        if ([itme isKindOfClass:[MLEmojiLabel class]]) {
            [itme removeFromSuperview];
        }else if ([itme isKindOfClass:[UIImageView class]]) {
            [itme removeFromSuperview];
        }
    }
    self.dataSource = [QMLabelText dictionaryWithJsonString:self.flowList];
    
    int maxItem = 8;
    if (self.isVertical) {
        maxItem = 4;
    }
    
    CGFloat number;
    if (self.dataSource.count%maxItem == 0) {
        number = self.dataSource.count/maxItem;
    }else {
        number = self.dataSource.count/maxItem+1;
    }
    
    NSMutableArray * srcArr = [self showHtml:self.robotFlowTip];
    //获取分段类型 文本 图片
    for (QMLabelText *model in srcArr) {
        if ([model.type isEqualToString:@"text"]) {
            [self createLabel:model.content];
        }else {
            [self createImage:model.content];
        }
    }

    _lineLabel.frame = CGRectMake(10, height + 12, CGRectGetWidth(self.frame) - 20, 1);

    _collectionView.frame = CGRectMake(0, height + 13, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - height - 13 - 20);
    if (self.isVertical) {
        self.layout.itemSize = CGSizeMake(240, 40);
    }else {
        self.layout.itemSize = CGSizeMake(115, 40);
    }
    self.layout.isVertical = self.isVertical;
    
    _pageControl.frame = CGRectMake(10,  CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame) - 20, 10);
    _pageControl.numberOfPages = number;
    
    [self.collectionView reloadData];
}

// 创建文本
- (void)createLabel: (NSString *)text {
    NSMutableArray *array = [self getAHtml:text];
    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *tempString = [regularExpretion stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length) withTemplate:@""];
    
    MLEmojiLabel *tLabel = [MLEmojiLabel new];
    tLabel.numberOfLines = 0;
    tLabel.font = [UIFont fontWithName:QM_PingFangSC_Reg size:16];
    tLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tLabel.delegate = self;
    tLabel.disableEmoji = NO;
    tLabel.disableThreeCommon = NO;
    tLabel.isNeedAtAndPoundSign = YES;
    tLabel.customEmojiRegex = @"\\:[^\\:]+\\:";
    tLabel.customEmojiPlistName = @"expressionImage.plist";
    tLabel.customEmojiBundleName = @"QMEmoticon.bundle";
    [self addSubview:tLabel];
    
    tLabel.checkResults = array;
    tLabel.checkColor = [UIColor colorWithRed:32/255.0f green:188/255.0f blue:158/255.0f alpha:1];

    tLabel.text = @"";
    tLabel.text = tempString;

    
    // labelFrame
//    CGSize size = [tLabel preferredSizeWithMaxWidth: QMChatTextMaxWidth];
    CGSize size = [tLabel preferredSizeWithMaxWidth: [UIScreen mainScreen].bounds.size.width - 160];

    tLabel.frame = CGRectMake(15, height, size.width, size.height);
    
    
    // 宽高适配
    height += size.height;
    width = width > size.width ? width : size.width;
}

// 创建图片 图片大小可调整
- (void)createImage: (NSString *)imageUrl {
    
    NSArray *temArray = nil;
    if ([imageUrl rangeOfString:@"src=\""].location != NSNotFound) {
        temArray = [imageUrl componentsSeparatedByString:@"src=\""];
    }else if ([imageUrl rangeOfString:@"src="].location != NSNotFound) {
        temArray = [imageUrl componentsSeparatedByString:@"src="];
    }

    if (temArray.count >= 2) {
        NSString *src = temArray[1];
        
        NSUInteger loc = [src rangeOfString:@"\""].location;
        if (loc != NSNotFound) {
            
            // 图片地址
            src = [src substringToIndex:loc];
            src = [src stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(15, height, 140, 100);
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [self addSubview:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:src] placeholderImage:[UIImage imageNamed:@"icon"]];
            
            QMTapGestureRecognizer * tapPressGesture = [[QMTapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressGesture:)];
            tapPressGesture.picName = src;
            tapPressGesture.picType = @"1";
            tapPressGesture.image = imageView.image;
            [imageView addGestureRecognizer:tapPressGesture];

            height += 100;
            width = width > 140 ? width : 140;
        }
    }
}

#pragma mark 文本处理
- (NSMutableArray *)showHtml: (NSString *)htmlString {

    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</br>" withString:@"\n"];
    if ([htmlString containsString:@"</p>"]) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    } else if ([htmlString containsString:@"<p>"]) {
        if ([htmlString hasPrefix:@"<p>"]) {
            htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
        }
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
    }
    // 拆分文本和图片
    __block NSString *tempString = htmlString;
    __block NSMutableArray *srcArr = [NSMutableArray array];
    
    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
    [regularExpretion enumerateMatchesInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length != 0) {
            // 字符串
            NSString *actionString = [NSString stringWithFormat:@"%@",[htmlString substringWithRange:result.range]];
            
            // 新的range
            NSRange range = [tempString rangeOfString:actionString];
            
            NSArray *components = nil;
            if ([actionString rangeOfString:@"<img src=\""].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src=\""];
            }else if ([actionString rangeOfString:@"<img src="].location != NSNotFound) {
                components = [actionString componentsSeparatedByString:@"src="];
            }

            if (components.count >= 2) {
                // 文本内容
                QMLabelText *model1 = [[QMLabelText alloc] init];
                model1.type = @"text";
                model1.content = [tempString substringToIndex:range.location];
                [srcArr addObject:model1];
                
                // 图片内容
                QMLabelText *model2 = [[QMLabelText alloc] init];
                model2.type = @"image";
                model2.content = [tempString substringWithRange:range];;
                [srcArr addObject:model2];
                tempString = [tempString substringFromIndex:range.location+range.length];
            }
        }
    }];
    
    QMLabelText *model3 = [[QMLabelText alloc] init];
    model3.type = @"text";
    model3.content = tempString;
    [srcArr addObject:model3];
    return srcArr;
}

- (NSMutableArray *)getAHtml: (NSString *)htmlString {
    // 文本匹配A标签
    __block NSString *tempString = htmlString;
    __block NSMutableArray *srcArr = [NSMutableArray array];
    __block int length = 0;

    NSRegularExpression *regularExpretion = [[NSRegularExpression alloc] initWithPattern:@"<a(.*?)href=(?:.*?)>(.*?)</a>" options:NSRegularExpressionCaseInsensitive error:nil];
    [regularExpretion enumerateMatchesInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length != 0) {
            NSRegularExpression *regularExpretion1 = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:nil];
            
            QMLabelText *model = [[QMLabelText alloc] init];

            // 获取高亮字符串
            NSString *actionString = [NSString stringWithFormat:@"%@",[htmlString substringWithRange:result.range]];
//            NSLog(@"获取高亮字符串--%@",actionString);
            // 获取链接 actionString -> https
            
            NSString *subRag = nil;
            NSString *sepearatStr = nil;
            if ([actionString containsString:@"href=\""]) {
                sepearatStr = @"href=\"";
                subRag = @"\"";
            } else {
                sepearatStr = @"href=";
                subRag = @">";
            }
            
            NSArray *components = [actionString componentsSeparatedByString:sepearatStr];
            if (components.count > 1) {
                NSString *src = components[1];
                NSUInteger loc = [src rangeOfString:subRag].location;
                if (loc != NSNotFound) {
                    // 地址
                    src = [src substringToIndex:loc];
                    src = [src stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    model.content = src;
//                    NSLog(@"走近循环--%@",src);
                }
            }
            
            actionString = [regularExpretion1 stringByReplacingMatchesInString:actionString options:NSMatchingReportProgress range:NSMakeRange(0, actionString.length) withTemplate:@""];

            // 找相同type不同位置的点击
            NSString *regStr = actionString;
            // 找相同type不同位置的点击end

            // 获取高亮range 防止重复
            actionString = [NSString stringWithFormat:@">%@<", actionString];
            model.type = actionString;
            NSRange range = [tempString rangeOfString:actionString];
            
            
            // 找相同type不同位置的点击
            NSString *prexStr = [htmlString substringToIndex:result.range.location];
            NSRegularExpression *regulerA = [NSRegularExpression regularExpressionWithPattern:regStr options:NSRegularExpressionAnchorsMatchLines error:nil];
            NSArray *matchs = [regulerA matchesInString:prexStr options:NSMatchingReportProgress range:NSMakeRange(0, prexStr.length)];
            model.rangeValue = [NSString stringWithFormat:@"%ld",matchs.count];
            // 找相同type不同位置的点击end

            // 拼接标号（目标位置前几个相同字段）
            // 高亮之前的字符串
            if (tempString.length > range.location+1) {
                NSString *preString = [tempString substringToIndex:range.location+1];

                preString = [regularExpretion1 stringByReplacingMatchesInString:preString options:NSMatchingReportProgress range:NSMakeRange(0, preString.length) withTemplate:@""];
            
                actionString = [NSString stringWithFormat:@"at->%@",actionString];
                NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:NSMakeRange(preString.length+length, range.length-2) replacementString:actionString];
            
                // 截取掉a标签前的字符串（防止a标签名称重复）
                tempString = [tempString substringFromIndex:range.location+1];
            
                // 字符串截取部分的长度
                length += preString.length;
                
//                model.rangeValue = [NSValue valueWithRange:nsra];

                [srcArr addObject:aResult];
                [srcArrs addObject:model];
            }
        }
    }];
    
    return srcArr;
}


#pragma mark 点击图片GestureRecognizer
- (void)imagePressGesture:(QMTapGestureRecognizer *)gestureRecognizer {
    QMChatShowImageViewController * showPicVC = [[QMChatShowImageViewController alloc] init];
    showPicVC.imageUrl = gestureRecognizer.picName;
    showPicVC.picType = gestureRecognizer.picType;
    showPicVC.image = gestureRecognizer.image;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showPicVC animated:true completion:nil];
}

#pragma mark ************* lazy load *************
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.layout = [[QMCustomLayout alloc]init];
        self.layout.minimumLineSpacing = lineSpace;
        self.layout.minimumInteritemSpacing = InteritemSpace;
        self.layout.itemSize = CGSizeMake(115, 40);
        self.layout.sectionInset = UIEdgeInsetsMake(topGap, leftGap, 0, rightGap);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height + 44, QM_kScreenWidth, QM_kScreenHeight - [UIApplication sharedApplication].statusBarFrame.size.height - 44) collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Agent_Dark : QMColor_News_Agent_Light];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark ************* collectionView data *************
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMChatRobotFlowCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlowCollectionCell" forIndexPath:indexPath];
    [cell showData:self.dataSource[indexPath.row]];
    cell.contentView.layer.cornerRadius = 2;
    cell.contentView.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_flowSelset) {
        if (!_flowSend) {
            NSMutableDictionary *dic = self.dataSource[indexPath.row];
            BOOL select = [dic[@"select"] boolValue];
            [dic setValue:[NSNumber numberWithBool:!select] forKey:@"select"];
            [self.dataSource replaceObjectAtIndex:indexPath.row withObject:dic];
            self.tapSelectAction(self.dataSource);
            [_collectionView reloadData];
        }
    }else {
        self.selectAction(self.dataSource[indexPath.row]);
    }
}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(_collectionView.frame);
    NSUInteger page = floor((_collectionView.contentOffset.x - pageWidth/2)/pageWidth) + 1;
    _pageControl.currentPage = page;
}

#pragma mark - MLEmojiLabelDelegate
- (void)mlEmojiLabel:(MLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(MLEmojiLabelLinkType)type {
//    NSLog(@"%@, %lu", link, (unsigned long)type);
    if (type == MLEmojiLabelLinkTypePhoneNumber) {
        if (link) {
            self.tapFlowNumberAction(link);
        }
    }else if (type == MLEmojiLabelLinkTypeAt) {
        for (QMLabelText *model in srcArrs) {
            NSString *matchStr = [NSString stringWithFormat:@"%@%@",model.type,model.rangeValue];
            if ([matchStr isEqualToString:link]) {
                self.tapFlowUrlAction(model.content);
            }else if ([model.type isEqualToString:link]) {
                self.tapFlowUrlAction(model.content);
                break;
            }
        }
    }else {
        if (link) {
//            self.tapNetAddress(link);
        }
    }
}

@end

@implementation QMChatRobotFlowCollectionCell {
    UILabel *_label;
    
    UIImageView *_imageView;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : QMColor_News_Agent_Light];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:12.0f];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F5F6F7"];
    _label.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#3B3B3B"];
    _label.numberOfLines = 2;
    [self.contentView addSubview:_label];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.image = [UIImage imageNamed:QMChatUIImagePath(@"qm_flow_select")];
    _imageView.hidden = YES;
    [self.contentView addSubview:_imageView];
}

- (void)showData:(NSDictionary *)dic {
    _label.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 40);
    _label.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F5F6F7"];
    _label.textColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_D5D5D5_text : @"#3B3B3B"];

    _imageView.frame = CGRectMake(CGRectGetWidth(self.frame) - 17.6, CGRectGetHeight(self.frame) - 12.6, 17.6, 12.6);
    
    if (dic.count > 0) {
        _label.text = dic[@"button"];
        BOOL select = [dic[@"select"] boolValue];
        if (select) {
            _label.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_News_Custom : QMColor_News_Custom alpha:0.1];
        }else {
            _label.backgroundColor = [UIColor colorWithHexString:isDarkStyle ? QMColor_3D3D3D_text : @"#F5F6F7"];
        }
        _imageView.hidden = !select;
    }else {
        _label.text = @"";
    }
}

@end

