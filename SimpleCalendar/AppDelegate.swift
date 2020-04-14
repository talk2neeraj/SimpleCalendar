//
//  AppDelegate.swift
//  SimpleCalendar
//
//  Created by Neeraj Singh on 4/10/20.
//  Copyright © 2020 Neeraj Singh. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.contentViewController = CalendarViewController(nibName: nil, bundle: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

