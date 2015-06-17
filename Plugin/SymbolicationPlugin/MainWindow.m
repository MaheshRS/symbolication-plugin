//
//  MainWindow.m
//  SymbolicationPlugin
//
//  Created by Mahesh Shanbhag on 02/06/15.
//  Copyright (c) 2015 Mahesh Shanbhag. All rights reserved.
//

#import "MainWindow.h"

NSString *const kSymbolicateWindowTitle = @"Symbolicate";

@interface MainWindow ()

@property (weak) IBOutlet NSView *mainView;

@end

@implementation MainWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // window title
    self.window.title = kSymbolicateWindowTitle;
}

@end
