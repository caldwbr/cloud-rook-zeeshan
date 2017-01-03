//
//  DeckOfCards.swift
//  CloudRook
//
//  Created by Brad Caldwell on 1/2/17.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabaseUI

class DeckOfCards {
    
    var ref: FIRDatabaseReference!
    
    func createDeck() -> [Card] {
        var deckOCards = [Card]()
        var i = 0
        for x in 1...14 {
            for y in 1...4 {
                i += 1
                var funkyRank: Int
                var funkyVal: Int
                if x < 2 {
                    funkyRank = 15
                }else {
                    funkyRank = x
                }
                switch x {
                case 5:
                    funkyVal = 5
                case 10:
                    funkyVal = 10
                case 14:
                    funkyVal = 10
                case 1:
                    funkyVal = 15
                default:
                    funkyVal = 0
                }
                var newCard = Card(cardID: i, cardNumbeR: x, cardColoR: y, cardRanK: funkyRank, cardValuE: funkyVal)
                deckOCards.append(newCard)
            }
        }
        // IDs start at 1 and end at 57 which is the Rook - just the way I did it.
        
        var rookCard = Card(cardID: 57, cardNumbeR: 15, cardColoR: 5, cardRanK: 16, cardValuE: 20)
        deckOCards.append(rookCard)
        return deckOCards
    }
    
    func shuffleDeck(theDeck: [Card]) -> [Card] {
        var numOfCards = theDeck.count
        var halfDeck = [Card]()
        var biggerHalfDeck = [Card]()
        var partlyShuffledDeck = [Card]()
        var cutDeckTiny = [Card]()
        var cutDeckLarge = [Card]()
        var shuffledDeck = [Card]()
        for i in ((numOfCards-1)/2)..<numOfCards {
            biggerHalfDeck.append(theDeck[i])
        }
        for i in 0..<((numOfCards-1)/2) {
            halfDeck.append(theDeck[i])
        }
        for i in 0..<((numOfCards-1)/2) {
            partlyShuffledDeck.append(biggerHalfDeck[i])
            partlyShuffledDeck.append(halfDeck[i])
        }
        for i in 0...9 {
            cutDeckTiny.append(partlyShuffledDeck[i])
        }
        for i in 10...56 {
            cutDeckLarge.append(partlyShuffledDeck[i])
        }
        for i in 0...29 {
            shuffledDeck.append(cutDeckLarge[i])
            if i % 3 == 0 {
                shuffledDeck.append(cutDeckTiny[i])
            }
        }
        for i in 30...46 {
            shuffledDeck.append(cutDeckLarge[i])
        }
        
        return shuffledDeck
        
    }
    
    func dealCards(aDeck: [Card]) -> [Card] {
        var playerA = [Card]()
        var playerB = [Card]()
        var playerC = [Card]()
        var playerD = [Card]()
        var kitty = [Card]()
        var dealtDeck = [Card]()
        
        for i in 1...52 {
            switch (i % 4) {
            case 1:
                playerA.append(aDeck[(i-1)])
            case 2:
                playerB.append(aDeck[(i-1)])
            case 3:
                playerC.append(aDeck[(i-1)])
            case 4:
                playerD.append(aDeck[(i-1)])
            default:
                break
            }
        }
        for i in 53...57 {
            kitty.append(aDeck[(i-1)])
        }
        for i in 1...13 {
            dealtDeck.append(playerA[(i-1)])
        }
        for i in 1...13 {
            dealtDeck.append(playerB[(i-1)])
        }
        for i in 1...13 {
            dealtDeck.append(playerC[(i-1)])
        }
        for i in 1...13 {
            dealtDeck.append(playerD[(i-1)])
        }
        for i in 1...5 {
            dealtDeck.append(kitty[(i-1)])
        }
        
        return dealtDeck
    
    }

}

class Card {
    
    var cardId: Int
    var cardNumber: Int
    var cardColor: Int
    var cardRank: Int
    var cardValue: Int
    
    init(cardID: Int, cardNumbeR: Int, cardColoR: Int, cardRanK: Int, cardValuE: Int) {
        self.cardId = cardID
        self.cardNumber = cardNumbeR
        self.cardColor = cardColoR
        self.cardRank = cardRanK
        self.cardValue = cardValuE
    }
    
}
