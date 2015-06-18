//
//  RootController.m
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

#import "RootController.h"
#import "DetailsController.h"
#import "SymbolicateMemory.h"

@interface RootController ()

@property (weak) IBOutlet NSView *rootContentView;
@property (weak) IBOutlet NSSegmentedControl *segmentControl;
@property (weak) IBOutlet NSTextField *dSYMPathTxtFld;
@property (weak) IBOutlet NSTextField *crashFilePathTxtFld;
@property (unsafe_unretained) IBOutlet NSTextView *resultTextViewField;


@property (weak) IBOutlet NSButton *symbolicateBtn;
@property (weak) IBOutlet NSTextField *dSYMFilepathLbl;
@property (weak) IBOutlet NSTextField *crashFilePathLbl;
@property (weak) IBOutlet NSButton *dSYMSelectBtn;
@property (weak) IBOutlet NSButton *crashSelectBtn;
@property (weak) IBOutlet NSScrollView *textScrollView;
@property (weak) IBOutlet NSButton *saveBtn;


@property (strong, nonatomic) DetailsController *detailsController;
@property (strong, nonatomic) SymbolicateMemory *symbolicateMemory;
@property (strong, nonatomic) NSProgressIndicator *progressIndicator;

@end

@implementation RootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[NSColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f].CGColor];
    [self.rootContentView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    [self.rootContentView.layer setBackgroundColor:[NSColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f].CGColor];
    [self.segmentControl selectSegmentWithTag:0];
    
    self.resultTextViewField.editable = NO;
    self.dSYMPathTxtFld.editable = NO;
    self.crashFilePathTxtFld.editable = NO;
    self.resultTextViewField.selectable = YES;
    [self enableSaveButton:NO];
}

- (void)dealloc {
    [self.task terminate];
    self.task = nil;
    
    [self stopProgressIndicator];
    [self enableControllers:YES];
}

#pragma mark - Segment Control

- (IBAction)segmentSelected:(NSSegmentedControl *)sender {
    switch (sender.selectedSegment) {
        case 0: {
            [self clearDetailsPage];
            [self clearSymbolicateMemoryPage];
            [self showRootView];
            break;
        }
        case 1: {
            [self clearSymbolicateMemoryPage];
            [self hideMainView:YES];
            [self showDetailsPage];
            break;
        }
        case 2: {
            [self clearDetailsPage];
            [self hideMainView:YES];
            [self showSymbolicateMemoryPage];
            break;
        }
        default:
            break;
    }
}

- (void)showRootView {
    [self hideMainView:NO];
}

- (void)hideMainView:(BOOL)hide {
    self.dSYMFilepathLbl.hidden = hide;
    self.dSYMPathTxtFld.hidden = hide;
    self.crashFilePathLbl.hidden = hide;
    self.crashFilePathTxtFld.hidden = hide;
    self.symbolicateBtn.hidden = hide;
    self.resultTextViewField.hidden = hide;
    self.textScrollView.hidden = hide;
    self.dSYMSelectBtn.hidden = hide;
    self.crashSelectBtn.hidden = hide;
}

- (void)showDetailsPage {
    
    if(self.detailsController != nil) {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[DetailsController class]];
    DetailsController *detailsCtlr = [[DetailsController alloc] initWithNibName:@"DetailsController" bundle:bundle];
    detailsCtlr.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    detailsCtlr.view.frame = self.rootContentView.bounds;
    
    [self.rootContentView addSubview:detailsCtlr.view];
    self.detailsController = detailsCtlr;
}

- (void)clearDetailsPage {
    if(self.detailsController) {
        [self.detailsController.view removeFromSuperview];
        self.detailsController = nil;
    }
}

- (void)clearSymbolicateMemoryPage {
    if(self.symbolicateMemory) {
        [self.symbolicateMemory.view removeFromSuperview];
        self.symbolicateMemory = nil;
    }
}

- (void)showSymbolicateMemoryPage {
    
    if(self.symbolicateMemory != nil) {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[SymbolicateMemory class]];
    SymbolicateMemory *memCtlr = [[SymbolicateMemory alloc] initWithNibName:@"SymbolicateMemory" bundle:bundle];
    memCtlr.view.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    memCtlr.view.frame = self.rootContentView.bounds;
    
    [self.rootContentView addSubview:memCtlr.view];
    self.symbolicateMemory = memCtlr;
}


#pragma mark - Symbolicate Button Action
- (IBAction)symbolicateBtnPressed:(id)sender {
    
    if(self.dSYMPathTxtFld.stringValue.length == 0) {
        [self showAlertWithTitle:@"File Missing" message:@"Please select dSYM file for symbolication"];
    }
    else if (self.crashFilePathTxtFld.stringValue.length == 0) {
        [self showAlertWithTitle:@"File Missing" message:@"Please select the crash file to be symbolicated."];
    }
    else {
        self.resultTextViewField.string = @""; // reset the result string
        [self startTask];
    }
}

#pragma mark - NSTask
- (void) startTask {
    [self startProgressIndicator];
    [self enableControllers:NO];
    [self enableSaveButton:NO];
    
    [super startTask];
    
    __typeof(self) __weak weakself = self;
    [self setUpTerminationHandlerForTask:self.task completion:^(NSString *taskOutput, NSError *error) {
        [weakself.resultTextViewField setString:taskOutput];
        [weakself.task terminate];
        weakself.task = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakself stopProgressIndicator];
            [weakself enableControllers:YES];
            [weakself enableSaveButton:YES];
        }];
    }];
    
    [self tryToLaunchTask:self.task completionIfFailed:^(NSString *taskOutput, NSError *error) {
        [weakself.resultTextViewField setString:[error localizedDescription]];
        [weakself.task terminate];
        weakself.task = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakself stopProgressIndicator];
            [weakself enableControllers:YES];
            [weakself enableSaveButton:NO];
        }];
    }];
}

- (NSArray *)getArgumentsForTask:(NSTask *)task {
    NSString *dSYMFilePath = self.dSYMPathTxtFld.stringValue;
    NSString *crashFilePath = self.crashFilePathTxtFld.stringValue;
    return @[crashFilePath, dSYMFilePath];
}

- (NSString *)getLaunchPathForTask:(NSTask *)task {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:kSymbolicationPluginBundleIdentifier];
    NSString *resymbolicateFilePath = [bundle pathForResource:@"resymbolicate" ofType:@""];
    return resymbolicateFilePath;
}

#pragma mark - Select Files
- (IBAction)selectdSYMFile:(id)sender {
    
    // Create and configure the panel.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"dSYM"]];
    [panel setMessage:@"Import one or more files or directories."];
    
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            NSURL *url = urls[0];
            self.dSYMPathTxtFld.stringValue = url.path;
        }
        
    }];
}

- (IBAction)selectCrashFile:(id)sender {
    
    // Create and configure the panel.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"crash"]];
    [panel setMessage:@"Import one or more files or directories."];
    
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            NSURL *url = urls[0];
            self.crashFilePathTxtFld.stringValue = url.path;
        }
        
    }];
}

- (IBAction)saveBtnPressed:(id)sender {
    
    // Create and configure the panel.
    NSSavePanel* panel = [NSSavePanel savePanel];
    panel.nameFieldStringValue = @"symbolicated_crash.crash";
    [panel setAllowedFileTypes:@[@"crash"]];
    [panel setMessage:@"Import one or more files or directories."];
    
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        NSURL *url = [panel URL];

        
        NSFileManager *manager =  [[NSFileManager alloc] init];
        if(![manager fileExistsAtPath:url.path isDirectory:NO]) {
            [manager createFileAtPath:url.path contents:[self.resultTextViewField.string dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
    }];
}

- (void)enableSaveButton:(BOOL)enable {
    self.saveBtn.enabled = enable;
}


#pragma mark - Progress Indicator
- (void)startProgressIndicator {
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:self.textScrollView.bounds];
    indicator.style = NSProgressIndicatorSpinningStyle;
    indicator.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self.textScrollView addSubview:indicator];
    [indicator startAnimation:nil];
    
    self.progressIndicator = indicator;
}

- (void)stopProgressIndicator {
    [self.progressIndicator stopAnimation:nil];
    [self.progressIndicator removeFromSuperview];
    self.progressIndicator = nil;
}

- (void)enableControllers:(BOOL)enable {
    self.dSYMPathTxtFld.enabled = enable;
    self.dSYMSelectBtn.enabled = enable;
    self.crashSelectBtn.enabled = enable;
    self.crashFilePathTxtFld.enabled = enable;
    self.symbolicateBtn.enabled = enable;
}

@end
