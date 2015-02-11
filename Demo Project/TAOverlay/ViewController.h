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

#import <UIKit/UIKit.h>
#import "TAOverlay.h"


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSMutableArray *items;
    
    
    UIButton *noString;
    UIButton *smallString;
    UIButton *longString;
    
    UIButton *bar;
    UIButton *fullscreen;
    UIButton *rect;
    
    UIButton *opaque;
    
    UIButton *dismiss;
    
    BOOL showBar;
    BOOL showFullscreen;
    BOOL showRect;
    BOOL showOpaque;
    
    UIView *buttonsView;
    
    CGFloat heightControl;

}

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSString *status;

@end

