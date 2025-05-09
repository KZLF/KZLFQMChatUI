//
//  QMPickedVideoViewController.m
//  IMSDK-OC
//
//  Created by HCF on 16/8/10.
//  Copyright © 2016年 HCF. All rights reserved.
//

#import "QMPickedVideoViewController.h"
#import "QMHeader.h"
#import <Photos/Photos.h>
#import "QMVideoTableCell.h"
#import "QMFileTabbarView.h"

@interface QMPickedVideoViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
    PHFetchResult *_photoAssets;
    PHCachingImageManager *_cacheManager;
    
    QMFileTabbarView *_tabbarView;
    CGFloat _navHeight;
}

@property (nonatomic, strong) NSMutableSet *pickedImageSet;

@end

@implementation QMPickedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect StatusRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect NavRect = self.navigationController.navigationBar.frame;
    _navHeight = StatusRect.size.height + NavRect.size.height;

    self.view.backgroundColor = [UIColor whiteColor];
    _cacheManager = [[PHCachingImageManager alloc] init];
    self.pickedImageSet = [[NSMutableSet alloc] init];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, QM_kScreenWidth, QM_kScreenHeight-_navHeight-44) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[QMVideoTableCell class] forCellReuseIdentifier:NSStringFromClass(QMVideoTableCell.self)];
    
    _tabbarView = [[QMFileTabbarView alloc] init];
    _tabbarView.frame = CGRectMake(0, QM_kScreenHeight-44-_navHeight, QM_kScreenWidth, 44);
    [self.view addSubview:_tabbarView];
    
    __weak typeof(self)weakSelf = self;
    _tabbarView.selectAction = ^{
        Class chatRoomClass = NSClassFromString(@"QMChatRoomViewController");
        for (UIViewController *viewController in weakSelf.navigationController.viewControllers) {
            if ([viewController isKindOfClass:chatRoomClass]) {
                [weakSelf.navigationController popToViewController:viewController animated:true];
                
                for (PHAsset *asset in weakSelf.pickedImageSet) {
//                    [QMPushManager share].asset = asset;
                    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHVideoRequestOptionsVersionOriginal;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                    options.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
                        
                        NSURL *videoURL = [(AVURLAsset *)avasset URL];
                        
                        // name
                        NSString *photoPath = videoURL.absoluteString;
        
                        NSRange range = [photoPath rangeOfString:@"#" options:NSBackwardsSearch];
                        if (range.length > 0) {
                            photoPath = [photoPath substringToIndex:range.location].lowercaseString;
                        }
                        
                        NSArray *array = [photoPath componentsSeparatedByString:@"/"];
                        
                        //                        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
                        // data
                        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
                        
                        // size
                        NSString *fileSize = [videoData length]<1024*1024 ? [NSString stringWithFormat:@"%d KB", (int)([videoData length]/1024.0)] : [NSString stringWithFormat:@"%d MB", (int)([videoData length]/1024.0/1024)];
                        
                        // filePath
                        NSString * filePath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], array.lastObject];
                        [videoData writeToFile:filePath atomically:YES];
                        
                        if (weakSelf.callBackBlock) {
                            weakSelf.callBackBlock(array.lastObject, fileSize, array.lastObject);
                        }
                    }];
                }
            }
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        self->_photoAssets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
        [self->_tableView reloadData];
    });
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset name:(NSString *)name completion:(void (^)(NSString *outputPath))completion {
    // Find compatible presets by video asset.
//    NSLog(@"%@", videoAsset);
    
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    if ([presets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
        NSString * outputPath = [NSString stringWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], name];
        
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"]]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/tmp"] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
        if (videoComposition.renderSize.width) {
            // 修正视频转向
            session.videoComposition = videoComposition;
        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (session.status) {
                case AVAssetExportSessionStatusCompleted: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion(outputPath);
                        }
                    });
                }  break;
                default: {
                    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
                        if (completion) {
                            completion(outputPath);
                        }
                    }else {
                        completion(nil);
                    }
                }
                break;
            }
        }];
    }
}

/// 获取优化后的视频转向信息
- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

/// 获取视频角度
- (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

- (void)dealloc {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoAssets ? _photoAssets.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMVideoTableCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QMVideoTableCell.self) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[QMVideoTableCell class]]) {
        QMVideoTableCell * displayCell = (QMVideoTableCell *)cell;
        displayCell.imageManager = _cacheManager;
        if (_photoAssets) {
            PHAsset *asset = _photoAssets[indexPath.row];
            displayCell.imageAsset = asset;
            displayCell.pickedItemImageView.hidden = ![self.pickedImageSet containsObject:asset];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_photoAssets) {
        PHAsset *asset = _photoAssets[indexPath.row];
        if ([self.pickedImageSet containsObject:asset]) {
            [self.pickedImageSet removeObject:asset];
        }else {
            if (self.pickedImageSet.count>0) {
                return;
            }
            [self.pickedImageSet addObject:asset];
        }
        
        QMVideoTableCell * cell = (QMVideoTableCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.pickedItemImageView.hidden = ![self.pickedImageSet containsObject:asset];
    }
    
    if (self.pickedImageSet.count>0) {
        _tabbarView.doneButton.selected = YES;
    }else {
        _tabbarView.doneButton.selected = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
