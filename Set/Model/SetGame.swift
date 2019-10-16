//
//  SetGame.swift
//  Set
//
//  Created by David on 2018-08-02.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class Set: CustomStringConvertible{
    
    private (set) var fullDeck = Deck()
    
    lazy var playingCards: [Card] = fullDeck.draw(number: .twelve) ?? []
    
    var cardsRemoved : [Card] = []
    
    var score = 0
    
    private var indexOfASelectedCard0: Int? = nil
    private var indexOfASelectedCard1: Int? = nil
    private var indexOfASelectedCard2: Int? = nil
    
    private var indeces: [Int?] = []
    
    func getFirstDealtOfCards(){
        indeces = [indexOfASelectedCard0, indexOfASelectedCard1, indexOfASelectedCard2]
        guard let cards = fullDeck.draw(number: .twelve) else {return}
        playingCards += cards
        playingCards.shuffle()
    }
    
   func addThreeMoreCards()->[Card]?{
        guard let cards = fullDeck.draw(number: .three) else {return []}
        playingCards += cards
        
        return cards
    }
    
    func selectingCard(at index: Int) {
        
        playingCards[index].isSelected = !playingCards[index].isSelected
        
        let optionalIndex: Int? = index
        
        if index != indeces[0]!, index != indeces[1]!, index != indeces[2]! {
            for indexes in indeces {
                
                if indexes == nil{
                    guard let indexNum = indexes else {return}
                    indeces[indexNum] = optionalIndex
                    break
                }
            }
        } else {
            //if selecting the same index as a previous one, deselect the card
            if index == indeces[0]! {
                //deselecting card at this index
                indeces[0] = nil
            } else if index == indeces[1]! {
                indeces[1] = nil
            } else if index == indeces[2]!{
                indeces[2] = nil
            }
        }
    }
    
    func isSet(cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        var sumMatrix  = [Int](repeating: 0, count: cards[0].matrixWithIntValues.count)
        for card in cards {
            let matrix = card.matrixWithIntValues
            for valueIndex in matrix.indices {
                sumMatrix[valueIndex] += matrix[valueIndex]
            }
        }
        return sumMatrix.reduce(true, { $0 && ($1 % 3 == 0) })
    }
    
    func ifSetThenRemove(cards: [Card]) ->Bool{
        guard isSet(cards: cards) else {return false}
        
        for card in cards {
            if let index = playingCards.firstIndex(of: card) {
                let removedCard = playingCards.remove(at: index)
                cardsRemoved.append(removedCard)
            }
        }
        return true
    }
    
    var hints : [[Card]] {
        var hints = [[Card]]()
        for a in 0..<playingCards.count - 2 {
            for b in (a + 1)..<playingCards.count - 1{
                for c in (b + 1)..<playingCards.count {
                    let cards = [playingCards[a], playingCards[b], playingCards[c]]
                    if isSet(cards: cards) {
                        hints.append(cards)
                    }
                }
            }
        }
        return hints
    }
    
    var description: String {
        var returnString = ""
        returnString += "cardsOnTable: \(playingCards.count)\n \(playingCards)"
        returnString += "\n\ncardsTakenFromTable: \(playingCards.count)\n \(playingCards)"
        let date = Date()
        let hints = self.hints
        returnString += "\n\nHints: \(hints.count)\n \(hints) \n\nIt took hints \(-date.timeIntervalSinceNow) seconds"
        return returnString
    }
}
