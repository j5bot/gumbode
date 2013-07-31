//
//  Menulet.m
//  GUmBoDE
//
//  Created by j5 on 7/30/13.
//  Copyright (c) 2013 gumbode. All rights reserved.
//

#import "Menulet.h"


@implementation Menulet
-(void)dealloc
{
    [statusItem release];
    [super dealloc];
}
- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength]
                  retain];
    [statusItem setHighlightMode:YES];
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"GUmBoDE"];
    [statusItem setMenu:theMenu];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"gumbode-status-icon" ofType:@"png"];
    menuIcon= [[NSImage alloc] initWithContentsOfFile:path];
    [statusItem setTitle:[NSString stringWithString:@""]];
    [statusItem setImage:menuIcon];
    [menuIcon release];    
}        
@end
