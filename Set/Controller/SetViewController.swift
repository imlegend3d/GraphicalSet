//
//  ViewController.swift
//  Set
//
//  Created by David on 2018-08-02.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, LayoutViews  {
    
    
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
            mainView.addSubview(deckView)
            mainView.addSubview(discardDeck)
            setGameUI()
        }
    }
    
    @IBOutlet weak var mainView: MainView! {
        didSet {
            layOutFor(view: mainView)
            
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealSwipe(_:)))
            swipe.direction = [.up]
            mainView.addGestureRecognizer(swipe)
            mainView.delegate = self
            
        }
    }
    
    // custom views
     private var deckView: SetCardView = {
        var deck = SetCardView(frame: CGRect.zero)
        deck.translatesAutoresizingMaskIntoConstraints = false
        return deck
    }()
    
    private let discardDeck: SetCardView = {
        let deck = SetCardView(frame: CGRect.zero)
        deck.translatesAutoresizingMaskIntoConstraints = false
        return deck
    }()
    
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
    
    private func addSetCardView(for card: Card) {
        let setCardButton = SetCardView()
        setCardButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setCardButton.card = card
        setCardButton.contentMode = .redraw
        cardButtons.append(setCardButton)
        setCardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardTapGesture)))
        mainView.addSubview(setCardButton)
    }
    
    @IBAction func addCardsBtn(_ sender: UIButton) {
        
        if setGame.fullDeck.count <= 2 {
            
            deckView.isHidden = true
        }
        if thereIsASet{
            handleSetState()
            addCards.isEnabled = setGame.fullDeck.count >= 1
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
    
    private var discardDeckShouldGoAway: Bool = false
    
    @IBAction func newGamePressed(_ sender: Any) {
        
        UIView.transition(with: mainView, duration: 2, options: [], animations: {
            self.mainView.subviews.forEach{
                $0.removeFromSuperview()
                self.discardDeckShouldGoAway = true
                
                self.animateRemoval(for: $0 as! SetCardView)
            }
        }
            , completion: { (finished) in
                ////New game animated.
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 3
                    , delay: 3, options: [], animations: {
                       //// delay for animation.
                }
                    , completion: {(position) in
                        switch position {
                        case .end:
                            if finished == true {
                                self.cardButtons = []
                                self.setGame = Set()
                                self.setGame.score = 0
                                self.addCards.isEnabled = true
                            }
                        default:
                            break
                        }
                }
                )
        }
        )
        mainView.addSubview(deckView)
        deckView.isHidden = false
    }
    
    // MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame = Set()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deckView.isFaceUp = false
        deckView.isHidden = false
        discardDeck.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: Action Methods
    
    private func addingCards() {
        
        if thereIsASet{
            handleSetState()
            addCards.isEnabled = setGame.fullDeck.count >= 1
        }
        if let cards = setGame.addThreeMoreCards() {
            for index in cards.indices {
                addSetCardView(for: cards[index])
            }
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
            
            selectedButtons.forEach {
                animateRemovalofMathcCards(for: $0)
                $0.card = nil
                cardButtons.remove(at: cardButtons.firstIndex(of: $0)!)
                $0.removeFromSuperview()
            }
        }
    }
    
    private func animateRemoval(for card: SetCardView) {
        
        var setCardView: SetCardView! { didSet { layOutFor(view: setCardView) } }
        setCardView = SetCardView(frame: card.frame)
        setCardView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        setCardView.card = card.card
        setCardView.cardIndex = card.cardIndex
        setCardView.draw(setCardView.frame)
        
        setCardView.isFaceUp = true
        setCardView.isHidden = false
        setCardView.contentMode = .redraw
        
        mainView.addSubview(setCardView)
        
        UIView.transition(with: setCardView, duration: 2.0, options: [], animations: {
            
            setCardView.bounds.size = CGSize(width: setCardView.frame.size.width * 1.2, height: setCardView.frame.size.height * 1.2)
            
        }
            , completion: { (finished) in
                UIView.transition(with: setCardView, duration: 2.0, options: [], animations: {
                    setCardView.center = self.mainView.center
                }
                    , completion: { (completed) in
                        
                        UIView.transition(with: setCardView, duration: 2, options: [], animations: {
                            
                            setCardView.frame = self.discardDeck.frame
                            
                        }
                            , completion: { finishes in
                                if finished {
                                    UIView.transition(with: setCardView, duration: 1, options: [.transitionFlipFromTop], animations: {
                                        setCardView.isFaceUp = false
                                    }
                                        , completion: { (finished) in
                                            self.discardDeck.isHidden = true
                                             self.discardDeck.isFaceUp = false
                                             ////When the animation has finished and the variable discardDeckShouldGoAway(newgame pressed) then perform the next part of the animation.
                                            if finished && self.discardDeckShouldGoAway {
                                                
                                                UIView.transition(with: setCardView, duration: 2, options: [], animations: {
                                                    setCardView.frame.origin = CGPoint(x: self.mainView.frame.width + 10.0, y: self.mainView.frame.height + 10.0)
                                                }
                                                    , completion: { completeed in
                                                        if completeed {
                                                            setCardView.removeFromSuperview()
                                                            self.discardDeckShouldGoAway = false
                                                        }
                                                }
                                                )
                                            }
                                    }
                                    )
                                }
                        }
                        )
                }
                )
        }
        )
    }
    
    
    ////Animation of removal of match cards(3 cards) this method is similar to the previous one but only for 3 carsd and doe not remove them all from the superview.
    private func animateRemovalofMathcCards(for card: SetCardView) {
        var setCardView: SetCardView! { didSet { layOutFor(view: setCardView) } }
        setCardView = SetCardView(frame: card.frame)
        setCardView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        setCardView.card = card.card
        setCardView.cardIndex = card.cardIndex
        setCardView.draw(setCardView.frame)
        
        setCardView.isFaceUp = true
        setCardView.isHidden = false
        setCardView.contentMode = .redraw
        
        mainView.addSubview(setCardView)
        
        UIView.transition(with: setCardView, duration: 2.0, options: [], animations: {
            
            setCardView.bounds.size = CGSize(width: setCardView.frame.size.width * 1.1, height: setCardView.frame.size.height * 1.1)
            
        }
            , completion: { (finished) in
                
                //self.cardBehavior.addItem(setCardView) - " Decided against using the UIDinamics animation where the matched card flyaway and bounce of one another, I did not find the animation to be elegant or necessary.
                
                UIView.transition(with: setCardView, duration: 2.0, options: [], animations: {
                    setCardView.center = self.mainView.center
                }
                    , completion: { (completed) in
                        
                        UIView.transition(with: setCardView, duration: 2, options: [], animations: {
                            
                            setCardView.frame = self.discardDeck.frame
                            
                        }
                            , completion: { finishes in
                                if finished {
                                    UIView.transition(with: setCardView, duration: 1, options: [.transitionFlipFromTop], animations: {
                                        setCardView.isFaceUp = false
                                    }
                                        , completion: { (finished) in
                                            ////When the card flips the discard deck apperas and the actual card is hidden so that when the screen is rotated the setCardView will be hidden.
                                            self.discardDeck.isHidden = false
                                             setCardView.isHidden = true
                                           
                                            if finished && self.discardDeckShouldGoAway {
                                                //// setCardView reapperas
                                                setCardView.isHidden = false
                                                ////Animation of moving the discardDeck off the table.
                                                UIView.transition(with: setCardView, duration: 2, options: [], animations: {
                                                    setCardView.frame.origin = CGPoint(x: self.mainView.frame.width + 10.0, y: self.mainView.frame.height + 10.0)
                                                }
                                                    , completion: { completeed in
                                                        if completeed {
                                                            setCardView.removeFromSuperview()
                                                            self.discardDeckShouldGoAway = false
                                                        }
                                                }
                                                )
                                            }
                                    }
                                    )
                                }
                        }
                        )
                }
                )
        }
        )
        
    }
    
    private func setGameUI(){
        scoreLabel.text = "Score: \(setGame.score)"
        
        //AutoLayout for the deckview
        deckView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        deckView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: (mainView.frame.width / 3 - (deckView.frame.width/2))).isActive = true
        deckView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.1).isActive = true
        deckView.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.1).isActive = true
        
        //AutoLayout for the discardDeck
        discardDeck.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        discardDeck.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: ((mainView.frame.width * 2/3) - (discardDeck.frame.width/2))).isActive = true
        discardDeck.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.1).isActive = true
        discardDeck.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.1).isActive = true
        
        
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
    
    var animationFinished = false
    
    // Delegate method:

    func updateViewFromModel() {
       
        var buttonsFrames = [CGRect]()
        let rectForGrid = CGRect(x: mainView.bounds.origin.x, y: mainView.bounds.origin.y, width: mainView.bounds.width, height: mainView.bounds.height * 0.90)
        let grid = aspectRatioGrid(for: rectForGrid , withNoOfFrames: setGame.playingCards.count)
        for index in self.cardButtons.indices {
            let insetXY = (grid[index]?.height ?? 400)/100
            let buttonFrame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
            ////cardButtons[index].frame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
            buttonsFrames.append(buttonFrame)
        }
        
        cardButtons.filter{$0.isFaceUp == false}.forEach{$0.frame = deckView.frame}
        
        var delay = 0.0
        
        for card in 0..<cardButtons.count {
            delay += 0.1
            
            UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut , animations: {
                
                self.cardButtons[card].frame = buttonsFrames[card]
            }
                , completion: {(finished:Bool) in
                    
                    if finished == true {
                        self.animationFinished = true
                        self.updateViewsWhenNeeded(cardNum: card)
                    }
            })
        }
    }
    
    func updateViewsWhenNeeded(cardNum: Int) {
        let timeDuration = 0.2 * Double(cardButtons.count)
        
        var delay = 0.1
        
        delay = Double(cardNum) * 0.05
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: timeDuration ,
            delay: delay,
            options: [.transitionFlipFromRight],
            animations: {
                if self.cardButtons[cardNum].isFaceUp == false {
                    self.cardButtons[cardNum].flipingCard(animated: true)
                }
        }
            //,  completion: <#T##((UIViewAnimatingPosition) -> Void)?##((UIViewAnimatingPosition) -> Void)?##(UIViewAnimatingPosition) -> Void#>
        )
    }
    
    // MARK: Objc methods
    
    @objc func dealSwipe(_ recognizer: UISwipeGestureRecognizer) {
        addingCards()
    }

    ////handles tap gestures to the cards.
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
        }
        setGameUI()
    }
}


