//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
// TAOverlay
// Copyright (c) 2015 TAIMUR AYAZ
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

#if !__has_feature(objc_arc)
#error TAOverlay is ARC only. Please turn on ARC for the project or use -fobjc-arc flag
#endif

#import "TAOverlay.h"

NSString * const TAOverlayWillDisappearNotification = @"TAOverlayWillDisappearNotification";
NSString * const TAOverlayDidDisappearNotification  = @"TAOverlayDidDisappearNotification";
NSString * const TAOverlayWillAppearNotification    = @"TAOverlayWillAppearNotification";
NSString * const TAOverlayDidAppearNotification     = @"TAOverlayDidAppearNotification";

NSString * const TAOverlayLabelTextUserInfoKey      = @"TAOverlayLabelTextUserInfoKey";

#pragma mark UIImage Category Implementation

@implementation UIImage (TAOverlay)

- (UIImage *) maskImageWithColor:(UIColor *)color
{
    NSParameterAssert(color != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end


#pragma mark TAOverlay Implementation

@implementation TAOverlay

@synthesize interaction, showBackground, showBlurred, shouldHide, background, window, overlay, spinner, image, label, icon, overlayType, overlaySize, imageArray, iconImage, labelText, customAnimationDuration, swipeUpDownGesture, swipeLeftRightGesture, tapGesture;

+ (TAOverlay *)shared
{
	static dispatch_once_t once = 0;
	static TAOverlay *tAOverlay;
 	dispatch_once(&once, ^{ tAOverlay = [[TAOverlay alloc] init]; });
 	return tAOverlay;
}

#pragma mark Show/Hide Methods

+ (void)hideOverlay
{
	[[self shared] overlayHide];
}

+ (void)showOverlayWithLabel:(NSString *)status Options:(TAOverlayOptions)options {
    
    [self shared].labelText  = status;
    [[self shared] analyzeOptions:options image:NO imageArray:NO];

}

+ (void)showOverlayWithLabel:(NSString *)status Image:(UIImage *)image Options:(TAOverlayOptions)options {

    NSParameterAssert(image != nil);
    
    [self shared].labelText  = status;
    [self shared].iconImage = image;
    [[self shared] analyzeOptions:options image:YES imageArray:NO];
}

+ (void)showOverlayWithLabel:(NSString *)status ImageArray:(NSArray *)imageArray Duration:(CGFloat)duration Options:(TAOverlayOptions)options {
    
    NSParameterAssert(imageArray != nil);
    
    [self shared].customAnimationDuration = duration;
    [self shared].labelText  = status;
    [self shared].imageArray = imageArray;
    [[self shared] analyzeOptions:options image:NO imageArray:YES];
}

#pragma mark Customization Methods

+ (void)setOverlayBackgroundColor:(UIColor *)color {
    
    if (color != nil && ![self shared].showBlurred)
    {
        [self shared].overlayBackgroundColor = color;
    }
    else
    {
        [self shared].overlayBackgroundColor = OVERLAY_BACKGROUND_COLOR;
    }
}

+ (void)setOverlayLabelFont:(UIFont *)font {
    
    if (font != nil)
    {
        [self shared].overlayFont = font;
    }
    else
    {
        [self shared].overlayFont = OVERLAY_LABEL_FONT;
    }
}

+ (void)setOverlayLabelTextColor:(UIColor *)color {
    
    if (color != nil)
    {
        [self shared].overlayFontColor = color;
    }
    else
    {
        [self shared].overlayFontColor = OVERLAY_LABEL_COLOR;
    }
}

+ (void)setOverlayShadowColor:(UIColor *)color {
    
    if (color != nil && [self shared].showBackground)
    {
        [self shared].overlayShadowColor = color;
    }
    else
    {
        [self shared].overlayShadowColor = OVERLAY_SHADOW_COLOR;
    }
}

- (id)init
{
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
 	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    
 	if ([delegate respondsToSelector:@selector(window)])
    {
        window = [delegate performSelector:@selector(window)];
    }
	else
    {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    background            = nil;
    overlay               = nil;
    icon                  = nil;
    spinner               = nil;
    image                 = nil;
    label                 = nil;
    tapGesture            = nil;
    swipeUpDownGesture    = nil;
    swipeLeftRightGesture = nil;
    self.alpha            = 0;
    
 	return self;
}

- (void) analyzeOptions:(TAOverlayOptions)options image:(BOOL)hasImage imageArray:(BOOL)hasImageArray {

    self.options = options;
    
    if (!hasImage && !hasImageArray)
    {
        if (OptionPresent(options, TAOverlayOptionOverlayTypeSuccess))
        {
            self.overlayType = tOverlayTypeSucess;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeActivityDefault))
        {
            self.overlayType = tOverlayTypeActivityDefault;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeActivityLeaf))
        {
            self.overlayType = tOverlayTypeActivityLeaf;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeActivityBlur))
        {
            self.overlayType = tOverlayTypeActivityBlur;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeActivitySquare))
        {
            self.overlayType = tOverlayTypeActivitySquare;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeWarning))
        {
            self.overlayType = tOverlayTypeWarning;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeError))
        {
            self.overlayType = tOverlayTypeError;
        }
        else if (OptionPresent(options, TAOverlayOptionOverlayTypeInfo))
        {
            self.overlayType = tOverlayTypeInfo;
        }
        else
        {
            self.overlayType = tOverlayTypeActivityLeaf;
        }
    }
    else if (hasImage && !hasImageArray)
    {
        self.overlayType = tOverlayTypeImage;
    }
    else if (!hasImage && hasImageArray)
    {
        self.overlayType = tOverlayTypeImageArray;
    }

    if (OptionPresent(options, TAOverlayOptionOverlaySizeFullScreen))
    {
        self.overlaySize = tOverlaySizeFullScreen;
    }
    else if (OptionPresent(options, TAOverlayOptionOverlaySizeBar))
    {
        self.overlaySize = tOverlaySizeBar;
    }
    else if (OptionPresent(options, TAOverlayOptionOverlaySizeRoundedRect))
    {
        self.overlaySize = tOverlaySizeRoundedRect;
    }
    else
    {
        self.overlaySize = tOverlaySizeBar;
    }
    
    if (OptionPresent(options, TAOverlayOptionOpaqueBackground))
    {
        self.showBlurred = NO;
    }
    else
    {
        self.showBlurred = YES;
    }
    
    if (OptionPresent(options, TAOverlayOptionOverlayShadow))
    {
        self.showBackground = YES;
    }
    else
    {
        self.showBackground = NO;
    }
    
    if (OptionPresent(options, TAOverlayOptionAllowUserInteraction))
    {
        self.interaction    = NO;
    }
    else
    {
        self.interaction    = YES;
        if (OptionPresent(options, TAOverlayOptionOverlayDismissTap))
        {
            self.userDismissTap = YES;
        }
        else
        {
            self.userDismissTap = NO;
        }
        if (OptionPresent(options, TAOverlayOptionOverlayDismissSwipeDown) | OptionPresent(options, TAOverlayOptionOverlayDismissSwipeUp) | OptionPresent(options, TAOverlayOptionOverlayDismissSwipeLeft) | OptionPresent(options, TAOverlayOptionOverlayDismissSwipeRight))
        {
            self.userDismissSwipe = YES;
        }
        else
        {
            self.userDismissSwipe = NO;
        }
    }
    
    if (OptionPresent(options, TAOverlayOptionAutoHide))
    {
        self.shouldHide = YES;
    }
    else
    {
        self.shouldHide = NO;
    }
    
    [self setProperties];
    
    [self overlayMake:self.labelText];
}

- (void) setProperties {
    
    if (_overlayFont == nil)
    {
        _overlayFont = OVERLAY_LABEL_FONT;
    }
    if (_overlayFontColor == nil)
    {
        _overlayFontColor = OVERLAY_LABEL_COLOR;
    }
    if (_overlayBackgroundColor == nil)
    {
        _overlayBackgroundColor = OVERLAY_BACKGROUND_COLOR;
    }
    if (_overlayShadowColor == nil)
    {
        _overlayShadowColor = OVERLAY_SHADOW_COLOR;
    }
}

- (void)overlayMake:(NSString *)status
{
	[self overlayCreate];
    
     switch (overlayType) {
             
         case tOverlayTypeSucess:
             icon.path = [self bezierPathOfCheckSymbolWithRect:CGRectMake(0, 0, 40, 40) scale:0.5 thick:OVERLAY_ICON_THICKNESS].CGPath;
             icon.fillColor = icon.borderColor = OVERLAY_SUCCESS_COLOR.CGColor;
             [image removeFromSuperview];   image = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview]; spinner = nil;
             break;
             
         case tOverlayTypeError:
             icon.path = [self bezierPathOfCrossSymbolWithRect:CGRectMake(0, 0, 40, 40) scale:0.5 thick:OVERLAY_ICON_THICKNESS].CGPath;
             icon.fillColor = icon.borderColor = OVERLAY_ERROR_COLOR.CGColor;
             [image removeFromSuperview];   image = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview]; spinner = nil;
             break;
             
         case tOverlayTypeWarning:
             icon.path = [self bezierPathOfExcalmationSymbolWithRect:CGRectMake(0, 0, 40, 40) scale:0.5 thick:OVERLAY_ICON_THICKNESS].CGPath;
             icon.fillColor = icon.borderColor = OVERLAY_WARNING_COLOR.CGColor;
             [image removeFromSuperview];   image = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview]; spinner = nil;
             break;
             
         case tOverlayTypeInfo:
             icon.path = [self bezierPathOfInfoSymbolWithRect:CGRectMake(0, 0, 40, 40) scale:0.5 thick:OVERLAY_ICON_THICKNESS].CGPath;
             icon.fillColor = icon.borderColor = OVERLAY_INFO_COLOR.CGColor;
             [image removeFromSuperview];   image = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview]; spinner = nil;
             break;
             
         case tOverlayTypeActivityDefault:
             [icon removeFromSuperlayer];   icon = nil;
             [image removeFromSuperview];   image = nil;
             [spinner startAnimating];
             break;
             
         case tOverlayTypeActivityLeaf:
             [icon removeFromSuperlayer];   icon = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview];    spinner = nil;
             if (image.image != nil) image.image = nil;
             image.frame = CGRectMake(0, 0, 50, 50);
             image.animationImages = OVERLAY_ACTIVITY_LEAF_ARRAY;
             image.animationDuration = 1;
             if (!image.isAnimating) [image startAnimating];
             imageArray = nil;
             break;
             
         case tOverlayTypeActivityBlur:
             [icon removeFromSuperlayer];   icon = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview];    spinner = nil;
             if (image.image != nil) image.image = nil;
             image.frame = CGRectMake(0, 0, 50, 50);
             image.animationImages = OVERLAY_ACTIVITY_BLUR_ARRAY;
             image.animationDuration = 1;
             if (!image.isAnimating) [image startAnimating];
             imageArray = nil;
             break;
             
         case tOverlayTypeActivitySquare:
             [icon removeFromSuperlayer];   icon = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview];    spinner = nil;
             if (image.image != nil) image.image = nil;
             image.frame = CGRectMake(0, 0, 50, 50);
             image.animationImages = OVERLAY_ACTIVITY_SQUARE_ARRAY;
             image.animationDuration = 0.35;
             if (!image.isAnimating) [image startAnimating];
             imageArray = nil;
             break;
             
         case tOverlayTypeImage:
             [icon removeFromSuperlayer];      icon = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview];    spinner = nil;
             if (image.isAnimating) [image stopAnimating];
             if (imageArray != nil) imageArray = nil;
             if (image.image == nil) image.image = iconImage;
             if (image.animationImages != nil) image.animationImages = nil;
             image.frame = CGRectMake(0, 0, 50, 50);
             break;
             
         case tOverlayTypeImageArray:
             [icon removeFromSuperlayer];   icon = nil;
             [spinner stopAnimating];
             [spinner removeFromSuperview];    spinner = nil;
             if (image.image != nil) image.image = nil;
             image.frame = CGRectMake(0, 0, 50, 50);
             image.animationImages = imageArray;
             image.animationDuration = customAnimationDuration;
             if (!image.isAnimating) [image startAnimating];
             imageArray = nil;
             break;
     }
    if (status == nil) {
        [label removeFromSuperview];
        label = nil;
    }
    else {
        label.text = status;
    }

    background.userInteractionEnabled = interaction;
    
    if (showBackground) {
        background.backgroundColor = _overlayShadowColor;
    } else {
        background.backgroundColor = [UIColor clearColor];
    }
    
    if (!showBlurred) {
        overlay.translucent = NO;
        overlay.backgroundColor = [UIColor clearColor];
        overlay.barTintColor = _overlayBackgroundColor;
    } else {
        overlay.translucent = YES;
        overlay.barTintColor = nil;
        overlay.backgroundColor = OVERLAY_BLUR_TINT_COLOR;
    }
    
	[self overlayDimensionsWithNotification:nil];
	[self overlayShow];
 	if (shouldHide) [NSThread detachNewThreadSelector:@selector(autoHide) toTarget:self withObject:nil];
}

- (void)overlayCreate
{
	if (overlay == nil)
	{
		overlay = [[UIToolbar alloc] initWithFrame:CGRectZero];
		overlay.translucent = YES;
		overlay.backgroundColor = [UIColor clearColor];
		overlay.layer.masksToBounds = YES;
		[self registerNotifications];
	}
 	if (overlay.superview == nil)
	{
        if (background == nil)
		{
			background = [[UIView alloc] initWithFrame:window.frame];
            if (showBackground) {
                background.backgroundColor = _overlayShadowColor;
            } else {
                background.backgroundColor = [UIColor clearColor];
            }
            background.alpha = 0.0;
			[window addSubview:background];
			[background addSubview:overlay];
		}
		else [window addSubview:overlay];
        
        if (tapGesture == nil && self.userDismissTap)
        {
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [window addGestureRecognizer:tapGesture];
        }
        
        if (self.userDismissSwipe)
        {
            if (swipeUpDownGesture == nil && (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeUp) | OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeDown)))
            {
                swipeUpDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            
                if (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeUp))
                {
                    swipeUpDownGesture.direction = UISwipeGestureRecognizerDirectionUp;
                }
                if (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeDown))
                {
                    swipeUpDownGesture.direction = (swipeUpDownGesture.direction | UISwipeGestureRecognizerDirectionDown);
                }
                
                [window addGestureRecognizer:swipeUpDownGesture];
            }
            if (swipeLeftRightGesture == nil && (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeLeft) | OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeRight)))
            {
                swipeLeftRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
                
                if (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeLeft))
                {
                    swipeLeftRightGesture.direction = UISwipeGestureRecognizerDirectionLeft;
                }
                if (OptionPresent(self.options, TAOverlayOptionOverlayDismissSwipeRight))
                {
                    swipeLeftRightGesture.direction = (swipeLeftRightGesture.direction | UISwipeGestureRecognizerDirectionRight);
                }
                
                [window addGestureRecognizer:swipeLeftRightGesture];
            }
        }
	}
 	if (spinner == nil)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.color = OVERLAY_ACTIVITY_DEFAULT_COLOR;
		spinner.hidesWhenStopped = YES;
	}
	if (spinner.superview == nil) [overlay addSubview:spinner];
     
     if (icon == nil)
     {
         CGRect layerFrame = CGRectMake(0, 0, 40, 40);
         icon = [CAShapeLayer layer];
         icon.frame = layerFrame;
         icon.borderWidth = OVERLAY_ICON_THICKNESS;
         icon.cornerRadius = 20;
         icon.opacity = 1.0;
     }
     if (icon.superlayer == nil) [overlay.layer addSublayer:icon];
     
 	if (image == nil)
	{
		image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	}
	if (image.superview == nil) [overlay addSubview:image];
 	if (label == nil)
	{
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = _overlayFont;
		label.textColor = _overlayFontColor;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.numberOfLines = 0;
	}
	if (label.superview == nil) [overlay addSubview:label];
}

- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayDimensionsWithNotification:)
												 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayDimensionsWithNotification:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayDimensionsWithNotification:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayDimensionsWithNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayDimensionsWithNotification:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)overlayDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.tapGesture)
    {
        [window removeGestureRecognizer:tapGesture]; tapGesture = nil;
    }
    if (self.swipeUpDownGesture)
    {
        [window removeGestureRecognizer:swipeUpDownGesture]; swipeUpDownGesture = nil;
    }
    if (self.swipeLeftRightGesture)
    {
        [window removeGestureRecognizer:swipeLeftRightGesture]; swipeLeftRightGesture = nil;
    }
 	[label removeFromSuperview];		label = nil;
	[image removeFromSuperview];		image = nil;
	[spinner removeFromSuperview];		spinner = nil;
	[overlay removeFromSuperview];		overlay = nil;
    [icon removeFromSuperlayer];		icon = nil;
	[background removeFromSuperview];	background = nil;
}

- (void)overlayDimensionsWithNotification:(NSNotification *)notification
{
	CGFloat heightKeyboard  = 0;
	NSTimeInterval duration = 0;
    CGRect labelRect = CGRectZero;
    CGFloat overlayWidth, overlayHeight, imagex, imagey;
    
    if (background != nil) background.frame = window.frame;
    
    switch (overlaySize)
    {
        case tOverlaySizeBar:
            
            overlay.layer.cornerRadius = 0;
            overlayWidth  = [[UIScreen mainScreen] bounds].size.width;
            overlayHeight = 100;
            
            if (label.text != nil)
            {
                NSDictionary *attributes = @{NSFontAttributeName:label.font};
                NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
                labelRect = [label.text boundingRectWithSize:CGSizeMake(overlayWidth - 2.0*LABEL_PADDING_X, 300) options:options attributes:attributes context:NULL];
                
                overlayHeight = labelRect.size.height + 80;
                labelRect.origin.x = overlayWidth/2.0 - labelRect.size.width/2.0;
                labelRect.origin.y = LABEL_PADDING_Y;
            }
            overlay.bounds = CGRectMake(0, 0, overlayWidth, overlayHeight);
            imagex = overlayWidth/2;
            imagey = (label.text == nil) ? overlayHeight/2 : 36.0;
            image.center = spinner.center = icon.position = CGPointMake(imagex, imagey);
            label.frame = labelRect;
            
            break;
            
        case tOverlaySizeFullScreen:
            
            overlay.layer.cornerRadius = 0;
            overlayWidth  = [[UIScreen mainScreen] bounds].size.width;
            overlayHeight = [[UIScreen mainScreen] bounds].size.height;
            
            if (label.text != nil)
            {
                NSDictionary *attributes = @{NSFontAttributeName:label.font};
                NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
                labelRect = [label.text boundingRectWithSize:CGSizeMake(overlayWidth - 2.0*LABEL_PADDING_X, 300) options:options attributes:attributes context:NULL];
                
                labelRect.origin.x = overlayWidth/2.0 - labelRect.size.width/2.0;
                labelRect.origin.y = (overlayHeight/2.0) + 16.0;
            }
            overlay.bounds = CGRectMake(0, 0, overlayWidth, overlayHeight);
            imagex = overlayWidth/2;
            imagey = (label.text == nil) ? overlayHeight/2 : (overlayHeight/2.0) - 14.0;
            image.center = spinner.center = icon.position = CGPointMake(imagex, imagey);
            label.frame = labelRect;
            
            break;
            
        case tOverlaySizeRoundedRect:
            
            overlay.layer.cornerRadius = 10;
            overlayWidth  = 100;
            overlayHeight = 100;
            if (label.text != nil)
            {
                NSDictionary *attributes = @{NSFontAttributeName:label.font};
                NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
                labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
                
                overlayHeight = labelRect.size.height + 80;
                overlayWidth = ((labelRect.size.width + 2.0*LABEL_PADDING_X) < 100.0) ? 100.0 : labelRect.size.width + 2.0*LABEL_PADDING_X;
                labelRect.origin.x = overlayWidth/2.0 - labelRect.size.width/2.0;
                labelRect.origin.y = LABEL_PADDING_Y;
            }
            overlay.bounds = CGRectMake(0, 0, overlayWidth, overlayHeight);
            imagex = overlayWidth/2;
            imagey = (label.text == nil) ? overlayHeight/2 : 36.0;
            image.center = spinner.center = icon.position = CGPointMake(imagex, imagey);
            label.frame = labelRect;
            
            break;
    }
    
 	if (notification != nil)
	{
		NSDictionary *info = [notification userInfo];
		CGRect keyboard = [[info valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		duration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		if ((notification.name == UIKeyboardWillShowNotification) || (notification.name == UIKeyboardDidShowNotification))
		{
			heightKeyboard = keyboard.size.height;
		}
	}
	else
    {
        heightKeyboard = [self keyboardHeight];
    }
 	CGRect screen = [UIScreen mainScreen].bounds;
	CGPoint center = CGPointMake(screen.size.width/2, (screen.size.height-heightKeyboard)/2);
 	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^
    {
		overlay.center = CGPointMake(center.x, center.y);
	}
    completion:nil];
}

- (CGFloat)keyboardHeight
{
	for (UIWindow *testWindow in [[UIApplication sharedApplication] windows])
	{
		if ([[testWindow class] isEqual:[UIWindow class]] == NO)
		{
			for (UIView *possibleKeyboard in [testWindow subviews])
			{
				if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"])
				{
					return possibleKeyboard.bounds.size.height;
				}
				else if ([[possibleKeyboard description] hasPrefix:@"<UIInputSetContainerView"])
				{
					for (UIView *hostKeyboard in [possibleKeyboard subviews])
					{
						if ([[hostKeyboard description] hasPrefix:@"<UIInputSetHost"])
						{
							return hostKeyboard.frame.size.height;
						}
					}
				}
			}
		}
	}
	return 0;
}

- (NSDictionary *)getUserInfo{
    return (label.text ? @{TAOverlayLabelTextUserInfoKey : label.text} : nil);
}

- (void)overlayShow
{
	if (self.alpha == 0)
	{
        NSDictionary *userInfo = [self getUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAOverlayWillAppearNotification
                                                            object:nil
                                                          userInfo:userInfo];
		self.alpha = 1;

		overlay.alpha = 0;
		overlay.transform = CGAffineTransformScale(overlay.transform, SCALE_TO, SCALE_TO);

		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
		[UIView animateWithDuration:ANIMATION_DURATION delay:0 options:options animations:^{
			overlay.transform = CGAffineTransformScale(overlay.transform, SCALE_UNITY/SCALE_TO, SCALE_UNITY/SCALE_TO);
			overlay.alpha = 1;
            background.alpha = 1;
        } completion:^(BOOL completion){
            [[NSNotificationCenter defaultCenter] postNotificationName:TAOverlayDidAppearNotification
                                                                object:nil
                                                              userInfo:userInfo];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, label.text);
        }];
	}
}

- (void)overlayHide
{
	if (self.alpha == 1)
	{
        self.willHide = YES;
        
        NSDictionary *userInfo = [self getUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAOverlayWillDisappearNotification
                                                            object:nil
                                                          userInfo:userInfo];
        
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
		[UIView animateWithDuration:ANIMATION_DURATION delay:0 options:options animations:^{
			overlay.transform = CGAffineTransformScale(overlay.transform, SCALE_TO, SCALE_TO);
			overlay.alpha = 0;
            background.alpha = 0;
		}
		completion:^(BOOL finished) {
			[self overlayDestroy];
			self.alpha = 0;
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TAOverlayDidDisappearNotification
                                                                object:nil
                                                              userInfo:userInfo];
		}];
	}
}

- (void)autoHide
{
	@autoreleasepool
	{
        self.willHide = NO;

		double length = label.text.length;
		NSTimeInterval sleep = length * 0.04 + 0.8;
		[NSThread sleepForTimeInterval:sleep];

		dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.willHide)
            {
                [self overlayHide];
            }
		});
	}
}

#pragma mark Gesture Handlers

- (void) handleTap:(UITapGestureRecognizer *)gesture {
    
    if (self.userDismissTap)
    {
        [self overlayHide];
    }
}

- (void) handleSwipe:(UISwipeGestureRecognizer *)gesture {
    
    if (self.userDismissSwipe)
    {
        [self overlayHide];
    }
}

#pragma mark Property Methods

- (void) setOverlayBackgroundColor:(UIColor *)overlayBackgroundColor {
    
    if (overlayBackgroundColor != nil)
    {
        _overlayBackgroundColor = overlayBackgroundColor;
        overlay.barTintColor = _overlayBackgroundColor;
    }
}

- (void)setOverlayFont:(UIFont *)overlayFont {
    
    if (overlayFont != nil)
    {
        _overlayFont = overlayFont;
        label.font = _overlayFont;
        [self overlayDimensionsWithNotification:nil];
    }
}

- (void)setOverlayFontColor:(UIColor *)overlayFontColor {
    
    if (overlayFontColor != nil)
    {
        _overlayFontColor = overlayFontColor;
        label.textColor = _overlayFontColor;
    }
}

- (void)setOverlayShadowColor:(UIColor *)overlayShadowColor {
    
    if (overlayShadowColor != nil) {
        _overlayShadowColor = overlayShadowColor;
        self.background.backgroundColor = _overlayShadowColor;
    }
}

#pragma mark UIBezierPath

- (UIBezierPath *)bezierPathOfInfoSymbolWithRect:(CGRect)rect scale:(CGFloat)scale thick:(CGFloat)thick
{
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat twoThirdHeight = height * 2.f / 3.f;
    CGFloat halfHeight = height / 2.f + (twoThirdHeight - height / 2.f)/2.f;
    CGFloat halfWidth  = width  / 2.f;
    CGFloat size       = height < width ? height : width;
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - size) / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth, (height - halfHeight) - thick * 2), offsetPoint)];
    [path addArcWithCenter:CGPointWithOffset(CGPointMake(halfWidth, (height - halfHeight) - thick * 2), offsetPoint) radius:thick startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, (height - halfHeight)), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + thick/2.0, (height - halfHeight)), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + thick/2.0, height), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, height), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, (height - halfHeight)), offsetPoint)];
    [path closePath];
    return path;
}

- (UIBezierPath *)bezierPathOfExcalmationSymbolWithRect:(CGRect)rect scale:(CGFloat)scale thick:(CGFloat)thick
{
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat twoThirdHeight = height * 2.f / 3.f;
    CGFloat halfHeight = height / 2.f + (twoThirdHeight - height / 2.f)/2.f;
    CGFloat halfWidth  = width  / 2.f;
    CGFloat size       = height < width ? height : width;
    
    CGPoint offsetPoint =
    CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - size) / 2.f,
                CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, 0.f), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + thick/2.0, 0.f), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + thick/2.0, halfHeight), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, halfHeight), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - thick/2.0, 0.f), offsetPoint)];
    [path moveToPoint:CGPointWithOffset(CGPointMake(halfWidth, twoThirdHeight + thick * 3.f/2.f), offsetPoint)];
    [path addArcWithCenter:CGPointWithOffset(CGPointMake(halfWidth, twoThirdHeight + thick * 3.f/2.f), offsetPoint) radius:thick startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [path closePath];
    return path;
}

- (UIBezierPath *)bezierPathOfCheckSymbolWithRect:(CGRect)rect scale:(CGFloat)scale thick:(CGFloat)thick
{
    CGFloat height, width;
    // height : width = 32 : 25
    if (CGRectGetHeight(rect) > CGRectGetWidth(rect)) {
        height = CGRectGetHeight(rect) * scale;
        width  = height * 32.f / 25.f;
    }
    else {
        width  = CGRectGetWidth(rect) * scale;
        height = width * 25.f / 32.f;
    }
    
    CGFloat topPointOffset    = thick / sqrt(2.f);
    CGFloat bottomHeight      = thick * sqrt(2.f);
    CGFloat bottomMarginRight = height - topPointOffset;
    CGFloat bottomMarginLeft  = width - bottomMarginRight;
    
    CGPoint offsetPoint = CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - width) / 2.f,
                                      CGRectGetMinY(rect) + (CGRectGetHeight(rect) - height) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, height - bottomMarginLeft), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(topPointOffset, height - bottomMarginLeft - topPointOffset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(bottomMarginLeft, height - bottomHeight), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - topPointOffset, 0.f), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, topPointOffset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(bottomMarginLeft, height), offsetPoint)];
    [path closePath];
    return path;
}

- (UIBezierPath *)bezierPathOfCrossSymbolWithRect:(CGRect)rect scale:(CGFloat)scale thick:(CGFloat)thick
{
    CGFloat height     = CGRectGetHeight(rect) * scale;
    CGFloat width      = CGRectGetWidth(rect)  * scale;
    CGFloat halfHeight = height / 2.f;
    CGFloat halfWidth  = width  / 2.f;
    CGFloat size       = height < width ? height : width;
    CGFloat offset     = thick / sqrt(2.f);
    
    CGPoint offsetPoint = CGPointMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect)  - size) / 2.f,
                                      CGRectGetMinY(rect) + (CGRectGetHeight(rect) - size) / 2.f);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointWithOffset(CGPointMake(0.f, offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(offset, 0.f), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, halfHeight - offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - offset, 0.f), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth + offset, halfHeight), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width, height - offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(width - offset, height), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth, halfHeight + offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(offset, height), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(0.f, height - offset), offsetPoint)];
    [path addLineToPoint:CGPointWithOffset(CGPointMake(halfWidth - offset, halfHeight), offsetPoint)];
    [path closePath];
    return path;
}

@end
