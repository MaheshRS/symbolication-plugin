//
//  DetailsController.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 11/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import "DetailsController.h"

@interface DetailsController ()

@property (weak) IBOutlet NSTextField *headerLbl;
@property (weak) IBOutlet NSTextField *filePathTextField;
@property (weak) IBOutlet NSScrollView *filePathTextView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *selectBtn;


@property (nonatomic, strong) NSProgressIndicator *progressIndicator;


@end

@implementation DetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.filePathTextField.enabled = NO;
    self.textView.editable = NO;
    self.textView.selectable = YES;
}

- (void)dealloc {
    [self.task terminate];
    self.task = nil;
    
    [self stopProgressIndicator];
    [self enableControllers:YES];
}

- (IBAction)selectButtonPressed:(id)sender {
    // Create and configure the panel.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"public.executable"]];
    [panel setMessage:@"Import one or more files or directories."];
    
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            NSURL *url = urls[0];
            self.filePathTextField.stringValue = url.path;
            
            [self startTask];
        }
        
    }];

}

#pragma mark - NSTask
- (void) startTask {
    
    [self startProgressIndicator];
    [self enableControllers:NO];
    
    self.textView.string = @""; // reset the result view
    
    [super startTask];
    
    __typeof(self) __weak weakself = self;
    [self setUpTerminationHandlerForTask:self.task completion:^(NSString *taskOutput, NSError *error) {
        [weakself.textView setString:taskOutput];
        [weakself.task terminate];
        weakself.task = nil;
        
        [weakself stopProgressIndicator];
        [weakself enableControllers:YES];
        
    }];
    
    [self tryToLaunchTask:self.task completionIfFailed:^(NSString *taskOutput, NSError *error) {
        [weakself.textView setString:[error localizedDescription]];
        [weakself.task terminate];
        weakself.task = nil;
        
        [weakself stopProgressIndicator];
        [weakself enableControllers:YES];
    }];
}

- (NSArray *)getArgumentsForTask:(NSTask *)task {
    return @[@"-u",self.filePathTextField.stringValue];
}

- (NSString *)getLaunchPathForTask:(NSTask *)task {
    return @"/usr/bin/dwarfdump";
}

#pragma mark - Progress Indicator
- (void)startProgressIndicator {
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:self.filePathTextField.bounds];
    indicator.style = NSProgressIndicatorSpinningStyle;
    indicator.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self.filePathTextField addSubview:indicator];
    [indicator startAnimation:nil];
    self.progressIndicator = indicator;
}

- (void)stopProgressIndicator {
    [self.progressIndicator stopAnimation:nil];
    [self.progressIndicator removeFromSuperview];
    self.progressIndicator = nil;
}

- (void)enableControllers:(BOOL)enable {
    self.selectBtn.enabled = enable;
    self.filePathTextField.enabled = enable;
}

@end
