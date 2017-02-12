//
//  GameModel.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 11/02/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import Foundation
import SwiftyJSON


class GameInvite {
    
    var id : String?
    var owner: User?
    var ownerName : String?
    var playerOne: User?
    var playerTwo: User?
    var playerThree: User?

    
    
    init(ownerName :String , id:String , gamers:[User])
    {
        self.id = id
        self.ownerName   = ownerName
        self.owner       = gamers[0]
        self.playerOne   = gamers[1]
        self.playerTwo   = gamers[2]
        self.playerThree = gamers[3]
        
        print("Init Players")
        print(self.owner!.id!)
        print(self.playerOne!.id!)
        print(self.playerTwo!.id!)
        print(self.playerThree!.id!)

    }

}
