//
//  InterfaceController.swift
//  APhotoWatch Extension
//
//  Created by Deniss Kaibagarovs on 27/05/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onAppleWatchButtonPress() {
        NSNotificationCenter.defaultCenter().postNotificationName("onWatchButonPressNotification", object:nil, userInfo:nil)
    }
}
