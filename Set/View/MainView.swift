//
//  MainView.swift
//  Set
//
//  Created by David on 2019-09-11.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

protocol LayoutViews: class {
    func updateViewFromModel()
    func updateViewsWhenNeeded(cardNum: Int)
}

class MainView: UIView {

    weak var delegate: LayoutViews?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.updateViewFromModel()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        delegate?.updateViewsWhenNeeded(cardNum: 0)
    }

}
