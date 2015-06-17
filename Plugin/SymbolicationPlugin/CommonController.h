//
//  CommonController.h
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 13/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CommonController : NSViewController

@property (nonatomic, strong) NSMutableData *taskOutput;
@property (nonatomic, strong) NSTask *task;

// Alert to be shown
- (void)showAlertWithTitle:(NSString *)text message:(NSString *)message;

//Task Methods
- (void)startTask;

- (NSArray *)getArgumentsForTask:(NSTask *)task;
- (NSString *)getLaunchPathForTask:(NSTask *)task;
- (NSString *)getCurrentDirectoryForTask:(NSTask *)task;

// Task Utils
- (void)setUpShellOutputForTask:(NSTask *)task;
- (void)setUpStdErrorOutputForTask:(NSTask *)task;
- (void)setUpTerminationHandlerForTask:(NSTask *)task completion:(void(^)(NSString *taskOutput, NSError *error))completion;
- (void)tryToLaunchTask:(NSTask *)shellTask completionIfFailed:(void(^)(NSString *taskOutput, NSError *error))completion;

@end
