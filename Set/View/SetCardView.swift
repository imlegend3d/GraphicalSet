//
//  CardButton.swift
//  Set
//
//  Created by David on 2019-08-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

class SetCardView: UIView{
    
     private let objectSizeToLineWidthRatio: CGFloat = 10
    
    var cardIndex = 0
    
    var card: Card? {
        didSet{
            cardIndex = card != nil ? card!.hashValue : 0
            stateOfCard = .unselected
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isFaceUp: Bool = false { didSet {setNeedsLayout(); setNeedsDisplay()}}

    enum StateOfCard {
        case unselected
        case selected
        case selectedAndmatched
        case hinted
    }
    
    var stateOfCard : StateOfCard = .unselected {
        didSet {
            switch stateOfCard {
            case .unselected:
            
                layer.borderWidth = LayOutMetricsForCardView.borderWidth
                layer.borderColor = LayOutMetricsForCardView.borderColor
                
            case .selected:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfSelected
                layer.borderColor = LayOutMetricsForCardView.borderColorIfSelected
                
            case .selectedAndmatched:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfMatched
                layer.borderColor = LayOutMetricsForCardView.borderColorIfMatched
                
            case .hinted:
                layer.borderWidth = LayOutMetricsForCardView.borderWidthIfHinted
                layer.borderColor = LayOutMetricsForCardView.borderColorIfHinted
            }
        }
    }
    
    private func setBorderLayOut(){
        layer.borderWidth = LayOutMetricsForCardView.borderWidth
        layer.borderColor = LayOutMetricsForCardView.borderColor
        layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setNeedsLayout()
    }
    
    override func draw(_ rect: CGRect) {
        
        if isFaceUp {
            if let card = card {
                var color = UIColor()
                switch card.color {
                case .yellow: color = #colorLiteral(red: 0.8546305299, green: 0.8274853826, blue: 0.2449662983, alpha: 1)
                case .blue: color = #colorLiteral(red: 0.2982538533, green: 0.2003276881, blue: 0.9918107551, alpha: 1)
                case .red: color = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
                color.setFill()
                color.setStroke()
                
                let objectsForSet = SetTypeObject(in: bounds, for: card.shape, numberOfObjects: card.number.rawValue)
                let path = objectsForSet.bezierPath
                path.lineWidth = objectsForSet.objectHeight * objectsForSet.fill / objectSizeToLineWidthRatio
                path.stroke()
                switch card.fill {
                case .empty:
                    break
                case .solid:
                    path.fill()
                case .stripe:
                    path.addClip()
                    let stripesPath = objectsForSet.bezierPathForStripes
                    stripesPath.lineWidth = objectsForSet.objectHeight * objectsForSet.fill / (objectSizeToLineWidthRatio * 2)
                    stripesPath.stroke()
                }
            }
        } else {
            if let cardsBackImage = UIImage(named: "cardback"){
                cardsBackImage.draw(in: bounds)
            }
        }
        
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.clipsToBounds = true
        setBorderLayOut()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        setBorderLayOut()
    }
    
    func flipingCard(animated: Bool = true) {
        if animated {
            UIView.transition(with: self,
                              duration: 0.1,
                              options: [.transitionFlipFromLeft],
                              animations: { self.isFaceUp = true}
                            //, completion: nil
                            )
        } else {
            self.isFaceUp = true
        }
    }
    
}
