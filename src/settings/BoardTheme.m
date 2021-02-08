//
//  BoardTheme.m
//  Little Go
//
//  Created by dan hassin on 2/7/21.
//

#import "BoardTheme.h"
#import "../utility/UIImageAdditions.h"
#import "../play/model/BoardViewModel.h"

@implementation BoardTheme

// -----------------------------------------------------------------------------
/// @brief Initializes a ArchiveGame object. The object's file name property is
/// set to @a aFileName. Other property values are taken from @a fileAttributes;
/// the dictionary is expected to contain values obtained via NSFileManager's
/// attributesOfItemAtPath:error:().
///
/// @a fileName and @a fileAttributes may be empty, in which case the properties
/// that describe this ArchiveGame object are set to empty string values.
///
/// @note This is the designated initializer of ArchiveGame.
// -----------------------------------------------------------------------------
+ (NSArray<BoardTheme*>*) boardThemes {
  static const NSArray* boardThemes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    boardThemes = [[NSArray alloc] initWithObjects:
                   [[BoardTheme alloc] initWithId: @"wood" name: @"Wood" backgroundImage: woodenBackgroundImageResource],
                   [[BoardTheme alloc] initWithId: @"dark" name: @"Dark Wood" backgroundImage: darkWoodenBackgroundImageResource],
      nil
    ];
  });
  return (NSArray<BoardTheme *>*)boardThemes;
}

+ (BoardTheme*) themeForId:(NSString*)boardThemeId {
  for (BoardTheme* theme in [self boardThemes]) {
    if ([theme.themeId isEqual:boardThemeId]) {
      return theme;
    }
  }
  return nil;
}

// -----------------------------------------------------------------------------
/// @brief Initializes a ArchiveGame object. The object's file name property is
/// set to @a aFileName. Other property values are taken from @a fileAttributes;
/// the dictionary is expected to contain values obtained via NSFileManager's
/// attributesOfItemAtPath:error:().
///
/// @a fileName and @a fileAttributes may be empty, in which case the properties
/// that describe this ArchiveGame object are set to empty string values.
///
/// @note This is the designated initializer of ArchiveGame.
// -----------------------------------------------------------------------------
- (id) initWithId:(NSString*)themeId name:(NSString*)name backgroundImage:(NSString*)backgroundImage {
  self = [super init];
  if (self) {
    self->_themeId = themeId;
    self->_name = name;
    self->_backgroundImage = backgroundImage;
  }
  return self;
}

// -----------------------------------------------------------------------------
/// @brief Returns a color object that can be used to display a wooden
/// background. The UIColor object is actually an image sized so that it is
/// guaranteed to cover the device's entire screen, regardless of which
/// orientation the UI has.
///
/// @todo The implementation of this method uses the UIScreen bounds to
/// determine the size of the image. For iPad multitasking scenarios this
/// yields a grossly oversized image. Although not wrong, this wastes a lot of
/// memory.
// -----------------------------------------------------------------------------
- (UIColor*) boardBackgroundColor
{
  // To make sure that the image covers the entire screen, regardless of which
  // orientation the UI has, we must make the image square, using the larger
  // dimension of the screen. This wastes some memory, but the alternative
  // would be to recreate the image whenever the UI orientation changes.
  CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
  CGFloat largerDimension = MAX(mainScreenBounds.size.width, mainScreenBounds.size.height);
  CGSize mainScreenSquaredSize = CGSizeMake(largerDimension, largerDimension);

  // The image on disk is quite large, intentionally, so that it's not very
  // obvious that tiling takes place. On devices with smaller screens the image
  // on disk may even be large enough to cover the entire screen without any
  // tiling at all.
  UIImage* image = [self boardBackgroundTileImage];
  UIImage* tiledImage = [UIImage tiledImageWithSize:mainScreenSquaredSize fromTile:image];
  return [UIColor colorWithPatternImage:tiledImage];
}

// -----------------------------------------------------------------------------
/// @brief Returns an image object that can be used to display a wooden
/// background. The image is suitable for tiling.
// -----------------------------------------------------------------------------
- (UIImage*) boardBackgroundTileImage
{
  // The background image is quite large, so we don't use UIImage namedImage:()
  // because that method caches the image in the background. We don't need
  // caching because we only load the image once, so not using namedImage:()
  // saves us quite a bit of valuable memory.
  NSString* imagePath = [[NSBundle mainBundle] pathForResource:self.backgroundImage
                                                        ofType:nil];
  NSData* imageData = [NSData dataWithContentsOfFile:imagePath];
  return [UIImage imageWithData:imageData];
}

@end
