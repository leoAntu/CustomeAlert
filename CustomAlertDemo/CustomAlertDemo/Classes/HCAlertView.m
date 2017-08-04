//
//  HCCustomAlertView.m
//
//  Created by hc on 16/6/7.
//  Copyright © 2016年 hc. All rights reserved.
//

#import "HCAlertView.h"

#define HC_RGB_COLOR(r,g,b)                             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
//AlertView的配置
#define HC_ALERT_VIEW_WIDTH                             270.5
#define HC_ALERT_VIEW_MAX_HEIGHT                        ([UIScreen mainScreen].bounds.size.height)
#define HC_ALERT_VIEW_MIN_HEIGHT                        125.0
#define HC_ALERT_VIEW_HORIZONTAL_PADDING                15
#define HC_ALERT_VIEW_VERTICAL_PADDING                  24
#define HC_ALERT_VIEW_VERTICAL_PADDING_IMAGEANDTITLE    20
#define HC_ALERT_VIEW_VERTICAL_PADDING_TITLEANDMESSAGE  15
#define HC_ALERT_VIEW_BUTTON_HEIGHT                     44
#define HC_ALERT_VIEW_SEPARATOR_HEIGHT                  .5
#define HC_ALERT_MESSAGE_LINESPACE                      4.0
#define HC_ALERT_TITLE_FONT                             [UIFont systemFontOfSize:17]
#define HC_ALERT_MESSAGE_FONT                           [UIFont systemFontOfSize:13]
#define HC_ALTER_BUTTON_FONT                            [UIFont systemFontOfSize:15]
#define HC_ALERT_TITLE_COLOR                            (HC_RGB_COLOR(45,45,55))
#define HC_ALERT_MESSAGE_COLOR                          (HC_RGB_COLOR(130,131,132))
#define HC_ALERT_CONFIRM_BUTTON_COLOR                   (HC_RGB_COLOR(237,77,77))
#define HC_ALERT_NORMAL_BUTTON_COLOR                    (HC_RGB_COLOR(45,45,55))
#define HC_ALERT_SEPARATOR_LINE_COLOR                   (HC_RGB_COLOR(218,218,218))

static NSString *HC_ALERT_CELL_ID = @"cellID";

@interface HCAlertView()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) NSMutableArray *buttonTitles;
@property (copy, nonatomic) NSString *cancelButtonTitle;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (strong, nonatomic) UIImage *alertImage;
@property (strong, nonatomic) UIImage *titleIcon;
@property (strong, nonatomic) UICollectionView *buttonCollection;
@property (strong, nonatomic) UIWindow *showWindow;

@end

@implementation HCAlertView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addKeyboardNotifications];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addKeyboardNotifications];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title titleIcon:(UIImage *)titleIcon message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        _title = title;
        _message = message;
        _alertImage = image;
        _titleIcon = titleIcon;
        _cancelButtonTitle = cancelButtonTitle;
        
        va_list arg_prt;
        NSMutableArray *arg_arr = [NSMutableArray array];
        if (otherButtonTitles)
        {
            [arg_arr addObject:otherButtonTitles];
            id arg;
            va_start(arg_prt, otherButtonTitles);
            while ((arg = va_arg(arg_prt, id)))
            {
                if (!arg)
                {
                    break;
                }
                
                [arg_arr addObject:arg];
            }
            va_end(arg_prt);
        }
        _buttonTitles = arg_arr;
        if (cancelButtonTitle && cancelButtonTitle.length)
        {
            [_buttonTitles insertObject:cancelButtonTitle atIndex:0];
        }
        [self loadSubViews];
    }
    return self;
}

- (instancetype)initWithCustomView:(UIView *)customView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        _customView = customView;
        [self addKeyboardNotifications];
    }
    return self;
}

- (void)loadSubViews
{
    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, HC_ALERT_VIEW_WIDTH, HC_ALERT_VIEW_MIN_HEIGHT)];
    containerView.backgroundColor = [UIColor whiteColor];
    
    //该视图用于放除了按钮之外的视图
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HC_ALERT_VIEW_WIDTH, HC_ALERT_VIEW_MIN_HEIGHT - HC_ALERT_VIEW_BUTTON_HEIGHT - HC_ALERT_VIEW_SEPARATOR_HEIGHT)];
    infoView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:infoView];
    
    CGFloat offsetY = HC_ALERT_VIEW_VERTICAL_PADDING;
    if (_alertImage)
    {
        UIImageView *alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake((HC_ALERT_VIEW_WIDTH - _alertImage.size.width)/2, offsetY, _alertImage.size.width, _alertImage.size.height)];
        alertImageView.image = _alertImage;
        [infoView addSubview:alertImageView];
        offsetY = CGRectGetMaxY(alertImageView.frame) + HC_ALERT_VIEW_VERTICAL_PADDING_IMAGEANDTITLE;
    }
    
    if (_title && _title.length > 1)
    {
        CGSize titleSize;
        NSMutableAttributedString *attributeTitle;
        if (_titleIcon)
        {
            HCTextAttachment *textAttachment = [[HCTextAttachment alloc] initWithData:nil ofType:nil];
            UIImage * aImage = _titleIcon;
            textAttachment.image = aImage;
            attributeTitle = [[NSMutableAttributedString alloc] initWithString:_title attributes:@{NSForegroundColorAttributeName:HC_ALERT_TITLE_COLOR,NSFontAttributeName:HC_ALERT_TITLE_FONT}];
            NSAttributedString * textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            NSAttributedString *spaceAttributeText = [[NSAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:HC_ALERT_TITLE_FONT}];
            [attributeTitle insertAttributedString:textAttachmentString atIndex:0];
            //设置图片与文字的距离
            [attributeTitle insertAttributedString:spaceAttributeText atIndex:1];
            titleSize = [attributeTitle boundingRectWithSize:CGSizeMake(HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_HORIZONTAL_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
        }else
        {
            titleSize = [_title boundingRectWithSize:CGSizeMake(HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_HORIZONTAL_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:HC_ALERT_TITLE_FONT} context:nil].size;
        }
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(HC_ALERT_VIEW_HORIZONTAL_PADDING, offsetY, HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_HORIZONTAL_PADDING*2, titleSize.height)];
        titleLabel.font = HC_ALERT_TITLE_FONT;
        titleLabel.textColor = HC_ALERT_TITLE_COLOR;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        if (_titleIcon)
        {
            titleLabel.attributedText = attributeTitle;
        }else
        {
            titleLabel.text = _title;
        }
        [infoView addSubview:titleLabel];
        offsetY = CGRectGetMaxY(titleLabel.frame);
        if (_message && _message.length > 1)
        {
            offsetY += HC_ALERT_VIEW_VERTICAL_PADDING_TITLEANDMESSAGE;
        }else
        {
            offsetY += HC_ALERT_VIEW_VERTICAL_PADDING;
        }
    }
    
    if (_message && _message.length > 1)
    {
        //设置message的段落格式，行间距的设置
        NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
        pStyle.lineBreakMode = NSLineBreakByWordWrapping;
        pStyle.alignment = NSTextAlignmentCenter;
        pStyle.lineSpacing = HC_ALERT_MESSAGE_LINESPACE;
        
        NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:_message attributes:@{NSParagraphStyleAttributeName:pStyle,NSFontAttributeName:HC_ALERT_MESSAGE_FONT}];
        CGSize messageSize = [attributedMessage boundingRectWithSize:CGSizeMake(HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_HORIZONTAL_PADDING*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(HC_ALERT_VIEW_HORIZONTAL_PADDING, offsetY, HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_HORIZONTAL_PADDING*2, messageSize.height)];
        messageLabel.font = HC_ALERT_MESSAGE_FONT;
        messageLabel.textColor = HC_ALERT_MESSAGE_COLOR;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        messageLabel.attributedText = attributedMessage;
        [infoView addSubview:messageLabel];
        offsetY = CGRectGetMaxY(messageLabel.frame);
        offsetY += HC_ALERT_VIEW_VERTICAL_PADDING;
    }
    
    //计算infoView + buttonsView的高度，如果没有达到视图的最小高度HC_ALERT_VIEW_MIN_HEIGHT，就重新infoView的位置
    CGRect infoViewFrame = infoView.frame;
    infoViewFrame.size.height = offsetY;
    infoView.frame = infoViewFrame;
    
    CGFloat buttonsHeight = [self buttonsViewHeight];
    if (offsetY + buttonsHeight + HC_ALERT_VIEW_SEPARATOR_HEIGHT < HC_ALERT_VIEW_MIN_HEIGHT)
    {
        CGFloat infoViewMinHeight = HC_ALERT_VIEW_MIN_HEIGHT - buttonsHeight - HC_ALERT_VIEW_SEPARATOR_HEIGHT;
        CGPoint infoViewCenter = infoView.center;
        infoViewCenter.y = infoViewMinHeight/2;
        infoView.center = infoViewCenter;
        offsetY = infoViewMinHeight;
    }
    
    [containerView addSubview:self.buttonCollection];
    CGRect collectionViewFrame = self.buttonCollection.frame;
    collectionViewFrame.origin.y = offsetY + HC_ALERT_VIEW_SEPARATOR_HEIGHT;
    self.buttonCollection.frame = collectionViewFrame;
    offsetY = CGRectGetMaxY(self.buttonCollection.frame);
    
    //计算整个视图的高度，如果高度超过了HC_ALERT_VIEW_MAX_HEIGHT 重新设置containerView的frame
    if (offsetY > HC_ALERT_VIEW_MAX_HEIGHT)
    {
        containerView.contentSize = CGSizeMake(HC_ALERT_VIEW_WIDTH, offsetY);
        containerView.scrollEnabled = YES;
        offsetY = HC_ALERT_VIEW_MAX_HEIGHT;
    }else
    {
        containerView.scrollEnabled = NO;
    }
    CGRect containerViewFrame = containerView.frame;
    containerViewFrame.size.height = offsetY;
    containerView.frame = containerViewFrame;
    containerView.layer.cornerRadius = 4;
    containerView.clipsToBounds = YES;
    self.customView = containerView;
}

- (void)setCustomView:(UIView *)customView
{
    _customView = customView;
    if (_customView)
    {
        CGRect customViewFrame = _customView.frame;
        customViewFrame.size = CGSizeMake(MIN(customView.frame.size.width, self.frame.size.width), MIN(customView.frame.size.height, self.frame.size.height));
        _customView.frame = customViewFrame;
    }
}

#pragma mark - Action

- (void)buttonActionHandle:(UIButton *)sender
{
    if (self.buttonAction)
    {
        self.buttonAction(sender.tag);
    }
    [self hide];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger buttonCount = _buttonTitles.count;
    return buttonCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCAlertButtonItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HC_ALERT_CELL_ID forIndexPath:indexPath];
    [cell.buttonItem setTitle:_buttonTitles[indexPath.row] forState:UIControlStateNormal];
    cell.buttonItem.tag = indexPath.row;
    [cell.buttonItem addTarget:self action:@selector(buttonActionHandle:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == 0)
    {
        if (_cancelButtonTitle && _cancelButtonTitle.length)
        {
            [cell.buttonItem setTitleColor:HC_ALERT_NORMAL_BUTTON_COLOR forState:UIControlStateNormal];
        }else if(_buttonTitles.count ==1)
        {
            [cell.buttonItem setTitleColor:HC_ALERT_CONFIRM_BUTTON_COLOR forState:UIControlStateNormal];
        }else
        {
            [cell.buttonItem setTitleColor:HC_ALERT_NORMAL_BUTTON_COLOR forState:UIControlStateNormal];
        }
    }else
    {
        if (_buttonTitles.count == 2)
        {
            [cell.buttonItem setTitleColor:HC_ALERT_CONFIRM_BUTTON_COLOR forState:UIControlStateNormal];
        }else
        {
            [cell.buttonItem setTitleColor:HC_ALERT_NORMAL_BUTTON_COLOR forState:UIControlStateNormal];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger btnCount = _buttonTitles.count;
    if (btnCount <= 1)
    {
        return CGSizeMake(HC_ALERT_VIEW_WIDTH, HC_ALERT_VIEW_BUTTON_HEIGHT);
    }else if (btnCount == 2)
    {
        return CGSizeMake((HC_ALERT_VIEW_WIDTH - HC_ALERT_VIEW_SEPARATOR_HEIGHT)/2, HC_ALERT_VIEW_BUTTON_HEIGHT);
    }else
    {
        return CGSizeMake(HC_ALERT_VIEW_WIDTH, HC_ALERT_VIEW_BUTTON_HEIGHT);
    }
}

#pragma mark - Notification

- (void)addKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)onKeyboardShow:(NSNotification *)notification
{
    if(notification)
    {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        double animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
        UIView *view = [self currentFirstResponderTextFiledOrTextView];
        if (view)
        {
            CGRect viewFromToSelf = [view convertRect:view.frame toView:self];
            CGFloat viewBottom = CGRectGetMaxY(viewFromToSelf);
            if (viewBottom + keyboardHeight > [UIScreen mainScreen].bounds.size.height)
            {
                CGPoint customViewCenter = self.customView.center;
                customViewCenter.y -= viewBottom + keyboardHeight - [UIScreen mainScreen].bounds.size.height;
                [UIView animateWithDuration:animationDuration animations:^{
                    self.customView.center = self.center;
                    self.customView.center = customViewCenter;
                }];
            }
        }
    }
}

- (void)onKeyboardHide:(NSNotification *)notification
{
    if (notification)
    {
        NSDictionary* keyboardInfo = [notification userInfo];
        double animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIView *view = [self currentFirstResponderTextFiledOrTextView];
        if (view)
        {
            CGPoint customViewCenter = self.customView.center;
            [UIView animateWithDuration:animationDuration animations:^{
                self.customView.center = customViewCenter;
                self.customView.center = self.center;
            }];
        }

    }
}

#pragma mark - Show&&Hide

- (void)show
{
    [self show:YES];
}

- (void)show:(BOOL)animated
{
    _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [_maskView addSubview:self.customView];
    self.customView.center = _maskView.center;
    [self addSubview:_maskView];
    __weak typeof(self) weakSelf = self;
    [weakSelf.showWindow addSubview:self];
    [weakSelf.showWindow makeKeyAndVisible];
    if (animated)
    {
        [self showWithAnimation];
    }
}

- (void)hide
{
    for (UIView *view in _customView.subviews)
    {
        [view removeFromSuperview];
    }
    [_customView removeFromSuperview];
    _customView = nil;
    
    for (UIView *view in _maskView.subviews)
    {
        [view removeFromSuperview];
    }
    [_maskView removeFromSuperview];
    _maskView = nil;
    [self removeFromSuperview];
}

- (void)showWithAnimation
{
    CAKeyframeAnimation *customViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    customViewAnimation.duration = 0.25;
    customViewAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05f, 1.05f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    customViewAnimation.keyTimes = @[@0.0f,@0.05f, @0.2f];
    customViewAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_customView.layer addAnimation:customViewAnimation forKey:nil];
}

#pragma mark - Private Methods

/**
 *  当前响应的textFiled或者textView
 *
 *  @return 当前响应的textFiled或者textView
 */
- (UIView *)currentFirstResponderTextFiledOrTextView
{
    for (UIView *view in _customView.subviews)
    {
        if (([view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UITextField class]]) && [view isFirstResponder])
        {
            return view;
        }
    }
    return nil;
}

- (CGFloat)buttonsViewHeight
{
    NSInteger btnCount = _buttonTitles.count;
    if (btnCount == 0)
    {
        return 0;
    }else if (btnCount <= 2)
    {
        return HC_ALERT_VIEW_BUTTON_HEIGHT + HC_ALERT_VIEW_SEPARATOR_HEIGHT;
    }else
    {
        return HC_ALERT_VIEW_BUTTON_HEIGHT*btnCount + HC_ALERT_VIEW_SEPARATOR_HEIGHT*(btnCount-1);
    }
}

#pragma mark - Getter && Setter

- (UICollectionView *)buttonCollection
{
    if (!_buttonCollection)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = HC_ALERT_VIEW_SEPARATOR_HEIGHT;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(HC_ALERT_VIEW_SEPARATOR_HEIGHT, 0, HC_ALERT_VIEW_SEPARATOR_HEIGHT, 0);
        _buttonCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, HC_ALERT_VIEW_WIDTH, [self buttonsViewHeight]) collectionViewLayout:flowLayout];
        _buttonCollection.delegate = self;
        _buttonCollection.dataSource = self;
        _buttonCollection.backgroundColor = HC_ALERT_SEPARATOR_LINE_COLOR;
        [_buttonCollection registerClass:[HCAlertButtonItem class] forCellWithReuseIdentifier:HC_ALERT_CELL_ID];
        _buttonCollection.scrollEnabled = NO;
    }
    return _buttonCollection;
}

- (UIWindow *)showWindow
{
    if(_showWindow == nil)
    {
        _showWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _showWindow.windowLevel = UIWindowLevelNormal + 1;
    }
    return _showWindow;
}

@end

@implementation HCAlertButtonItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _buttonItem = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonItem.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_buttonItem setTitleColor:HC_ALERT_NORMAL_BUTTON_COLOR forState:UIControlStateNormal];
        [_buttonItem.titleLabel setFont:HC_ALTER_BUTTON_FONT];
        [self.contentView addSubview:_buttonItem];
    }
    return self;
}
@end


@implementation HCTextAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0, -4, lineFrag.size.height, lineFrag.size.height);
}

@end
