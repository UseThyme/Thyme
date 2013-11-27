//
//  HYPHomeViewController.m
//  Thyme
//
//  Created by Elvis Nunez on 26/11/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPHomeViewController.h"
#import "HYPPlateCell.h"
#import "HYPUtils.h"

static NSString * const HYPPlateCellIdentifier = @"HYPPlateCellIdentifier";

@interface HYPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *ovenCollectionView;

@property (nonatomic, strong) UIImageView *activeImageView;
@property (nonatomic, strong) UIImageView *unactiveImageView;
@property (nonatomic, strong) UIImageView *timerImageView;
@end

@implementation HYPHomeViewController

- (UIImageView *)timerImageView
{
    if (!_timerImageView) {
        CGFloat sideMargin = 0.0f;
        CGFloat topMargin = 60.0f;//40.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _timerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
        _timerImageView.image = [UIImage imageNamed:@"timer"];
        _timerImageView.alpha = 0.0f;
        _timerImageView.contentMode = UIViewContentModeCenter;
    }
    return _timerImageView;
}

- (UIImageView *)activeImageView
{
    if (!_activeImageView) {
        CGFloat sideMargin = 0.0f;
        CGFloat topMargin = 110.0f;//40.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _activeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
        _activeImageView.image = [UIImage imageNamed:@"activeKitchen"];
        _activeImageView.userInteractionEnabled = YES;
        _activeImageView.contentMode = UIViewContentModeCenter;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activeImageViewPressed)];
        [gesture setNumberOfTouchesRequired:1];
        [gesture setNumberOfTapsRequired:1];
        [_activeImageView addGestureRecognizer:gesture];
    }
    return _activeImageView;
}

- (UIImageView *)unactiveImageView
{
    if (!_unactiveImageView) {
        CGFloat sideMargin = 0.0f;
        CGFloat topMargin = 110.0f;//40.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _unactiveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width)];
        _unactiveImageView.image = [UIImage imageNamed:@"unactiveKitchen"];
        _unactiveImageView.contentMode = UIViewContentModeCenter;
        _unactiveImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unactiveImageViewPressed)];
        [gesture setNumberOfTouchesRequired:1];
        [gesture setNumberOfTapsRequired:1];
        [_unactiveImageView addGestureRecognizer:gesture];
        _unactiveImageView.alpha = 0.0f;
    }
    return _unactiveImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        CGFloat sideMargin = 20.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        CGFloat topMargin = 40.0f;//60.0f;
        CGFloat height = 25.0f;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
        _titleLabel.font = [HYPUtils avenirLightWithSize:12.0f];
        _titleLabel.text = @"YOUR DISH WILL BE DONE IN";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        CGFloat sideMargin = CGRectGetMinX(self.titleLabel.frame);
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        CGFloat topMargin = CGRectGetMaxY(self.titleLabel.frame);
        CGFloat height = CGRectGetHeight(self.titleLabel.frame);
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, height)];
        _subtitleLabel.font = [HYPUtils avenirBlackWithSize:19.0f];
        _subtitleLabel.text = @"ABOUT 20 MINUTES";
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = [UIColor whiteColor];
    }
    return _subtitleLabel;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {

        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = 100.0f;
        [flowLayout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGFloat sideMargin = 50.0f;
        CGFloat topMargin = 50.0f; //110.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width) collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self applyTransformToLayer:_collectionView.layer usingFactor:0.30];
    }
    return _collectionView;
}

- (UICollectionView *)ovenCollectionView
{
    if (!_ovenCollectionView) {

        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellWidth = 120.0f;
        [flowLayout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGFloat sideMargin = 100.0f;
        CGFloat topMargin = 50 + 270.0f;//380.0f;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGFloat width = CGRectGetWidth(bounds) - 2 * sideMargin;
        _ovenCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(sideMargin, topMargin, width, width) collectionViewLayout:flowLayout];
        _ovenCollectionView.dataSource = self;
        _ovenCollectionView.delegate = self;
        _ovenCollectionView.backgroundColor = [UIColor clearColor];
        [self applyTransformToLayer:_ovenCollectionView.layer usingFactor:0.25];
    }
    return _ovenCollectionView;
}

- (void)applyTransformToLayer:(CALayer *)layer usingFactor:(CGFloat)factor
{
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -800.0;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * factor, 1.0f, 0.0f, 0.0f);

    [UIView animateWithDuration:0.5 animations:^{
        layer.anchorPoint = CGPointMake(0.5, 0);
        layer.transform = rotationAndPerspectiveTransform;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;

    //[self.view addSubview:self.titleLabel];
    //[self.view addSubview:self.subtitleLabel];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    //[self.view addSubview:self.unactiveImageView];
    //[self.view addSubview:self.activeImageView];
    //[self.view addSubview:self.timerImageView];
    [self.collectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.ovenCollectionView registerClass:[HYPPlateCell class] forCellWithReuseIdentifier:HYPPlateCellIdentifier];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.ovenCollectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        return 4;
    }

    return 1;
}

- (HYPPlateCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPPlateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HYPPlateCellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYPPlateCell *cell = (HYPPlateCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.active = !cell.isActive;
}

- (void)activeImageViewPressed
{
    CGFloat scale = 0.3;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGPoint center = CGPointMake(self.view.center.x, self.view.center.y + 170.0f);

    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.timerImageView.alpha = 1.0f;
    } completion:NULL];

    [UIView animateWithDuration:0.4 animations:^{
        self.titleLabel.alpha = 0.0f;
        self.subtitleLabel.alpha = 0.0f;
        self.activeImageView.alpha = 0.0f;
        self.unactiveImageView.alpha = 1.0f;
        self.activeImageView.transform = transform;
        self.unactiveImageView.transform = transform;
        self.activeImageView.center = center;
        self.unactiveImageView.center = center;
    } completion:^(BOOL finished) {
        self.unactiveImageView.userInteractionEnabled = YES;
        self.activeImageView.userInteractionEnabled = NO;
    }];
}

- (void)unactiveImageViewPressed
{
    CGFloat scale = 1.0f;
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGPoint center = CGPointMake(160, 270);

    [UIView animateWithDuration:0.35f animations:^{
        self.timerImageView.alpha = 0.0f;
        self.titleLabel.alpha = 1.0f;
        self.subtitleLabel.alpha = 1.0f;
        self.activeImageView.alpha = 1.0f;
        self.unactiveImageView.alpha = 0.0f;
        self.activeImageView.transform = transform;
        self.unactiveImageView.transform = transform;
        self.activeImageView.center = center;
        self.unactiveImageView.center = center;
    } completion:^(BOOL finished) {
        self.unactiveImageView.userInteractionEnabled = NO;
        self.activeImageView.userInteractionEnabled = YES;
    }];
}

@end