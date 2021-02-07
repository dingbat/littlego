//
//  BoardTheme.m
//  Little Go
//
//  Created by dan hassin on 2/7/21.
//

#import "BoardTheme.h"

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
+ (NSArray<BoardTheme *>*) boardThemes {
  static const NSArray* boardThemes;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    boardThemes = [[NSArray alloc] initWithObjects:
      [[BoardTheme alloc] initWithId: @"wood" name: @"Wood"],
      [[BoardTheme alloc] initWithId: @"dark" name: @"Dark Wood"],
      nil
    ];
  });
  return (NSArray<BoardTheme *>*)boardThemes;
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
- (id) initWithId:(NSString*)themeId name:(NSString*)name {
  self = [super init];
  if (self) {
    self->_themeId = themeId;
    self->_name = name;
  }
  return self;
}

@end
