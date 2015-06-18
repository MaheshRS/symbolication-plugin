//
//  CommonController.m
//  SymbolicationPlugin
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Mahesh R Shanbhag
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "CommonController.h"

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
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kSymbolicationPluginBundleIdentifier];
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
            }
            else {
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
