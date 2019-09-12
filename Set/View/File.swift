//
//  File.swift
//  Set
//
//  Created by David on 2019-08-20.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

struct LayOutMetricsForCardView {
    static var borderWidth: CGFloat = 1.0
    static var borderWidthIfSelected: CGFloat = 3.0
    static var borderColorIfSelected: CGColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor
    
    
    static var borderWidthIfHinted: CGFloat = 4.0
    static var borderColorIfHinted: CGColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1).cgColor
    
    static var borderWidthIfMatched: CGFloat = 4.0
    static var borderColorIfMatched: CGColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor
    
    static var borderColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    static var borderColorForDrawButton: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
    static var borderWidthForDrawButton: CGFloat = 3.0
    static var cornerRadius: CGFloat = 8.0
}

struct ModelToView {
    static let shapes: [Shapes: String] = [.circle: "●", .triangle: "▲", .square: "■"]
    static var colors: [Colors: UIColor] = [.yellow: #colorLiteral(red: 0.8546305299, green: 0.8274853826, blue: 0.2449662983, alpha: 1), .blue: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), .red: #colorLiteral(red: 0.9421014786, green: 0, blue: 0.1308873296, alpha: 1)]
    static var alpha: [Fills: CGFloat] = [.solid: 1.0, .empty: 0.95, .stripe: 0.30]
    static var strokeWidth: [Fills: CGFloat] = [.solid: -5, .empty: 5, .stripe: -5]
}
