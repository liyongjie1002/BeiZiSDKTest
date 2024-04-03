//
//  ExpressFeedAdViewController.m
//  JHNSDKDemo
//
//  Created by ZJL on 2022/08/03.
//

#import "ExpressFeedAdViewController.h"

@interface ExpressFeedAdViewController ()<JHNFeedAdDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UIButton *loadAdBtn;
@property(nonatomic,strong) JHNFeedAd *jhnFeedAd;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *feedAdAdViews;

@end

@implementation ExpressFeedAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutUI];
}

- (void)layoutUI {
    
    [self.view addSubview:self.tableView];
    [self loadFeedAd];
}

- (void)loadFeedAd {
    [QMUITips showLoadingInView:self.view];
    
    //设置宽度。高度是按宽度自适应，设为0
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 0;

//    self.jhnFeedAd = [[JHNFeedAd alloc] initWithSlotID:@"85ikvtui5f5i" Size:CGSizeMake(width, height)];// 测试
    self.jhnFeedAd = [[JHNFeedAd alloc] initWithSlotID:@"a46e9isj60ni" Size:CGSizeMake(width, height)];// 正式
    self.jhnFeedAd.delegate = self;
    self.jhnFeedAd.videoMuted = YES;
    //拉取广告，count为拉取范围1-3，最大值为3条
    [self.jhnFeedAd loadAdWithCount:3];
}

/**
 This method is called when video ad material loaded successfully.
 */
- (void)JHNFeedAdDidLoad:(NSArray *)feedDataArray{
    
//    NSLog(@"JHN------成功请求到广告数据 %@",feedDataArray);
    self.feedAdAdViews = [NSMutableArray arrayWithArray:feedDataArray];
    [self.tableView reloadData];
    
    [QMUITips hideAllTips];
}

/**
 This method is called when video ad materia failed to load.
 */
- (void)JHNFeedAdFailWithCode:(NSInteger)code TipStr:(NSString *)tipStr ErrorMessage:(NSString *)errorMessage{
    NSLog(@"JHN------[%ld-%@]",code,tipStr);
    [QMUITips hideAllTips];
}

/**
 This method is called when rendering a nativeExpressAdView successed.
 It will happen when ad is show.
 */
- (void)JHNFeedAdViewRenderSuccess{
    NSLog(@"JHN------JHNFeedAdViewRenderSuccess");
    
    //渲染成功 刷新tableview
//    [self.tableView reloadData];
}

- (void)JHNFeedAdViewExposure {
    NSLog(@"JHN------JHNFeedAdViewExposure");
}

/**
 This method is called when video ad is closed.
 */
- (void)JHNFeedAdDidClose:(id)feedAd {
    NSLog(@"JHN------JHNFeedAdDidClose");

    [self.feedAdAdViews removeObject:feedAd];
    [self.tableView reloadData];
}

/**
 This method is called when video ad is clicked.
 */
- (void)JHNFeedAdDidClick{
    NSLog(@"JHN------JHNFeedAdDidClick");
    
    [self recordJHNAd];
}

- (void)recordJHNAd {
    [[BRNetwork sharedInstance] postWithUrltoken:recordJiHuoNiao_URL params:@{} successComplete:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failureComplete:^(NSError *error) {
        
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = self.feedAdAdViews[indexPath.row];
    CGFloat height = view.bounds.size.height;
    return height > 0 ? height: 106;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feedAdAdViews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"jhnFeedAdcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
    if ([subView superview]) {
        [subView removeFromSuperview];
    }
    UIView *view = self.feedAdAdViews[indexPath.row];
    view.tag = 1000;
    [self addAccessibilityIdentifier:view];
    [cell.contentView addSubview:view];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *view = [cell.contentView viewWithTag:1000];
    if (view) {
        [self removeAccessibilityIdentifier:view];
    }
}

- (void)addAccessibilityIdentifier:(UIView *)adView {
    adView.accessibilityIdentifier = @"express_feed_view";
}

- (void)removeAccessibilityIdentifier:(UIView *)adView {
    adView.accessibilityIdentifier = nil;
}

- (NSMutableArray *)feedAdAdViews {
    if (!_feedAdAdViews) {
        _feedAdAdViews = [NSMutableArray array];
    }
    return _feedAdAdViews;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
