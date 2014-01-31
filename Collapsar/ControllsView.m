//
//  ControllsView.m
//  Collapsar
//
//  Created by Sergey P on 31.01.14.
//  Copyright (c) 2014 SergeyP. All rights reserved.
//

#import "ControllsView.h"

@implementation ControllsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
    
    [[NSColor colorWithCalibratedRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1] setFill];
    
    NSRectFill(dirtyRect);
}

@end
