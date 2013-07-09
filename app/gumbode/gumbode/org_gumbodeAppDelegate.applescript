--
--  org_gumbodeAppDelegate.applescript
--  gumbode
--
--  Created by j5 on 7/8/13.
--  Copyright (c) 2013 gumbode. All rights reserved.
--

script org_gumbodeAppDelegate
	property parent : class "NSObject"
    
    property buttonWeinre : missing value
    property buttonHybugger : missing value
    property buttonJSConsole : missing value
    property buttonAardwolf : missing value
    
    property buttonWebkitDebugger : missing value
    
    property webkitDebuggerFIFO : missing value
    property webkitDebuggerPID : missing value
    
    on buttonWebkitDebuggerShow_
        
        set isRunning to do shell script "launchctl list | grep -c ios-webkit-debug-proxy"
        
    end
    
    on buttonWebkitDebuggerClicked_(sender)
        
        do shell script "launchctl unload /Library/LaunchDaemons/homebrew.google.ios-webkit-debug-proxy.plist" with administrator privileges
        do shell script "launchctl load /Library/LaunchDaemons/homebrew.google.ios-webkit-debug-proxy.plist" with administrator privileges
        
    end buttonWebkitDebuggerClicked_
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        
        if webkitDebuggerPID is not missing value then do shell script "kill " & webkitDebuggerPID
        
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script