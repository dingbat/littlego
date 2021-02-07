//
//  BoardTheme.h
//  Little Go
//
//  Created by dan hassin on 2/7/21.
//

#import <Foundation/Foundation.h>

@interface BoardTheme : NSObject

+ (NSArray<BoardTheme *> *) boardThemes;

@property(nonatomic, assign, readonly) NSString* name;
/// @brief The filename of the .sgf file.
@property(nonatomic, assign, readonly) NSString* themeId;

@end
