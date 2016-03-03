//
//  DKAEffectObject.swift
//  APhoto
//
//  Created by Deniss Kaibagarovs on 02/03/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class DKAEffectObject: NSObject {
    var image:UIImage!
    var effectName:String!
    
    init(effectImage : UIImage, effectName : String) {
        self.image = effectImage
        self.effectName = effectName
    }
}
