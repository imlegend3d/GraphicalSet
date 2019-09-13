//
//  ViewController.swift
//  Set
//
//  Created by David on 2018-08-02.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, LayoutViews {
    
    var cardButtons: [SetCardView] = []

    
    @IBOutlet weak var scoreLabel: UILabel! { didSet { layOutFor(view: scoreLabel) } }
    
    @IBOutlet weak var hintBtn: UIButton! { didSet { layOutFor(view: hintBtn) } }
    
    @IBOutlet weak var newGameBtn: UIButton! { didSet { layOutFor(view: newGameBtn) } }
    
    @IBOutlet weak var addCards: UIButton! {
        didSet {
            layOutFor(view: addCards)
            addCards.titleLabel?.numberOfLines = 0
            addCards.setTitle("None", for: .disabled)
        }
    }
    
    private var setGame: Set! {
        didSet {
            let playingCards = setGame.playingCards
            hints.cards = setGame.hints
            playingCards.indices.forEach { addSetCardView(for: playingCards[$0])}
            setGameUI()
            
        }
    }
    
    @IBOutlet weak var mainView: MainView! {
        didSet {
            layOutFor(view: mainView)
            
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(onDrawCardSwipe(_:)))
            swipe.direction = [.down]
            mainView.addGestureRecognizer(swipe)
            
            mainView.delegate = self
            
        }
    }
    
    private var timer: Timer?
    
    private var lastHint: [SetCardView]?
    
    private var selectedButtons: [SetCardView] {
        return cardButtons.filter{ cardView in
            cardView.stateOfCard == .selected || cardView.stateOfCard == .selectedAndmatched }
    }
    
    private var hints: (cards: [[Card]], index: Int) = ([[]] , 0) {

        didSet{
            if hints.index == oldValue.index {
                hints.index = 0
            }
            self.hints.cards = setGame.hints
            
            hintBtn?.isEnabled = !hints.cards.isEmpty ? true : false

            hintBtn?.setTitle("hints: \(hints.cards.count)", for: .normal)
        }
    }
    
    private var thereIsASet: Bool {
        let cards = selectedButtons.map {$0.card!}
        
        if cards.count == 3 && setGame.isSet(cards: cards){
            selectedButtons.forEach { $0.stateOfCard = .selectedAndmatched}
            
            addCards.isEnabled = true
            return true
        }
        return false
    }
    @IBAction func AddCardsBtn(_ sender: UIButton) {
        if thereIsASet{
            handleSetState()
            addCards.isEnabled = setGame.fullDeck.count >= 2
        }
        if let cards = setGame.addThreeMoreCards() {
            for index in cards.indices {
                addSetCardView(for: cards[index])
            }
            //hints.cards = setGame.hints
        } else {
            addCards.isEnabled = false
        }
        hints.cards = setGame.hints
        setGameUI()
    }
    
    @IBAction func hintBtnPressed(_ sender: Any) {
        
        timer?.invalidate()
        lastHint?.forEach {$0.stateOfCard = .unselected}
        selectedButtons.forEach {$0.stateOfCard = .unselected}
        
        let cardsWithSet = buttonsFor(cards: hints.cards[hints.index])
        
        cardsWithSet.forEach {$0.stateOfCard = .hinted}
        
        lastHint = cardsWithSet
        
        hints.index = hints.index < hints.cards.count - 1 ? hints.index + 1 : 0
        
        timer = Timer.scheduledTimer(withTimeInterval:2, repeats: false, block: { timer in cardsWithSet.forEach {[weak self] in
            
            if $0.stateOfCard == .hinted {
                $0.stateOfCard = .unselected
                self!.lastHint = nil
                }
            }
            //self!.lastHint = nil
        })
    }
    
    @IBAction func newGamePressed(_ sender: Any) {
        cardButtons.forEach{
            $0.card = nil
            $0.removeFromSuperview()
        }
        cardButtons = []
        
        setGame = Set()
        
        setGame.score = 0
        
        addCards.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setGame = Set()
       
    }
    
    private func addSetCardView(for card: Card) {
        let setCardButton = SetCardView()
        setCardButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        setCardButton.card = card
        setCardButton.contentMode = .redraw
        cardButtons.append(setCardButton)
        setCardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardTapGesture)))
        mainView.addSubview(setCardButton)
        
    }
    
    private func addingCards() {
        
        if thereIsASet{
            handleSetState()
            addCards.isEnabled = setGame.fullDeck.count >= 2
        }
        if let cards = setGame.addThreeMoreCards() {
            for index in cards.indices {
                addSetCardView(for: cards[index])
            }
            //hints.cards = setGame.hints
        } else {
            addCards.isEnabled = false
        }
        hints.cards = setGame.hints
        setGameUI()
    }
    
    //
    private func handleSetState(){
        
        let cards = selectedButtons.map {$0.card!}
        if cards.count == 3 && setGame.ifSetThenRemove(cards: cards) {
            self.hints.cards = setGame.hints
            setGameUI()
            selectedButtons.forEach { $0.card = nil
                cardButtons.remove(at: cardButtons.firstIndex(of: $0)!)
                $0.removeFromSuperview()
            }
        }
    }
    
    private func setGameUI(){
        // cardsDisplayed.forEach {$0.backgroundColor = $0.card != nil ? UIColor.lightGray : UIColor.clear }
        scoreLabel.text = "Score: \(setGame.score)"
    }
    
    private func buttonsFor(cards: [Card]) -> [SetCardView]{
        var buttons: [SetCardView] = []
        for card in cards {
            if let button = (cardButtons.filter {$0.cardIndex == card.hashValue}).first {buttons.append(button)}
        }
        return buttons
    }
    
    func layOutFor(view: UIView) {
        view.layer.cornerRadius = LayOutMetricsForCardView.cornerRadius
        view.layer.borderWidth = LayOutMetricsForCardView.borderWidthForDrawButton
        view.clipsToBounds = true
    }

    // Delegate method:
    
    func updateViewFromModel() {
        let grid = aspectRatioGrid(for: mainView.bounds, withNoOfFrames: setGame.playingCards.count)
        for index in cardButtons.indices {
            let insetXY = (grid[index]?.height ?? 400)/100
            cardButtons[index].frame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
        }
    }
    
    //Objc methods
    
    @objc func onDrawCardSwipe(_ recognizer: UISwipeGestureRecognizer) {
        addingCards()
    }
    
    @objc func onDrawCardButton() {
        addingCards()
    }
    
    @objc func onCardTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard let tappedCard = recognizer.view as? SetCardView else {return}
        if selectedButtons.count == 3 {
            if thereIsASet {
                handleSetState()
            }
            selectedButtons.forEach {$0.stateOfCard = .unselected}
        }
        tappedCard.stateOfCard = tappedCard.stateOfCard == .selected ? .unselected : .selected
        if thereIsASet {
            setGame.score += 3
            setGameUI()
        }
        setGameUI()
    }
}

