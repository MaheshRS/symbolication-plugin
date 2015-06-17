//
//  CommonController.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 13/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import "CommonController.h"
#import "SymbolicationPlugin.h"

@interface CommonController ()

@end

@implementation CommonController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)showAlertWithTitle:(NSString *)text message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:text];
    [alert setInformativeText:message];
    [alert runModal];
}


#pragma mark - Shell Tasks
- (void)startTask {
    self.taskOutput = [NSMutableData new];
    self.task = [NSTask new];
    
    [self.task setCurrentDirectoryPath:[self getCurrentDirectoryForTask:self.task]];
    [self.task setLaunchPath:[self getLaunchPathForTask:self.task]];
    [self.task setArguments:[self getArgumentsForTask:self.task]];
    
    [self setUpShellOutputForTask:self.task];
    [self setUpStdErrorOutputForTask:self.task];
}


- (NSArray *)getArgumentsForTask:(NSTask *)task {
    return @[];
}

- (NSString *)getLaunchPathForTask:(NSTask *)task {
    return @"";
}

- (NSString *)getCurrentDirectoryForTask:(NSTask *)task {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mahesh.SymbolicationPlugin"];
    return bundle.bundlePath;
}

#pragma mark - Shell Utils
- (void)setUpShellOutputForTask:(NSTask *)task {
    task.standardOutput = [NSPipe pipe];
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        [self.taskOutput setData:[file availableData]];
    }];
}

- (void)setUpStdErrorOutputForTask:(NSTask *)task {
    task.standardError = [NSPipe pipe];
    [[task.standardError fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        [self.taskOutput appendData:[file availableData]];
    }];
}

- (void)setUpTerminationHandlerForTask:(NSTask *)task completion:(void(^)(NSString *taskOutput, NSError *error))completion {
    [task setTerminationHandler:^(NSTask *task) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSString* output = [[NSString alloc] initWithData:self.taskOutput encoding:NSUTF8StringEncoding];
            
            if (task.terminationStatus == 0) {
                completion(output, nil);
            } else {
                NSString* reason = [NSString stringWithFormat:@"Task exited with status %d", task.terminationStatus];
                completion(output, [NSError errorWithDomain:reason code:666 userInfo:@{ NSLocalizedDescriptionKey: reason }]);
            }
        }];
        
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        [task.standardError fileHandleForReading].readabilityHandler = nil;
    }];
}

- (void)tryToLaunchTask:(NSTask *)shellTask completionIfFailed:(void(^)(NSString *taskOutput, NSError *error))completion {
    @try {
        [shellTask launch];
    }
    @catch (NSException *exception) {
        completion(nil, [NSError errorWithDomain:exception.reason code:667 userInfo:nil]);
    }
}


@end
