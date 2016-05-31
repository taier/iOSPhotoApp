//
//  InterfaceController.swift
//  APhotoWatch Extension
//
//  Created by Deniss Kaibagarovs on 27/05/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate{
    
var session : WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onAppleWatchButtonPress() {
        let messageToSend = ["Value":"takePhoto"]
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            }, errorHandler: {error in
                // catch any errors here
                print(error)
        })
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
    }
}
