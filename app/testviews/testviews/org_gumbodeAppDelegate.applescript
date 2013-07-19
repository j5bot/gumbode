--
--  org_gumbodeAppDelegate.applescript
--  testviews
--
--  Created by j5 on 7/17/13.
--  Copyright (c) 2013 gumbode. All rights reserved.
--

script org_gumbodeAppDelegate
	property parent : class "NSObject"
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script