//
//  Deck.swift
//  Set
//
//  Created by David on 2018-08-02.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

struct Deck: CustomStringConvertible{
    
    private(set) var cards = [Card]()
    
    
    var count: Int {
        return cards.count
    }
    
    enum numberOfCardsToDraw: Int {
        case three = 3
        case twelve = 12
    }
    
    init() {
        let range = 1...3
        for numbers in range {
            for color in range {
                for shape in range {
                    for fill in range {
                        let card = Card(with: numbers, color , shape, fill)
                        cards.append(card)
                    }
                }
            }
        }
    }
    
    mutating func draw(number: numberOfCardsToDraw = .three ) -> [Card]? {
        if cards.count > 0 && cards.count > number.rawValue {
            var cardsBundle = [Card]()
            for _ in 1...number.rawValue {
                
                cardsBundle.append(cards.remove(at: cards.count.arc4random))
            }
            return cardsBundle
        } else {
            return nil
        }
    }
    
    var description: String {
        var description = ""
        for card in cards {
            description += "\(card)\n"
        }
        return description
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
