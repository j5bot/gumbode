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
property NSStatusItem : class "NSStatusItem"
property NSStatusBar : class "NSStatusBar"

script org_gumbodeAppDelegate
    
	property parent : class "NSObject"
    
    property statusBarMenu : missing value
    
    -- preferences
    property defaults : missing value
    
    -- to be bound, initialized earlier
    property theAVDList : {}
    property theDeviceList : {}
    
    property theWindow : missing value
    
    property startAVDbutton : missing value
    
    property theAVDListTableView : missing value
    property theDeviceListTableView : missing value
    
    property selectedAVDrow : missing value
    property selectedDeviceRow : missing value
    property selectedDevicePackage : missing value
    
    -- array controllers, to which we add objects
    property theAVDListArrayController : missing value
    property theDeviceListArrayController : missing value
    
    
    property androidIcon : missing value
    property bugIcon : missing value
    property chromeIcon : missing value
    property operaIcon : missing value
    property firefoxIcon : missing value
    
    property noIcon : missing value

    property isPackageInstalling : false
    property isPrivoxyRunning : false
    
    -- debugger tab
    property privoxyButton : missing value
    property privoxyStatusImage : missing value
    property weinreButton : missing value
    property weinreStatusImage: missing value
    property jsConsoleButton : missing value
    property jsConsoleStatusImage : missing value
    property aardwolfButton : missing value
    property aardwolfStatusImage: missing value
    property aardwolfPathButton : missing value
    
    -- aardwolf path
    property aardwolfScriptPath : missing value
    property aardwolfMatchPath : missing value
    
    on checkServicesRunning_(sender)
        
        checkServiceRunning_({ serviceName: "gumbode.weinre", button: weinreButton })
        checkServiceRunning_({ serviceName: "gumbode.aardwolf", button: aardwolfButton })
        checkServiceRunning_({ serviceName: "gumbode.privoxy", button: privoxyButton })
        
    end checkServicesRunning_
    
    on checkServiceRunning_(sender)
        
        if (button of sender is not equal to missing value) then
            set isRunning to isServiceRunning_(sender)
            if isRunning then
                set state of button of sender to 1
            else
                set state of button of sender to 0
            end if
        end if

    end checkServiceRunning_
    
    on startDefaultService_(sender) -- send serviceName and button as in checkServiceRunning + identifier
        try
        if (button of sender is not equal to missing value) then
            set theButton to button of sender
            
            -- start by default
            if state of theButton as string is equal to "1" then
                if not (isServiceRunning_(sender)) then
                    toggleService_(sender)
                end if
            else
                if isServiceRunning_(sender) then
                    toggleService_(sender)
                end if
            end if
            
        end if
        end try
    end startDefaultService_
    
    on toggleService_(sender)
        
        #log "state of sender: " & (state of sender)
        if (state of sender as string) is equal to "1" then
            set theCommand to "load"
        else
            set theCommand to "unload"
        end if
            
        set theService to POSIX path of (getFilePath_("org.gumbode." & identifier of sender & ".plist","","services"))
        #log "identifier: " & identifier of sender
        log "service: " & theService
        log "command: " & theCommand
        do shell script "launchctl " & theCommand & " " & theService
        
    end toggleService_
    
    on openWeinreConsole_(sender)
        
        if not isServiceRunning_({ serviceName: "gumbode.weinre" }) then
            set state of weinreButton to "1"
            toggleService_(weinreButton)
            restartPrivoxy_(sender)
        end if
        
        set theIP to do shell script (POSIX path of (path to resource "getipaddress"))
        open location "http://" & theIP & ":37128/client/#gumbode"
        
    end openWeinreConsole_
    
    on openJSConsole_(sender)
        
        if state of jsConsoleButton is not equal to "1" then
            set state of jsConsoleButton to "1"
            restartPrivoxy_(sender)
        end if
        
        try
            set theKey to do shell script "/bin/bash -c -l \"cat $HOME/.gumbode/privoxy/conf/jsconsole.key\""
            open location "http://jsconsole.com?:listen%20" & theKey
        end try
        
    end openJSConsole_
    
    on openAardwolfConsole_(sender)
        
        if not isServiceRunning_({ serviceName: "gumbode.aardwolf" })
            set state of aardwolfButton to "1"
            toggleService_(aardwolfButton)
            restartPrivoxy_(sender)
        end if
        
        set theIP to do shell script (POSIX path of (path to resource "getipaddress"))
        open location "http://" & theIP & ":8000/ui/index.html"
        
    end openAardwolfConsole_
    
    on openSafariConsole_(sender)
        
        tell application "Safari"
            
            activate
            
            try
                set theInspectorCount to length of windows whose title contains "Web Inspector"
                on error
                set theInspectorCount to 0
            end try
            
            if theInspectorCount is greater than 0 then
                activate (every window whose title contains "Web Inspector")		
            end if
            
        end tell
        
    end openSafariConsole_
    
    on updatePrivoxy_(sender)
        
        if aardwolfMatchPath is not equal to missing value then
            set theMatch to " " & aardwolfMatchPath
        else
            set theMatch to ""
        end if
        
        -- log "theMatch - " & theMatch
        
        set theScript to POSIX path of (path to resource "update-privoxy-config")
        -- set result to do shell script "/bin/bash -c -l \"" & theScript & " ''" & theMatch & "\""
        set result to (do shell script theScript & " ''" & theMatch)
        -- log "result -- " & result
    end updatePrivoxy_
    
    on restartPrivoxy_(sender)
        
        log "restarting privoxy ..."
        log "isPrivoxyRunning: " & isPrivoxyRunning
        if isPrivoxyRunning then
            set state of privoxyButton to "0"
            toggleService_(privoxyButton)
        end if
        
        set state of privoxyButton to "1"
        startPrivoxy_(privoxyButton)
        
    end restartPrivoxy_
    
    on startPrivoxy_(sender)
        
        set theHome to POSIX path of (path to home folder)
        set theSettings to theHome & ".gumbode/privoxy/services.ini"
        
        updatePrivoxy_(sender)

        -- reset services
        try
            do shell script "rm " & theSettings
        on error
            log theSettings & " file didn't exist"
        end try
        
        if isServiceRunning_({ serviceName: "gumbode.weinre" }) then do shell script "echo 'WEINRE=1' >> " & theSettings
        if isServiceRunning_({ serviceName: "gumbode.aardwolf" }) then do shell script "echo 'AARDWOLF=1' >> " & theSettings
        if state of jsConsoleButton is 1 then do shell script "echo 'JSCONSOLE=1' >> " & theSettings
        
        -- update config with services
        set theScript to POSIX path of (path to resource "startprivoxy")
        do shell script "/bin/bash -c -l '" & theScript & "'"
        
        toggleService_(sender)
        
        set isPrivoxyRunning to isServiceRunning_({ serviceName: "gumbode.privoxy" })
        
    end startPrivoxy_
    
    on startAardwolf_(sender)
        
        updateAardwolf_(sender)
        toggleService_(sender)
        
    end startAardwolf_
    
    on updateAardwolf_(sender)
        
        set theScript to POSIX path of (path to resource "update-aardwolf-config")
        do shell script "/bin/bash -c -l '" & theScript & " " & aardwolfScriptPath & "'"
        
    end updateAardwolf_
    
    on isServiceRunning_(sender)
       
        set theScript to POSIX path of (path to resource "isrunning") as string
        
        #log "checking service - " & theScript & " " & (serviceName of sender)
        set theResult to do shell script (theScript & " " & serviceName of sender)
        
        if serviceName of sender is equal to "gumbode.privoxy" and theResult is equal to "1" then
            set isPrivoxyRunning to true
        end if
            
        if theResult is equal to "1" then return true
        
        return false
        
    end isServiceRunning_
    
    
    on chooseAardwolfScriptPath_(sender)
        
        set theOldScriptPath to aardwolfScriptPath
        if theOldScriptPath is equal to missing value then
            set theOldScriptPath to (path to desktop) as alias
        else
            set theOldScriptPath to (aardwolfScriptPath as text) as POSIX file as alias
        end if
        
        set theNewScriptPath to POSIX path of (choose folder with prompt "Choose Path" default location theOldScriptPath)
        
        #log theNewScriptPath
        
        set my aardwolfScriptPath to theNewScriptPath
        tell defaults to setObject_forKey_(aardwolfScriptPath, "aardwolfScriptPath")
        
        updateAardwolf_({ scriptPath: aardwolfScriptPath })
        
    end chooseAardwolfScriptPath_
    
    -- installation tab
    property homebrewInstallButton : missing value
    property androidSDKInstallButton : missing value
    property androidPlatformsInstallButton : missing value
    property androidSystemImagesInstallButton : missing value
    property intelHAXMInstallButton : missing value
    property xcodeInstallButton : missing value
    property gitInstallButton : missing value
    property nodeInstallButton : missing value
    property privoxyInstallButton : missing value
    property weinreInstallButton : missing value
    property aardwolfInstallButton : missing value
    property androidRepoInstallButton : missing value
    
    
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
    
    on getFilePath_(fileName, type, dir)
        
        set theBundle to current application's NSBundle's mainBundle()
        if dir is not equal to "" then
            set thePath to theBundle's pathForResource_ofType_inDirectory_(fileName, type, dir) as text
        else
            set thePath to theBundle's pathForResource_ofType_(fileName, type) as text
        end if
        
        return thePath
        
    end getFilePath_
    
    on setBadge_(badgeText)
        
        #tell me to log badgeText

        set appDockTile to current application's NSApp's dockTile()
        appDockTile's setBadgeLabel_(badgeText)
    
    end setBadge_
    
    on badgeEmulators_(funny)
        
        #tell me to log "badging emulators"
        
        tell application "System Events"
            set emulators to get the name of every process whose name contains "emulator"
            repeat with emulator in emulators
                tell process emulator
                    set theTitle to title of first window
                    #tell me to log "first window of emulator: " & theTitle
                    set appDockTile to emulator's NSApp's dockTile()
                    appDockTile's setBadgeLabel_(theTitle)
                end tell
            end repeat
        end tell
        
    end badgeEmulators_
    
    on startAVD_(avdName)
        
        -- use privoxy if running
        if isPrivoxyRunning then
            set ipAddress to do shell script (path to resource "getipaddress")
            set environmentVars to "http_proxy=" & ipAddress & ":8118 "
        else
            set environmentVars to ""
        end if
        
        set result to (do shell script "/bin/bash -c -l \"" & environmentVars & (POSIX path of (path to resource "startavd") as string) & " " & avdName & "\" > /dev/null 2>&1")
        
    end startAVD_
    
    -- takes a package name and gives the longer name
    on translatePackageName_(package)
        
        if package is equal to "jsHybugger (1.2)" then
            return "jshybugger-proxy-1.2.0.apk"
        else if package is equal to "Firefox (22)" then
            return "firefox-22.apk"
        else if package is equal to "Opera (15)" then
            return "opera-15.apk"
        end if
        
    end translatePackageName_
    
    on installPackageClicked_(sender)
        if selectedDeviceRow is not equal to missing value then
            if selectedDevicePackage is not equal to missing value then
                                
                set theSerial to (theSerial of theDeviceList's objectAtIndex_(selectedRow of theDeviceListTableView as integer))
                set thePackage to getFilePath_(translatePackageName_(selectedDevicePackage as text), "", "redist")
            
                if selectedDevicePackage is not equal to missing value then
                    set my isPackageInstalling to true
                    do shell script "/bin/bash -c -l 'adb -s " & theSerial & " install " & thePackage & "'"
                    set my isPackageInstalling to false
                end if
                
            end if
        end if
    end installPackageClicked_
    
    on showAVDClicked_(sender)
        
        #tell me to log "showing avd ... "
        
        if selectedDeviceRow is not equal to missing value then
            set thePort to (thePort of theDeviceList's objectAtIndex_(selectedRow of theDeviceListTableView as integer))
            showAVD_(thePort)
        end if
        
    end showAVDClicked_
    
    on showAVD_(avdPort)
    
        tell application "System Events"
            
            repeat with theProcess in (processes whose name contains "emulator")
                
                if name of first item of windows of theProcess contains avdPort then
                    set the frontmost of theProcess to true
                end if
                
            end repeat
            
        end tell
        
    end showAVD_
        
    on manageEmulatorsClicked_(sender)
        
        do shell script "/bin/bash -c -l 'android avd' > /dev/null 2>&1"
        
    end manageEmulatorsClicked_
    
    on refreshDevicesClicked_(sender)

        tell theDeviceListArrayController
            removeObjects_(arrangedObjects())
        end tell
        
        getDeviceList_("")
        
    end refreshDevicesClicked_
    
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
                
                -- tell me to log avdListItemArray
                
                -- set avdListItem to current application's AVDitem's alloc()'s init()
                set avdListItem to { theName:"", theDevice:"", theManufacturer:"", thePlatform:"", theCPU:"", apiLevel: 0, apiName:"" }
                
                #tell me to log "1: " & first item of avdListItemArray
                #tell me to log "2: " & second item of avdListItemArray
                #tell me to log "3: " & third item of avdListItemArray
                #tell me to log "4: " & fourth item of avdListItemArray
                #tell me to log "5: " & fifth item of avdListItemArray
                #tell me to log "6: " & sixth item of avdListItemArray
                #tell me to log "7: " & seventh item of avdListItemArray
            
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
        
        tell application "System Events"
            set processCount to count of (processes whose name contains "emulator")
        end tell
        
        if processCount is not equal to count of theDeviceListArrayController's arrangedObjects() then
            
            #log "getdevicelist getpackages"
            set deviceListString to do shell script "/bin/bash -c -l " & (POSIX path of (path to resource "getpackages") as string)
            set deviceListArray to theSplit(deviceListString, return)
            
            #tell me to log "getting device list"
            
            tell theDeviceListArrayController
                removeObjects_(arrangedObjects())
            end tell
            
            #tell me to log "1"
            
            repeat with deviceItem in deviceListArray
                
                #tell me to log deviceItem
                
                set deviceItemPropertyArray to theSplit(deviceItem, tab)
                
                #tell me to log "deviceItemPropertyArray.length: " & length of deviceItemPropertyArray
                
                set deviceListItem to { theName: "", thePort: "", theSerial: "", theVersion: 0, hasHybugger: 0, hasBrowser: 0, hasChrome: 0, hasOpera: 0, hasFirefox: 0 }
                
                -- set deviceListItem to current application's Device's alloc()'s init()
                
                #tell me to log first item of deviceItemPropertyArray
                #tell me to log second item of deviceItemPropertyArray
                
                set theName of deviceListItem to trim(first item of deviceItemPropertyArray as text)
                set thePort of deviceListItem to trim(second item of deviceItemPropertyArray as text)
                set theSerial of deviceListItem to trim(third item of deviceItemPropertyArray as text)
                set theVersion of deviceListItem to trim(fourth item of deviceItemPropertyArray as text)
                
                if trim(fifth item of deviceItemPropertyArray as text) is equal to "1" then
                    #log "hasHybugger"
                    set hasHybugger of deviceListItem to bugIcon
                    else
                    set hasHybugger of deviceListItem to noIcon
                end if
                
                if trim(sixth item of deviceItemPropertyArray as text) is equal to "1" then
                    #log "hasBrowser"
                    set hasBrowser of deviceListItem to androidIcon
                    else
                    set hasBrowser of deviceListItem to noIcon
                end if
                
                if trim(seventh item of deviceItemPropertyArray as text) is equal to "1" then
                    #log "hasChrome"
                    set hasChrome of deviceListItem to chromeIcon
                    else
                    set hasChrome of deviceListItem to noIcon
                end if
                
                if trim(eighth item of deviceItemPropertyArray as text) is equal to "1" then
                    #log "hasOpera"
                    set hasOpera of deviceListItem to operaIcon
                    else
                    set hasOpera of deviceListItem to noIcon
                end if
                
                if trim(ninth item of deviceItemPropertyArray as text) is equal to "1" then
                    #log "hasFirefox"
                    set hasFirefox of deviceListItem to firefoxIcon
                    else
                    set hasFirefox of deviceListItem to noIcon
                end if
                
                theDeviceListArrayController's addObject_(deviceListItem)
                
            end repeat
            
        end if
        
        tell application "System Events"
            set processCount to count of (processes whose name contains "emulator")
        end tell
        
        -- this happens when the adb server has crapped out and we need to restart it
        if processCount is not equal to count of theDeviceListArrayController's arrangedObjects() then
            log "kill adb"
            do shell script "/bin/bash -c -l 'adb kill-server' > /dev/null 2>&1"
            getDeviceList_("")
        end if
        
        -- log "end getdevicelist"
        
        #tell me to log "2"
                        
    end getDeviceList_
    
    on tableDoubleClicked_(sender)
        
        set theAVD to trim(theName of theAVDListArrayController's arrangedObjects()'s objectAtIndex_(selectedRow of theAVDListTableView as integer) as string)
        startAVD_(theAVD)

    end tableDoubleClicked_
    
    on applicationWillFinishLaunching_(aNotification)
        
	end applicationWillFinishLaunching_
    
    on awakeFromNib()
        
        -- startAVDbutton's setAction("startAVD:")
        
        -- theAVDListTableView's setDoubleAction_("tableDoubleClicked:")
        
        -- theWindow's displayIfNeeded()

        #log "setting table actions"
        tell theDeviceListTableView to setDoubleAction_("showAVDClicked:")
        tell theDeviceListTableView to setTarget_(me)
        tell theAVDListTableView to setDoubleAction_("tableDoubleClicked:")
        tell theAVDListTableView to setTarget_(me)

        #log "setting icons"
        tell current application's NSImage
            
            set my androidIcon to imageNamed_("android-icon.png")
            set my bugIcon to imageNamed_("bug-icon.png")
            set my chromeIcon to imageNamed_("chrome-icon.png")
            set my operaIcon to imageNamed_("opera-icon.png")
            set my firefoxIcon to imageNamed_("firefox-icon.png")
            set my noIcon to imageNamed_("transparent.png")
            
        end tell

        #log "get avds"
        getAVDList_()
        
        #log "get devices"
        getDeviceList_("")
        
        #tell me to log "3"
        
        #log "schedule get devices"
        NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(30, me, "getDeviceList:", "", false)

        #log "check services"
        -- start from defaults?
        
        startDefaultService_({ serviceName: "gumbode.aardwolf", button: aardwolfButton })
        startDefaultService_({ serviceName: "gumbode.weinre", button: weinreButton })
        startDefaultService_({ serviceName: "gumbode.privoxy", button: privoxyButton })
        
        checkServicesRunning_("")

        #log "schedule check services"
        -- every 2 mins check service status
        NSTimer's scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(120, me, "checkServicesRunning:", "", false)
        
        -- Insert code here to initialize your application before any files are opened
        
        tell current application's NSUserDefaults to set defaults to standardUserDefaults()
        
        set thePath to POSIX path of (path to home folder)
        -- log "home folder: " & thePath
        
        tell defaults to registerDefaults_({ aardwolfScriptPath: thePath, aardwolfMatch: "" })
        
        tell defaults to set my aardwolfScriptPath to objectForKey_("aardwolfScriptPath")
        -- log "aardwolfScriptPath: " & aardwolfScriptPath
        
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