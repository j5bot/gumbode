--
--  org_gumbodeAppDelegate.applescript
--  gumbode
--
--  Created by j5 on 7/8/13.
--  Copyright (c) 2013 gumbode. All rights reserved.
--

property NSTimer : class "NSTimer"
property NSMutableArray: class "NSMutableArray"
property NSImage : class "NSImage"

script org_gumbodeAppDelegate
    
	property parent : class "NSObject"
    
    -- to be bound, initialized earlier
    property theAVDList : {}
    property theDeviceList : {}
    
    property theWindow : missing value
    
    property startAVDbutton : missing value
    
    property theAVDListTableView : missing value
    property theDeviceListTableView : missing value
    
    property selectedAVDrow : missing value
    
    -- array controllers, to which we add objects
    property theAVDListArrayController : missing value
    property theDeviceListArrayController : missing value
    
    
    property androidIcon : missing value
    property bugIcon : missing value
    property chromeIcon : missing value
    property operaIcon : missing value
    property firefoxIcon : missing value
    
    property noIcon : missing value

    on trim(strg)
        ignoring white space
            -- do the left trim
            set left_counter to 1
            repeat with J from 1 to length of strg
                if " " = (character left_counter of strg) then
                    set left_counter to left_counter + 1
                    else
                    exit repeat
                end if
            end repeat
            try
                set strg to text left_counter through -1 of strg
                on error
                set strg to ""
            end try
            -- end left trim
            
            -- do the right trim
            set right_counter to -1
            repeat with J from 1 to length of strg
                if " " = (character right_counter of strg) then
                    set right_counter to right_counter - 1
                    else
                    exit repeat
                end if
            end repeat
            try
                set strg to text 1 through right_counter of strg
                on error
                set strg to ""
            end try
            -- end right trim
        end ignoring
        return strg
    end trim
    
    on theSplit(theString, theDelimiter)
		-- save delimiters to restore old settings
		set oldDelimiters to AppleScript's text item delimiters
		-- set delimiters to delimiter to be used
		set AppleScript's text item delimiters to theDelimiter
		-- create the array
		set theArray to every text item of theString
		-- restore the old setting
		set AppleScript's text item delimiters to oldDelimiters
		-- return the result
		return theArray
	end theSplit
    
    on setBadge_(badgeText)
        
        tell me to log badgeText

        set appDockTile to current application's NSApp's dockTile()
        appDockTile's setBadgeLabel_(badgeText)
    
    end setBadge_
    
    on badgeEmulators_(funny)
        
        tell me to log "badging emulators"
        
        tell application "System Events"
            set emulators to get the name of every process whose name contains "emulator"
            repeat with emulator in emulators
                tell process emulator
                    set theTitle to title of first window
                    tell me to log "first window of emulator: " & theTitle
                    set appDockTile to emulator's NSApp's dockTile()
                    appDockTile's setBadgeLabel_(theTitle)
                end tell
            end repeat
        end tell
        
    end badgeEmulators_
    
    on startAVD_(avdName)
            
        set result to (do shell script "/bin/bash -c -l \"" & (POSIX path of (path to resource "startavd") as string) & " " & avdName & "\" > /dev/null 2>&1")
        
    end startAVD_
    
    on manageEmulatorsClicked_(sender)
        
        do shell script "/bin/bash -c -l 'android avd' > /dev/null 2>&1"
        
    end manageEmulatorsClicked_
    
    on startAVDClicked_(sender)
        
        set theAVD to theName of theAVDList's objectAtIndex_(selectedRow of theAVDListTableView as integer)
        startAVD_(theAVD)
        
    end startAVDClicked_
    
    on getAVDList_()

        set getavdinfo to POSIX path of (path to resource "getavdinfo") as string
        
        set avdListString to do shell script (getavdinfo & " | grep -v 'AVD Name' | grep -v '^$' | grep -v -e '----'")
        set avdListArray to theSplit(avdListString, return)
        
        tell theAVDListArrayController
           removeObjects_(arrangedObjects())
        end tell
        
        repeat with avdListArrayItem in avdListArray
            -- tell me to log avdListArrayItem
            
            set avdListItemArray to theSplit(avdListArrayItem, tab)
            
            if length of avdListItemArray is greater than 0 then
                
                tell me to log avdListItemArray
                
                -- set avdListItem to current application's AVDitem's alloc()'s init()
                set avdListItem to { theName:"", theDevice:"", theManufacturer:"", thePlatform:"", theCPU:"", apiLevel: 0, apiName:"" }
                
                tell me to log "1: " & first item of avdListItemArray
                tell me to log "2: " & second item of avdListItemArray
                tell me to log "3: " & third item of avdListItemArray
                tell me to log "4: " & fourth item of avdListItemArray
                tell me to log "5: " & fifth item of avdListItemArray
                tell me to log "6: " & sixth item of avdListItemArray
                tell me to log "7: " & seventh item of avdListItemArray
            
                set theName of avdListItem to trim(first item of avdListItemArray as text)
                set theDevice of avdListItem to trim(second item of avdListItemArray as text)
                set theManufacturer of avdListItem to trim(third item of avdListItemArray as text)
                set thePlatform of avdListItem to trim(fourth item of avdListItemArray as text)
                set theCPU of avdListItem to trim(fifth item of avdListItemArray as text)
                set apiLevel of avdListItem to trim(sixth item of avdListItemArray as text)
                set apiName of avdListItem to trim(seventh item of avdListItemArray as text)
            
                theAVDListArrayController's addObject_(avdListItem)

            end if
            -- tell me to log "theName: " & theName of avdListItem
            
        end repeat
                
        -- theWindow's displayIfNeeded()
        
        -- theAVDListTableView's reloadData()
        
    end getAVDList_
    
    on getDeviceList_(msg)
        
        set deviceListString to do shell script "/bin/bash -c -l " & (POSIX path of (path to resource "getpackages") as string)
        set deviceListArray to theSplit(deviceListString, return)
        
        tell me to log "getting device list"
        
        tell theDeviceListArrayController
            removeObjects_(arrangedObjects())
        end tell
        
        tell me to log "1"
        
        repeat with deviceItem in deviceListArray
            
            tell me to log deviceItem
            
            set deviceItemPropertyArray to theSplit(deviceItem, tab)
            
            tell me to log "deviceItemPropertyArray.length: " & length of deviceItemPropertyArray
            
            set deviceListItem to { theName: "", thePort: "", theSerial: "", hasHybugger: 0, hasBrowser: 0, hasChrome: 0, hasOpera: 0, hasFirefox: 0 }
            
            -- set deviceListItem to current application's Device's alloc()'s init()
            
            tell me to log first item of deviceItemPropertyArray
            tell me to log second item of deviceItemPropertyArray
            
            set theName of deviceListItem to trim(first item of deviceItemPropertyArray as text)
            set thePort of deviceListItem to trim(second item of deviceItemPropertyArray as text)
            set theSerial of deviceListItem to trim(third item of deviceItemPropertyArray as text)
            
            if trim(fourth item of deviceItemPropertyArray as text) is equal to "1" then
                log "hasHybugger"
                set hasHybugger of deviceListItem to bugIcon
            else
                set hasHybugger of deviceListItem to noIcon
            end if
                
            if trim(fifth item of deviceItemPropertyArray as text) is equal to "1" then
                log "hasBrowser"
                set hasBrowser of deviceListItem to androidIcon
            else
                set hasBrowser of deviceListItem to noIcon
            end if
                
            if trim(sixth item of deviceItemPropertyArray as text) is equal to "1" then
                log "hasChrome"
                set hasChrome of deviceListItem to chromeIcon
            else
                set hasChrome of deviceListItem to noIcon
            end if
            
            if trim(seventh item of deviceItemPropertyArray as text) is equal to "1" then
                log "hasOpera"
                set hasOpera of deviceListItem to operaIcon
            else
                set hasOpera of deviceListItem to noIcon
            end if
            
            if trim(eighth item of deviceItemPropertyArray as text) is equal to "1" then
                log "hasFirefox"
                set hasFirefox of deviceListItem to firefoxIcon
            else
                set hasFirefox of deviceListItem to noIcon
            end if
            
            theDeviceListArrayController's addObject_(deviceListItem)
            
        end repeat
        
        tell me to log "2"
                        
    end getDeviceList_
    
    on tableDoubleClicked_(sender)
        
        tell theAVDListTableView to set theSelection to selectedObjects() as list
        
        tell me to log "the selection: " & theSelection
        
        tell me to log tableDoubleClicked
        if theAVDListTableView's selectedRow as integer is not equal to -1 then
            
            my setSelectedAVDrow_(theAVDListTableView's selectedRow as integer)
            set thisAVD to theAVDList's objectAtIndex_(selectedAVDrow as integer)
            set selectedAVDname to trim((thisAVD's valueForKey_("theName")) as string)
            
            startAVD_(selectedAVDname)

        end if
    end tableDoubleClicked_
    
    on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        
	end applicationWillFinishLaunching_
    
    on awakeFromNib()
        
        -- startAVDbutton's setAction("startAVD:")
        
        -- theAVDListTableView's setDoubleAction_("tableDoubleClicked:")
        
        -- theWindow's displayIfNeeded()

        tell current application's NSImage
            
            set my androidIcon to imageNamed_("android-icon.png")
            set my bugIcon to imageNamed_("bug-icon.png")
            set my chromeIcon to imageNamed_("chrome-icon.png")
            set my operaIcon to imageNamed_("opera-icon.png")
            set my firefoxIcon to imageNamed_("firefox-icon.png")
            set my noIcon to imageNamed_("transparent.png")
            
        end tell
        
        getAVDList_()
        getDeviceList_("")
        
        tell me to log "3"
        NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(30, me, "getDeviceList:", "", false)
        
    end awakeFromNib
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        
        -- unload ios-webkit-debug-proxy if running
        -- set isRunning to do shell script "launchctl list | grep -c ios-webkit-debug-proxy"
        -- if isRunning is not "" then do shell script "launchctl unload " & (path to resource "services:org.gumbode.google.ios-webkit-debug-proxy.plist")
        
        theAVDList's release()
        theDeviceList's release()
        
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script