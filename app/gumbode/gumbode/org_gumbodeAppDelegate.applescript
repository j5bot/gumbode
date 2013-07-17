--
--  org_gumbodeAppDelegate.applescript
--  gumbode
--
--  Created by j5 on 7/8/13.
--  Copyright (c) 2013 gumbode. All rights reserved.
--

property NSMutableArray : class "NSMutableArray"

script org_gumbodeAppDelegate
	property parent : class "NSObject"
    
    property avdTableView : missing value
    
    property buttonWeinre : missing value
    property buttonHybugger : missing value
    property buttonJSConsole : missing value
    property buttonAardwolf : missing value
    
    property buttonWebkitDebugger : missing value
    
    property theDataSource : missing value
    
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
    
    on getAVDList_()
        
        set avdListString to do shell script (path to resource "scripts:getavdinfo") & " | cut -f 1 | grep -v 'AVD Name' | grep -v '^$' | grep -v -e '----'"
        set avdListArray to theSplit(avdListString,"\n")
        
        repeat with avdListArrayItem in avdListArray
            set avdListItemArray to theSplit(avdListArrayItem,"\t")
            set avdListItem to { theName:"", theDevice:"", theManufacturer:"", thePlatform:"", theCPU:"", apiLevel: 0, apiName:"" }
            set theName of avdListItem to first item of avdListArrayItem
            set theDevice of avdListItem to second item of avdListArrayItem
            set theManufacturer of avdListItem to third item of avdListArrayItem
            set thePlatform of avdListItem to fourth item of avdListArrayItem
            set theCPU of avdListItem to fifth item of avdListArrayItem
            set apiLevel of avdListItem to sixth item of avdListArrayItem
            set apiName of avdListItem to seventh item of avdListArrayItem
            
            theDataSource's addObject_(avdListItem)
        end repeat
        
        
    end getAVDList_
    
    on buttonWebkitDebuggerClicked_(sender)
        
        do shell script "launchctl unload " & (path to resource "services:org.gumbode.google.ios-webkit-debug-proxy.plist")
        do shell script "launchctl load " & (path to resource "services:org.gumbode.google.ios-webkit-debug-proxy.plist")
        
    end buttonWebkitDebuggerClicked_
    
    ##################################################
    # TableView
    
    (*
     Below are three NSTableView methods of which two are mandatory.
     
     Mandatory methods:
     These can be found in NSTableViewDataSource.
     tableView_objectValueForTableColumn_row_
     numberOfRowsInTableView_
     
     Optional method:
     This is found in NSTableViewDelegate.
     tableView_sortDescriptorsDidChange_
     *)
    
    on tableView_objectValueForTableColumn_row_(aTableView, aColumn, aRow)
        
        (*
         Check theDataSource's array size. If it is 0 then no need
         to go further in the code.
         
         Notice the use of "|" around count. Count is an AppleScript
         reserved word so we surround it with vertical bars.
         *)
        if theDataSource's |count|() is equal to 0 then return end
        
        (*
         The column identifier is the value you set IB
         *)
        set ident to aColumn's identifier
        
        (*
         NSMutableArray methods
         objectAtIndex_ returns the "record" from the array at
         the current iteration of aRow.
         
         objectForKey_ returns the specified item from the
         record. If ident is "age" then what is returned
         is the value of age.
         
         Note:
         The nice thing about this is that it is dynamic.
         We can add or remove as many columns as we like
         and never have to visit this code. The only
         unique area is where we are inserting an image.
         Take that out and this is boiler plate code.
         *)
        set theRecord to theDataSource's objectAtIndex_(aRow)
        set theValue to theRecord's objectForKey_(ident)
        
        (*
         isEqualToString_ is required to test the equivalency
         of ident against "theStatus."
         *)
        (* if ident's isEqualToString_("theStatus") then
            *)
            (*
             Same thing goes with testing theValue against 1.
             We need the intValue of theValue. Radio button
             groups return integer values.
             
             Note:
             How many of you have wanted to insert images
             into your AppleScript Studio table views?
             Look how easy it is to do now!
             
             Don't forget:
             To use an Objective-C class you must make
             a property reference first. We did this at
             the top with the following:
             
             property NSImage : class "NSImage"
             
             Images:
             You can find the "red.tiff", and "green.tiff"
             inside the project source folder.
             
             To add the images to your project right click
             on the "Resources" folder, choose "Add..." then
             "Existing files..."
             
             After choosing the files make sure the
             check box at the top of the window saying
             "Copy items into destination group's folder (if needed)"
             is checked.
             *)
           (* if theValue's intValue() = 0 then
                set theValue to NSImage's imageNamed_("green")
                else
                set theValue to NSImage's imageNamed_("red")
            end if
            
        end if *)
        
        (*
         Return the "value" of theValue to the table view for display.
         *)
        return theValue
    end tableView_objectValueForTableColumn_row_
    
    on numberOfRowsInTableView_(aTableView)
        
        (*
         This is a mess but it works. When we get sample projects
         from Sal we will see a better way.
         *)
        try
            if theDataSource's |count|() is equal to null then
                return 0
                else
                
                (*
                 Required method. Simply returns the integer value
                 representing the number of items in our array "theDataSource."
                 *)
                return theDataSource's |count|()
            end if
            on error
            return 0
        end try
    end numberOfRowsInTableView_
    
    on tableView_sortDescriptorsDidChange_(aTableView, oldDescriptors)
        
        (*
         When a user clicks on the table column headers this method
         is called. You can find it in the documentation under NSTableViewDelegate.
         
         For this to work you must set the "Sort Key" and "Selector" in the
         Table Column Attributes in IB.
         
         Note:
         Common Selectors are "compare:" and "caseInsensitiveCompare:"
         The colon is part of the name.
         *)
        
        set sortDesc to aTableView's sortDescriptors()
        theDataSource's sortUsingDescriptors_(sortDesc)
        aTableView's reloadData()
    
    end tableView_sortDescriptorsDidChange_
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened
        
	end applicationWillFinishLaunching_
    
    on awakeFromNib()
    
        if theDataSource is equal to missing value then
            set theDataSource to NSMutableArray's alloc()'s init()
            avdTableView's reloadData()
        end if
        
        getAVDList_()
        
    end awakeFromNib
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits
        
        -- unload ios-webkit-debug-proxy if running
        -- set isRunning to do shell script "launchctl list | grep -c ios-webkit-debug-proxy"
        -- if isRunning is not "" then do shell script "launchctl unload " & (path to resource "services:org.gumbode.google.ios-webkit-debug-proxy.plist")
        
        theDataSource's release()
        
        
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script