// -----------------------------------------------------------------------------
// Copyright 2011-2013 Patrick Näf (herzbube@herzbube.ch)
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
#import "RestoreGameCommand.h"
#import "../boardposition/SyncGTPEngineCommand.h"
#import "../game/LoadGameCommand.h"
#import "../game/NewGameCommand.h"
#import "../../go/GoBoardPosition.h"
#import "../../go/GoGame.h"
#import "../../go/GoScore.h"
#import "../../main/ApplicationDelegate.h"
#import "../../play/model/ScoringModel.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private properties for RestoreGameCommand.
// -----------------------------------------------------------------------------
@interface RestoreGameCommand()
@property(nonatomic, retain) GoGame* unarchivedGame;
@property(nonatomic, retain) GoScore* unarchivedScore;
@end


@implementation RestoreGameCommand

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this RestoreGameCommand object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  self.unarchivedGame = nil;
  self.unarchivedScore = nil;
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Executes this command. See the class documentation for details.
// -----------------------------------------------------------------------------
- (bool) doIt
{
  if (! [self tryRestoreFromArchive])
  {
    if (! [self tryRestoreFromSgf])
    {
      [[[[NewGameCommand alloc] init] autorelease] submit];
    }
  }
  return true;
}

// -----------------------------------------------------------------------------
/// @brief Private helper for doIt().
// -----------------------------------------------------------------------------
- (bool) tryRestoreFromArchive
{
  DDLogVerbose(@"%@: Restoring game from NSCoding archive", [self shortDescription]);
  BOOL fileExists;
  NSString* backupFilePath = [self filePathForBackupFileNamed:archiveBackupFileName fileExists:&fileExists];
  if (! fileExists)
    return false;

  NSData* data = [NSData dataWithContentsOfFile:backupFilePath];
  NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  self.unarchivedGame = [unarchiver decodeObjectForKey:nsCodingGoGameKey];
  self.unarchivedScore = [unarchiver decodeObjectForKey:nsCodingGoScoreKey];
  [unarchiver finishDecoding];
  [unarchiver release];
  if (! self.unarchivedGame)
    return false;

  NewGameCommand* command = [[[NewGameCommand alloc] initWithGame:self.unarchivedGame] autorelease];
  // Computer player must not be triggered before the GTP engine has been
  // sync'ed
  command.shouldTriggerComputerPlayer = false;
  [command submit];

  [[[[SyncGTPEngineCommand alloc] init] autorelease] submit];

  if (GoGameTypeComputerVsComputer == self.unarchivedGame.type)
  {
    if (GoGameStateGameHasNotYetStarted == self.unarchivedGame.state ||
        GoGameStateGameHasStarted == self.unarchivedGame.state)
    {
      DDLogWarn(@"%@: Computer vs. computer game is in state %d, i.e. not paused", [self shortDescription], self.unarchivedGame.state);
      [self.unarchivedGame pause];
    }
  }
  // It is quite possible that the user suspended the app while the computer
  // was thinking (the "computer play" function makes this possible even in
  // human vs. human games) . We must reset that status here.
  if (self.unarchivedGame.isComputerThinking)
  {
    DDLogInfo(@"%@: Computer vs. computer game, turning off 'computer is thinking' state", [self shortDescription]);
    self.unarchivedGame.computerThinks = false;
  }

  if (self.unarchivedScore)
  {
    ScoringModel* scoringModel = [ApplicationDelegate sharedDelegate].scoringModel;
    // Scoring model sends its own notification
    [scoringModel restoreScoringModeWithScoreObject:self.unarchivedScore];
  }

  return true;
}

// -----------------------------------------------------------------------------
/// @brief Private helper for doIt().
// -----------------------------------------------------------------------------
- (bool) tryRestoreFromSgf
{
  DDLogVerbose(@"%@: Restoring game from .sgf file", [self shortDescription]);
  BOOL fileExists;
  NSString* backupFilePath = [self filePathForBackupFileNamed:sgfBackupFileName fileExists:&fileExists];
  if (! fileExists)
    return false;
  LoadGameCommand* loadCommand = [[[LoadGameCommand alloc] initWithFilePath:backupFilePath] autorelease];
  loadCommand.restoreMode = true;
  // LoadGameCommand executes synchronously because this RestoreGameCommand
  // is already asynchronous
  bool success = [loadCommand submit];
  return success;
}

// -----------------------------------------------------------------------------
/// @brief Private helper.
// -----------------------------------------------------------------------------
- (NSString*) filePathForBackupFileNamed:(NSString*)backupFileName fileExists:(BOOL*)fileExists
{
  BOOL expandTilde = YES;
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, expandTilde);
  NSString* appSupportDirectory = [paths objectAtIndex:0];
  NSString* backupFilePath = [appSupportDirectory stringByAppendingPathComponent:backupFileName];
  NSFileManager* fileManager = [NSFileManager defaultManager];
  *fileExists = [fileManager fileExistsAtPath:backupFilePath];
  DDLogVerbose(@"%@: Checking file %@, file exists = %d", [self shortDescription], backupFilePath, *fileExists);
  return backupFilePath;
}

@end
