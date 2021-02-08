// -----------------------------------------------------------------------------
// Copyright 2013-2019 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Project includes
#import "RightPaneViewController.h"
#import "../boardposition/BoardPositionButtonBoxDataSource.h"
#import "../boardview/BoardViewController.h"
#import "../controller/AutoLayoutConstraintHelper.h"
#import "../controller/NavigationBarController.h"
#import "../controller/StatusViewController.h"
#import "../gameaction/GameActionButtonBoxDataSource.h"
#import "../gameaction/GameActionManager.h"
#import "../../main/MainMenuPresenter.h"
#import "../../shared/LayoutManager.h"
#import "../../ui/AutoLayoutUtility.h"
#import "../../ui/ButtonBoxController.h"
#import "../../ui/UiElementMetrics.h"
#import "../../utility/UIColorAdditions.h"
#import "../../main/ApplicationDelegate.h"
#import "../model/BoardViewModel.h"
#import "../../settings/BoardTheme.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private properties for RightPaneViewController.
// -----------------------------------------------------------------------------
@interface RightPaneViewController()
@property(nonatomic, assign) bool useNavigationBar;
@property(nonatomic, retain) UIView* woodenBackgroundView;
@property(nonatomic, retain) UIView* leftColumnView;
@property(nonatomic, retain) UIView* rightColumnView;
@property(nonatomic, retain) BoardViewController* boardViewController;
@property(nonatomic, retain) ButtonBoxController* boardPositionButtonBoxController;
@property(nonatomic, retain) BoardPositionButtonBoxDataSource* boardPositionButtonBoxDataSource;
@property(nonatomic, retain) ButtonBoxController* gameActionButtonBoxController;
@property(nonatomic, retain) GameActionButtonBoxDataSource* gameActionButtonBoxDataSource;
@property(nonatomic, retain) NSMutableArray* boardViewAutoLayoutConstraints;
@property(nonatomic, retain) NSArray* gameActionButtonBoxAutoLayoutConstraints;
@property(nonatomic, retain) UIButton* mainMenuButton;
@end


@implementation RightPaneViewController

#pragma mark - Initialization and deallocation

// -----------------------------------------------------------------------------
/// @brief Initializes a RightPaneViewController object.
///
/// @note This is the designated initializer of RightPaneViewController.
// -----------------------------------------------------------------------------
- (id) init
{
  // Call designated initializer of superclass (UIViewController)
  self = [super initWithNibName:nil bundle:nil];
  if (! self)
    return nil;
  [self setupUseNavigationBar];
  [self setupChildControllers];
  self.woodenBackgroundView = nil;
  self.leftColumnView = nil;
  self.rightColumnView = nil;
  self.boardViewAutoLayoutConstraints = [NSMutableArray array];
  self.gameActionButtonBoxAutoLayoutConstraints = nil;
  self.mainMenuButton = nil;
  [self setupNotificationResponders];
  return self;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this RightPaneViewController object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  [self removeNotificationResponders];

  self.navigationBarController = nil;

  self.leftColumnView = nil;
  self.rightColumnView = nil;
  self.boardPositionButtonBoxController = nil;
  self.boardPositionButtonBoxDataSource = nil;
  self.gameActionButtonBoxController = nil;
  self.gameActionButtonBoxDataSource = nil;
  self.gameActionButtonBoxAutoLayoutConstraints = nil;
  self.mainMenuButton = nil;

  self.woodenBackgroundView = nil;
  self.boardViewController = nil;
  self.boardViewAutoLayoutConstraints = nil;
  
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Private helper for initializer.
// -----------------------------------------------------------------------------
- (void) setupUseNavigationBar
{
  if ([LayoutManager sharedManager].uiType == UITypePhone)
    self.useNavigationBar = false;
  else
    self.useNavigationBar = true;
}

#pragma mark - Setup/remove notification responders

// -----------------------------------------------------------------------------
/// @brief Private helper.
// -----------------------------------------------------------------------------
- (void) setupNotificationResponders
{
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  [center addObserver:self selector:@selector(boardViewWillDisplayCrossHair:) name:boardViewWillDisplayCrossHair object:nil];
  [center addObserver:self selector:@selector(boardViewWillHideCrossHair:) name:boardViewWillHideCrossHair object:nil];
}

// -----------------------------------------------------------------------------
/// @brief Private helper.
// -----------------------------------------------------------------------------
- (void) removeNotificationResponders
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Container view controller handling

// -----------------------------------------------------------------------------
/// This is an internal helper invoked during initialization.
// -----------------------------------------------------------------------------
- (void) setupChildControllers
{
  if (self.useNavigationBar)
  {
    self.navigationBarController = [NavigationBarController navigationBarController];
  }
  else
  {
    self.boardPositionButtonBoxController = [[[ButtonBoxController alloc] initWithScrollDirection:UICollectionViewScrollDirectionVertical] autorelease];
    self.gameActionButtonBoxController = [[[ButtonBoxController alloc] initWithScrollDirection:UICollectionViewScrollDirectionVertical] autorelease];
  }
  self.boardViewController = [[[BoardViewController alloc] init] autorelease];

  if (! self.useNavigationBar)
  {
    self.boardPositionButtonBoxDataSource = [[[BoardPositionButtonBoxDataSource alloc] init] autorelease];
    self.boardPositionButtonBoxController.buttonBoxControllerDataSource = self.boardPositionButtonBoxDataSource;
    self.gameActionButtonBoxDataSource = [[[GameActionButtonBoxDataSource alloc] init] autorelease];
    self.gameActionButtonBoxDataSource.buttonBoxController = self.gameActionButtonBoxController;
    self.gameActionButtonBoxController.buttonBoxControllerDataSource = self.gameActionButtonBoxDataSource;
    self.gameActionButtonBoxController.buttonBoxControllerDelegate = self;
  }
}

// -----------------------------------------------------------------------------
/// @brief Private setter implementation.
// -----------------------------------------------------------------------------
- (void) setNavigationBarController:(NavigationBarController*)navigationBarController
{
  if (_navigationBarController == navigationBarController)
    return;
  if (_navigationBarController)
  {
    [_navigationBarController willMoveToParentViewController:nil];
    // Automatically calls didMoveToParentViewController:
    [_navigationBarController removeFromParentViewController];
    [_navigationBarController release];
    _navigationBarController = nil;
  }
  if (navigationBarController)
  {
    // Automatically calls willMoveToParentViewController:
    [self addChildViewController:navigationBarController];
    [navigationBarController didMoveToParentViewController:self];
    [navigationBarController retain];
    _navigationBarController = navigationBarController;
  }
}

// -----------------------------------------------------------------------------
/// @brief Private setter implementation.
// -----------------------------------------------------------------------------
- (void) setBoardViewController:(BoardViewController*)boardViewController
{
  if (_boardViewController == boardViewController)
    return;
  if (_boardViewController)
  {
    [_boardViewController willMoveToParentViewController:nil];
    // Automatically calls didMoveToParentViewController:
    [_boardViewController removeFromParentViewController];
    [_boardViewController release];
    _boardViewController = nil;
  }
  if (boardViewController)
  {
    // Automatically calls willMoveToParentViewController:
    [self addChildViewController:boardViewController];
    [boardViewController didMoveToParentViewController:self];
    [boardViewController retain];
    _boardViewController = boardViewController;
  }
}

// -----------------------------------------------------------------------------
/// @brief Private setter implementation.
// -----------------------------------------------------------------------------
- (void) setBoardPositionButtonBoxController:(ButtonBoxController*)boardPositionButtonBoxController
{
  if (_boardPositionButtonBoxController == boardPositionButtonBoxController)
    return;
  if (_boardPositionButtonBoxController)
  {
    [_boardPositionButtonBoxController willMoveToParentViewController:nil];
    // Automatically calls didMoveToParentViewController:
    [_boardPositionButtonBoxController removeFromParentViewController];
    [_boardPositionButtonBoxController release];
    _boardPositionButtonBoxController = nil;
  }
  if (boardPositionButtonBoxController)
  {
    // Automatically calls willMoveToParentViewController:
    [self addChildViewController:boardPositionButtonBoxController];
    [boardPositionButtonBoxController didMoveToParentViewController:self];
    [boardPositionButtonBoxController retain];
    _boardPositionButtonBoxController = boardPositionButtonBoxController;
  }
}

// -----------------------------------------------------------------------------
/// @brief Private setter implementation.
// -----------------------------------------------------------------------------
- (void) setGameActionButtonBoxController:(ButtonBoxController*)gameActionButtonBoxController
{
  if (_gameActionButtonBoxController == gameActionButtonBoxController)
    return;
  if (_gameActionButtonBoxController)
  {
    [_gameActionButtonBoxController willMoveToParentViewController:nil];
    // Automatically calls didMoveToParentViewController:
    [_gameActionButtonBoxController removeFromParentViewController];
    [_gameActionButtonBoxController release];
    _gameActionButtonBoxController = nil;
  }
  if (gameActionButtonBoxController)
  {
    // Automatically calls willMoveToParentViewController:
    [self addChildViewController:gameActionButtonBoxController];
    [gameActionButtonBoxController didMoveToParentViewController:self];
    [gameActionButtonBoxController retain];
    _gameActionButtonBoxController = gameActionButtonBoxController;
  }
}

#pragma mark - UIViewController overrides

// -----------------------------------------------------------------------------
/// @brief UIViewController method.
// -----------------------------------------------------------------------------
- (void) loadView
{
  [super loadView];
  [self setupViewHierarchy];
  [self setupAutoLayoutConstraints];
  [self configureViews];
}

// -----------------------------------------------------------------------------
/// @brief UIViewController method.
///
/// This override handles interface orientation changes while this controller's
/// view hierarchy is visible, and changes that occurred while this controller's
/// view hierarchy was not visible (this method is invoked when the controller's
/// view becomes visible again).
// -----------------------------------------------------------------------------
- (void) viewWillLayoutSubviews
{
  [AutoLayoutConstraintHelper updateAutoLayoutConstraints:self.boardViewAutoLayoutConstraints
                                              ofBoardView:self.boardViewController.view
                                  forInterfaceOrientation:[UiElementMetrics interfaceOrientation]
                                         constraintHolder:self.woodenBackgroundView];
}

#pragma mark - Private helpers for loadView

// -----------------------------------------------------------------------------
/// @brief Private helper for loadView.
// -----------------------------------------------------------------------------
- (void) setupViewHierarchy
{
  self.woodenBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  [self.view addSubview:self.woodenBackgroundView];
  [self.woodenBackgroundView addSubview:self.boardViewController.view];
  if (self.useNavigationBar)
  {
    [self.view addSubview:self.navigationBarController.view];
  }
  else
  {
    self.leftColumnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.woodenBackgroundView addSubview:self.leftColumnView];
    [self.leftColumnView addSubview:self.boardPositionButtonBoxController.view];

    self.rightColumnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.woodenBackgroundView addSubview:self.rightColumnView];
    [self.rightColumnView addSubview:self.gameActionButtonBoxController.view];

    self.mainMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.rightColumnView addSubview:self.mainMenuButton];
  }
}

// -----------------------------------------------------------------------------
/// @brief Private helper for loadView.
// -----------------------------------------------------------------------------
- (void) setupAutoLayoutConstraints
{
  self.boardViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  [AutoLayoutConstraintHelper updateAutoLayoutConstraints:self.boardViewAutoLayoutConstraints
                                              ofBoardView:self.boardViewController.view
                                  forInterfaceOrientation:[UiElementMetrics interfaceOrientation]
                                         constraintHolder:self.woodenBackgroundView];

  NSMutableDictionary* viewsDictionary = [NSMutableDictionary dictionary];
  NSMutableArray* visualFormats = [NSMutableArray array];
  if (self.useNavigationBar)
  {
    self.navigationBarController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.woodenBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [viewsDictionary setObject:self.navigationBarController.view forKey:@"navigationBarView"];
    [viewsDictionary setObject:self.woodenBackgroundView forKey:@"woodenBackgroundView"];
    [visualFormats addObject:@"H:|-0-[navigationBarView]-0-|"];
    [visualFormats addObject:@"H:|-0-[woodenBackgroundView]-0-|"];
    // Don't need to specify height value for navigationBarView because
    // UINavigationBar specifies a height value in its intrinsic content size
    [visualFormats addObject:@"V:|-0-[navigationBarView]-0-[woodenBackgroundView]-0-|"];
    [AutoLayoutUtility installVisualFormats:visualFormats withViews:viewsDictionary inView:self.view];
  }
  else
  {
    int horizontalSpacingButtonBox = [AutoLayoutUtility horizontalSpacingSiblings];
    int verticalSpacingButtonBox = [AutoLayoutUtility verticalSpacingSiblings];

    self.woodenBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [AutoLayoutUtility fillSuperview:self.view withSubview:self.woodenBackgroundView];

    // The board view is square and horizontally centered, which means that
    // there is a dynamic amount of width left. We need left/right columns that
    // can horizontally expand and take up that width. The button boxes have
    // fixed width, so we need to wrap them in superviews that can expand.
    self.leftColumnView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightColumnView.translatesAutoresizingMaskIntoConstraints = NO;
    [viewsDictionary setObject:self.leftColumnView forKey:@"leftColumnView"];
    [viewsDictionary setObject:self.boardViewController.view forKey:@"boardView"];
    [viewsDictionary setObject:self.rightColumnView forKey:@"rightColumnView"];
    // The board view is anchored at the horizontal center and has a defined
    // width. By aligning the column edges with the board view edges and by NOT
    // specifying any column widths we guarantee that the column views will
    // horizontally expand (the column views will be anchored to the superview's
    // edges further down).
    [visualFormats addObject:@"H:[leftColumnView]-0-[boardView]-0-[rightColumnView]"];
    [AutoLayoutUtility installVisualFormats:visualFormats withViews:viewsDictionary inView:self.woodenBackgroundView];

    UIView* anchorView = self.woodenBackgroundView;
    NSLayoutXAxisAnchor* leftAnchor;
    NSLayoutXAxisAnchor* rightAnchor;
    NSLayoutYAxisAnchor* topAnchor;
    NSLayoutYAxisAnchor* bottomAnchor;
    if (@available(iOS 11.0, *))
    {
      UILayoutGuide* layoutGuide = anchorView.safeAreaLayoutGuide;
      leftAnchor = layoutGuide.leftAnchor;
      rightAnchor = layoutGuide.rightAnchor;
      topAnchor = layoutGuide.topAnchor;
      bottomAnchor = layoutGuide.bottomAnchor;
    }
    else
    {
      leftAnchor = anchorView.leftAnchor;
      rightAnchor = anchorView.rightAnchor;
      topAnchor = anchorView.topAnchor;
      bottomAnchor = anchorView.bottomAnchor;
    }
    [self.leftColumnView.leftAnchor constraintEqualToAnchor:leftAnchor].active = YES;
    [self.leftColumnView.topAnchor constraintEqualToAnchor:topAnchor].active = YES;
    [self.leftColumnView.bottomAnchor constraintEqualToAnchor:bottomAnchor].active = YES;
    [self.rightColumnView.topAnchor constraintEqualToAnchor:topAnchor].active = YES;
    [self.rightColumnView.bottomAnchor constraintEqualToAnchor:bottomAnchor].active = YES;
    [self.rightColumnView.rightAnchor constraintEqualToAnchor:rightAnchor].active = YES;

    [viewsDictionary removeAllObjects];
    [visualFormats removeAllObjects];
    self.boardPositionButtonBoxController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [viewsDictionary setObject:self.boardPositionButtonBoxController.view forKey:@"boardPositionButtonBox"];
    [visualFormats addObject:[NSString stringWithFormat:@"H:|-%d-[boardPositionButtonBox]", horizontalSpacingButtonBox]];
    [visualFormats addObject:[NSString stringWithFormat:@"V:[boardPositionButtonBox]-%d-|", verticalSpacingButtonBox]];
    [visualFormats addObject:[NSString stringWithFormat:@"H:[boardPositionButtonBox(==%f)]", self.boardPositionButtonBoxController.buttonBoxSize.width]];
    [visualFormats addObject:[NSString stringWithFormat:@"V:[boardPositionButtonBox(==%f)]", self.boardPositionButtonBoxController.buttonBoxSize.height]];
    [AutoLayoutUtility installVisualFormats:visualFormats withViews:viewsDictionary inView:self.leftColumnView];

    [viewsDictionary removeAllObjects];
    [visualFormats removeAllObjects];
    self.mainMenuButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.gameActionButtonBoxController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [viewsDictionary setObject:self.mainMenuButton forKey:@"mainMenuButton"];
    [viewsDictionary setObject:self.gameActionButtonBoxController.view forKey:@"gameActionButtonBox"];
    [visualFormats addObject:[NSString stringWithFormat:@"V:|-%d-[mainMenuButton]", verticalSpacingButtonBox]];
    [visualFormats addObject:[NSString stringWithFormat:@"H:[gameActionButtonBox]-%d-|", horizontalSpacingButtonBox]];
    [visualFormats addObject:[NSString stringWithFormat:@"V:[gameActionButtonBox]-%d-|", verticalSpacingButtonBox]];
    [AutoLayoutUtility installVisualFormats:visualFormats withViews:viewsDictionary inView:self.rightColumnView];
    // The main menu button is not in a box, so has not the same width as the
    // game action button box. To make it look good we horizontally center it on
    // the game action button box.
    [AutoLayoutUtility alignFirstView:self.mainMenuButton
                       withSecondView:self.gameActionButtonBoxController.view
                          onAttribute:NSLayoutAttributeCenterX
                     constraintHolder:self.rightColumnView];

    // Size (specifically height) of gameActionButtonBox is variable,
    // constraints are managed dynamically
    [self updateGameActionButtonBoxAutoLayoutConstraints];
  }
}

// -----------------------------------------------------------------------------
/// @brief Private helper for loadView.
// -----------------------------------------------------------------------------
- (void) configureViews
{
  // This view provides a wooden texture background not only for the Go board,
  // but for the entire area in which the Go board resides
  [[ApplicationDelegate sharedDelegate].boardViewModel addObserver:self
                                                        forKeyPath:@"boardThemeId"
                                                           options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                                                           context:self.woodenBackgroundView];

  [self.boardPositionButtonBoxController applyTransparentStyle];
  [self.gameActionButtonBoxController applyTransparentStyle];

  [self.mainMenuButton setImage:[UIImage imageNamed:mainMenuIconResource]
                       forState:UIControlStateNormal];
  [self.mainMenuButton addTarget:[MainMenuPresenter sharedPresenter]
                          action:@selector(presentMainMenu:)
                forControlEvents:UIControlEventTouchUpInside];
  // Same tint as button box
  self.mainMenuButton.tintColor = [UIColor blackColor];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (object == [ApplicationDelegate sharedDelegate].boardViewModel) {
    if ([keyPath isEqual:@"boardThemeId"]) {
      NSString* boardThemeId = [(BoardViewModel*)object boardThemeId];
      ((UIView*)context).backgroundColor = [BoardTheme themeForId:boardThemeId].boardBackgroundColor;
    }
  }
}

#pragma mark - Dynamic Auto Layout constraint handling

// -----------------------------------------------------------------------------
/// @brief Updates Auto Layout constraints that manage the size of the
/// Game Action button box. The new constraints use the current size values
/// provided by the button box controller.
// -----------------------------------------------------------------------------
- (void) updateGameActionButtonBoxAutoLayoutConstraints
{
  if (self.gameActionButtonBoxAutoLayoutConstraints)
    [self.rightColumnView removeConstraints:self.gameActionButtonBoxAutoLayoutConstraints];

  NSDictionary* viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.gameActionButtonBoxController.view, @"gameActionButtonBox",
                                   nil];
  NSMutableArray* visualFormats = [NSMutableArray arrayWithObjects:
                                   [NSString stringWithFormat:@"H:[gameActionButtonBox(==%f)]", self.gameActionButtonBoxController.buttonBoxSize.width],
                                   [NSString stringWithFormat:@"V:[gameActionButtonBox(==%f)]", self.gameActionButtonBoxController.buttonBoxSize.height],
                                   nil];
  self.gameActionButtonBoxAutoLayoutConstraints = [AutoLayoutUtility installVisualFormats:visualFormats
                                                                                withViews:viewsDictionary
                                                                                   inView:self.rightColumnView];
}

#pragma mark - ButtonBoxControllerDataDelegate overrides

// -----------------------------------------------------------------------------
/// @brief ButtonBoxControllerDataDelegate protocol method.
// -----------------------------------------------------------------------------
- (void) buttonBoxButtonsWillChange
{
  [self updateGameActionButtonBoxAutoLayoutConstraints];
}

#pragma mark - Notification responders

// -----------------------------------------------------------------------------
/// @brief Responds to the #boardViewWillDisplayCrossHair notifications.
// -----------------------------------------------------------------------------
- (void) boardViewWillDisplayCrossHair:(NSNotification*)notification
{
  self.mainMenuButton.enabled = NO;
}

// -----------------------------------------------------------------------------
/// @brief Responds to the #boardViewWillHideCrossHair notifications.
// -----------------------------------------------------------------------------
- (void) boardViewWillHideCrossHair:(NSNotification*)notification
{
  self.mainMenuButton.enabled = YES;
}

@end
