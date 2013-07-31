//
//  Menulet.h
//  GUmBoDE
//
//  Created by j5 on 7/30/13.
//  Copyright (c) 2013 gumbode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface Menulet : NSObject {
    NSMenuItem *MenuItem;
    IBOutlet NSMenu *theMenu;
    
    NSStatusItem *statusItem;
    NSImage *menuIcon;
}
@end
