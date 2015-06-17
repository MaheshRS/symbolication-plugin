//
//  SymbolicateMemory.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 12/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import "SymbolicateMemory.h"

@interface SymbolicateMemory ()

@property (weak) IBOutlet NSTextField *dSYMFilePathLbl;
@property (weak) IBOutlet NSTextField *dSYMFilePathTxtFld;
@property (weak) IBOutlet NSTextField *memoryAddressLbl;
@property (weak) IBOutlet NSTextField *memoryAddressTxtFld;
@property (unsafe_unretained) IBOutlet NSTextView *resultTxtView;
@property (weak) IBOutlet NSButton *symbolicateBtn;
@property (weak) IBOutlet NSMatrix *architectureMatrix;

@property (nonatomic, strong) NSProgressIndicator *progressIndicator;

@property (weak) IBOutlet NSButton *selectBtn;

@end

@implementation SymbolicateMemory

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.dSYMFilePathTxtFld.editable = NO;
    self.resultTxtView.selectable = YES;
    self.resultTxtView.editable = NO;
    [self setUpArchitectureMatrix];
}

- (void)dealloc {
    [self.task terminate];
    self.task = nil;
    
    [self stopProgressIndicator];
    [self enableControllers:YES];
}

- (void)setUpArchitectureMatrix {
    NSArray *array = self.architectureMatrix.cells;
    [array[0] setTitle:@"x86_64"];
    [array[1] setTitle:@"arm64"];
    [array[2] setTitle:@"armv7"];
    [array[3] setTitle:@"armv7s"];
}

- (NSString *)valueForMatrix:(NSInteger)integer {
    
    NSString *arch = @"armv7";
    switch (integer) {
        case 0:
            arch = @"x86_64";
            break;
        case 1:
            arch = @"arm64";
            break;
        case 2:
            arch = @"armv7";
            break;
        case 3:
            arch = @"armv7s";
            break;
        default:
            arch = @"armv7";
            break;
    }
    
    return arch;
}


#pragma mark - Symbolicate Button Pressed
- (IBAction)symbolicateBtnPressed:(NSButton *)sender {
    
    if(self.dSYMFilePathTxtFld.stringValue.length == 0) {
        [self showAlertWithTitle:@"Missing Executable." message:@"Please provide the path to the executable (*/<application>.app/application)"];
    }
    else {
        [self startTask];
    }
}

#pragma mark - NSTask
- (void) startTask {
    
    [self startProgressIndicator];
    [self enableControllers:NO];
    
    [super startTask];
    
    __typeof(self) __weak weakself = self;
    [self setUpTerminationHandlerForTask:self.task completion:^(NSString *taskOutput, NSError *error) {
        [weakself.resultTxtView setString:taskOutput];
        [weakself.task terminate];
        weakself.task = nil;
        
        [weakself stopProgressIndicator];
        [weakself enableControllers:YES];
    }];
    
    [self tryToLaunchTask:self.task completionIfFailed:^(NSString *taskOutput, NSError *error) {
        [weakself.resultTxtView setString:[error localizedDescription]];
        [weakself.task terminate];
        weakself.task = nil;
        
        [weakself stopProgressIndicator];
        [weakself enableControllers:YES];
    }];
}

- (NSArray *)getArgumentsForTask:(NSTask *)task {
    return [self getArguments];
}

- (NSString *)getLaunchPathForTask:(NSTask *)task {
    return @"/usr/bin/atos";
}


#pragma mark - Helper Methods
- (NSArray *)getArguments {
    __block NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:@"-arch"];
    [arguments addObject:[self valueForMatrix:self.architectureMatrix.selectedColumn]];
    [arguments addObject:@"-o"];
    
    NSURL *dSYMFilePathURL = [NSURL fileURLWithPath:self.dSYMFilePathTxtFld.stringValue];
    NSString *string = [dSYMFilePathURL path];
    [arguments addObject:string];
    
    NSArray *array = [[self.memoryAddressTxtFld stringValue] componentsSeparatedByString:@" "];
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *str = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [arguments addObject:str];
    }];
    
    return [NSArray arrayWithArray:arguments];
}

#pragma mark - Select Button Actions
- (IBAction)applicationFileSelected:(id)sender {
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
            self.dSYMFilePathTxtFld.stringValue = url.path;
        }
        
    }];
}


#pragma mark - Progress Indicator
- (void)startProgressIndicator {
    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:self.resultTxtView.bounds];
    indicator.style = NSProgressIndicatorSpinningStyle;
    indicator.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self.resultTxtView addSubview:indicator];
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
    self.dSYMFilePathTxtFld.enabled = enable;
    self.symbolicateBtn.enabled = enable;
}


@end
