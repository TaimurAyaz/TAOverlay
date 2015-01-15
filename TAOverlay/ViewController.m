//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
// ViewController
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

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize mainTableView, status;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotifications) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    heightControl = 170.4;
    
    mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.showsVerticalScrollIndicator = NO;
    mainTableView.showsHorizontalScrollIndicator = NO;
    mainTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:mainTableView];
    
    status = nil;
    
    items = [[NSMutableArray alloc] init];
    [items addObject:@"TAOverlay"];
    [items addObject:@"Activity Default"];
    [items addObject:@"Activity Leaf"];
    [items addObject:@"Activity Blur"];
    [items addObject:@"Activity Square"];
    [items addObject:@"Success"];
    [items addObject:@"Warning"];
    [items addObject:@"Error"];
    [items addObject:@"Information"];
    [items addObject:@"Custom Image"];
    [items addObject:@"Custom Image Array"];
    [items addObject:@""];

    showOpaque     = NO;
    showBar        = YES;
    showFullscreen = NO;
    showRect       = NO;
        
    buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, ((items.count - 2.0)*50 + 100.0), self.view.frame.size.width, heightControl)];
    buttonsView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1.0];
    buttonsView.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonsView.layer.shadowOffset = CGSizeMake(0, 0);
    buttonsView.layer.shadowOpacity = 0.1;
    buttonsView.layer.shadowRadius = 10;
    [self.view addSubview:buttonsView];
    
    opaque = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    opaque.frame = CGRectMake(0, 0, buttonsView.frame.size.width, buttonsView.frame.size.height/4.0);
    opaque.tag = 1;
    [opaque setTitle:@"Toggle Blur: ON" forState:UIControlStateNormal];
    [opaque setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    opaque.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    [opaque addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:opaque];
    
    noString = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    noString.frame = CGRectMake(0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    noString.tag = 2;
    [noString setTitle:@"No Text" forState:UIControlStateNormal];
    noString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    [noString setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [noString addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:noString];
    
    smallString = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    smallString.frame = CGRectMake(buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    smallString.tag = 3;
    [smallString setTitle:@"Small Text" forState:UIControlStateNormal];
    smallString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    [smallString setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [smallString addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:smallString];
    
    longString = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    longString.frame = CGRectMake(buttonsView.frame.size.width*2.0/3.0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    longString.tag = 4;
    [longString setTitle:@"Long Text" forState:UIControlStateNormal];
    longString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    [longString setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [longString addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:longString];
    
    bar = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bar.frame = CGRectMake(0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    bar.tag = 5;
    [bar setTitle:@"Bar" forState:UIControlStateNormal];
    [bar setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bar.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
    [bar addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:bar];
    
    fullscreen = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fullscreen.frame = CGRectMake(buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    fullscreen.tag = 6;
    [fullscreen setTitle:@"Fullscreen" forState:UIControlStateNormal];
    fullscreen.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    [fullscreen setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fullscreen addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:fullscreen];
    
    rect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rect.frame = CGRectMake(buttonsView.frame.size.width*2.0/3.0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    rect.tag = 7;
    [rect setTitle:@"Rectangle" forState:UIControlStateNormal];
    rect.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    [rect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rect addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:rect];
    
    dismiss = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    dismiss.frame = CGRectMake(0, buttonsView.frame.size.height*3.0/4.0, buttonsView.frame.size.width, buttonsView.frame.size.height/4.0);
    dismiss.tag = 8;
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:30];
    [dismiss setTitleColor:OVERLAY_ERROR_COLOR forState:UIControlStateNormal];
    [dismiss addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsView addSubview:dismiss];

}

- (void) handleNotifications {
    
    mainTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        buttonsView.frame = CGRectMake(0, mainTableView.contentSize.height - heightControl - mainTableView.contentOffset.y, self.view.frame.size.width, heightControl);
    }
    else if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        buttonsView.frame = CGRectMake(0, mainTableView.contentSize.height - heightControl - mainTableView.contentOffset.y, self.view.frame.size.width, heightControl);
    }
    
    opaque.frame = CGRectMake(0, 0, buttonsView.frame.size.width, buttonsView.frame.size.height/4.0);
    noString.frame = CGRectMake(0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    smallString.frame = CGRectMake(buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    longString.frame = CGRectMake(buttonsView.frame.size.width*2.0/3.0, buttonsView.frame.size.height/4.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    bar.frame = CGRectMake(0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    fullscreen.frame = CGRectMake(buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    rect.frame = CGRectMake(buttonsView.frame.size.width*2.0/3.0, buttonsView.frame.size.height/2.0, buttonsView.frame.size.width/3.0, buttonsView.frame.size.height/4.0);
    dismiss.frame = CGRectMake(0, buttonsView.frame.size.height*3.0/4.0, buttonsView.frame.size.width, buttonsView.frame.size.height/4.0);

}

- (void) handleTap:(UIButton *)button {
    
    
    
    if (button.tag == 1)
    {
        if (showOpaque)
        {
            showOpaque = NO;
            [opaque setTitle:@"Toggle Blur: ON" forState:UIControlStateNormal];
            opaque.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        }
        else if (!showOpaque)
        {
            showOpaque = YES;
            [opaque setTitle:@"Toggle Blur: OFF" forState:UIControlStateNormal];
            opaque.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        }
    }
    if (button.tag == 2)
    {
        status = nil;
        noString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        smallString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        longString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];

    }
    if (button.tag == 3)
    {
        status = @"Small Text";
        smallString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        noString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        longString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    }
    if (button.tag == 4)
    {
        status = @"This is a very long text string. This is a very long text string. This is a very long text string. This is a very long text string. This is a very long text string.";
        longString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        smallString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        noString.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    }
    if (button.tag == 5)
    {
        showBar        = YES;
        showFullscreen = NO;
        showRect       = NO;
        bar.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        fullscreen.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        rect.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    }
    if (button.tag == 6)
    {
        showBar        = NO;
        showFullscreen = YES;
        showRect       = NO;
        fullscreen.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        bar.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        rect.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    }
    if (button.tag == 7)
    {
        showBar        = NO;
        showFullscreen = NO;
        showRect       = YES;
        rect.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        fullscreen.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
        bar.titleLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    }
    if (button.tag == 8) {
        [TAOverlay hideOverlay];
    }
}

#pragma mark - Table view data source

 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 {
    return 1;
}

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 {
    return [items count];
}

 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
    if (indexPath.row == 0) {
        return 100;
    }
     if (indexPath.row == 11) {
         return heightControl;
     }
    return 50;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = items[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:40];
            cell.imageView.image = nil;
            break;
            
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"spin"];
            break;
            
        case 2:
            cell.imageView.image = [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_ACTIVITY_LEAF_COLOR];
            break;
            
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"blur"];
            break;
            
        case 4:
            cell.imageView.image = [UIImage imageNamed:@"square"];
            break;
            
        case 5:
            cell.imageView.image = [UIImage imageNamed:@"success"];
            break;
            
        case 6:
            cell.imageView.image = [UIImage imageNamed:@"excl"];
            break;
            
        case 7:
            cell.imageView.image = [UIImage imageNamed:@"error"];
            break;
            
        case 8:
            cell.imageView.image = [UIImage imageNamed:@"info"];
            break;
            
        case 9:
            cell.imageView.image = [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_ERROR_COLOR];
            break;
            
        case 10:
            cell.imageView.image = [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_WARNING_COLOR];
            break;
            
        default:
            break;
    }
    

    return cell;
}

#pragma mark - Table view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
    buttonsView.frame = CGRectMake(0, mainTableView.contentSize.height - heightControl - scrollView.contentOffset.y, self.view.frame.size.width, heightControl);
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     
     TAOverlayOptions options = TAOverlayOptionNone;

     if (showOpaque) {
         
         if (showFullscreen)
         {
             options = TAOverlayOptionOpaqueBackground;
         }
         else
         {
             options = TAOverlayOptionOpaqueBackground | TAOverlayOptionOverlayShadow;
         }
     }
     
     
     if (showBar) {
         
         options = options | TAOverlayOptionOverlaySizeBar;
     }
     else if (showFullscreen){
         
         options = options |  TAOverlayOptionOverlaySizeFullScreen | TAOverlayOptionAutoHide;
         
     }
     else if (showRect){
         
         options = options |  TAOverlayOptionOverlaySizeRoundedRect;
         
     }
     
     
     options = options | TAOverlayOptionAllowUserInteraction;
     
     switch (indexPath.row) {
             
         case 1:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeActivityDefault)];
             break;
             
         case 2:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeActivityLeaf)];
             break;
             
         case 3:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeActivityBlur)];
             break;
             
         case 4:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeActivitySquare)];
             break;
             
         case 5:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeSuccess)];
             break;
             
         case 6:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeWarning)];
             break;
             
         case 7:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeError)];
             break;
             
         case 8:
             [TAOverlay showOverlayWithLabel:status Options:(options | TAOverlayOptionOverlayTypeInfo)];
             break;
             
         case 9:
             [TAOverlay showOverlayWithLabel:status Image:[[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_ERROR_COLOR] Options:options];
             break;
             
         case 10:
             [TAOverlay showOverlayWithLabel:status ImageArray:[NSArray arrayWithObjects:
                                                                [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_WARNING_COLOR],
                                                                [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_ERROR_COLOR],
                                                                [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_SUCCESS_COLOR],
                                                                [[UIImage imageNamed:@"TAOverlayImage"] maskImageWithColor:OVERLAY_INFO_COLOR],
                                                                nil] Duration:0.4 Options:options];
             break;
             
         default:
             break;
     }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
