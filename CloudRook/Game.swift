//
//  Game.swift
//  CloudRook
//
//  Created by Brad Caldwell on 1/2/17.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import Foundation
class Game {
    
    func playRound(){
        
        var gameDeckObject = DeckOfCards()
        var gameDeck = gameDeckObject.createDeck()
        var beenDealtDeck = [Card]()
        gameDeck = gameDeckObject.shuffleDeck(theDeck: gameDeck)
        
        //Provides some randomness to the process
        var shuffleTimes = arc4random_uniform(UInt32(15))
        for i in 0...shuffleTimes {
            gameDeck = gameDeckObject.shuffleDeck(theDeck: gameDeck)
        }
        beenDealtDeck = gameDeckObject.dealCards(aDeck: gameDeck)
        
    }
    
}
