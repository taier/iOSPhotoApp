//
//  WatchSessionManager.swift
//  APhoto
//
//  Created by Deniss Kaibagarovs on 30/05/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit
import WatchConnectivity

// Note that the WCSessionDelegate must be an NSObject
// So no, you cannot use the nice Swift struct here!
@available(iOS 9.0, *)
class WatchSessionManager: NSObject, WCSessionDelegate {
    
    // Instantiate the Singleton
    static let sharedManager = WatchSessionManager()
    private override init() {
        super.init()
    }
    
    // Keep a reference for the session,
    // which will be used later for sending / receiving data
    private let session = WCSession.defaultSession()
    
    // Activate Session
    // This needs to be called to activate the session before first use!
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
    
    
//    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
//        if let currentSession = session {
//            do {
//                try session.updateApplicationContext(applicationContext)
//            } catch let error {
//                throw error
//            }
//        }
//    }
    
    
    func sendMessageToCapture() {
        
        
//        try session.updateApplicationContext(
//            ["message" : "Take Photo"])
//        } catch let error as NSError {
//        }
    }
}
