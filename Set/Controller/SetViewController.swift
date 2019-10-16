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
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
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
    
    private var orientation: Bool = true
    
    private lazy var discardDeck: CGRect = {
        
        var rect = CGRect.zero
        if orientation == false {
             rect = CGRect(origin: CGPoint(x: mainView.bounds.width * 0.70, y: mainView.bounds.height * 0.85), size: CGSize(width: mainView.bounds.width * 0.1, height: mainView.bounds.height * 0.1))
        } else {
            rect = CGRect(origin: CGPoint(x: mainView.bounds.width * 0.70, y: mainView.bounds.height * 0.85), size: CGSize(width: mainView.bounds.width * 0.1, height: mainView.bounds.height * 0.1))
        }
        return rect
    }()
    
    private func addSetCardView(for card: Card) {
        let setCardButton = SetCardView()
        setCardButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        setCardButton.card = card
        setCardButton.contentMode = .redraw
        cardButtons.append(setCardButton)
        setCardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardTapGesture)))
        mainView.addSubview(setCardButton)
    }
    
    @IBAction func addCardsBtn(_ sender: UIButton) {
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
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2
                    , delay: 10, options: [], animations: {
                        if  self.discardDeckShouldGoAway == false {
                            if finished == true {
                                self.cardButtons = []
                                self.setGame = Set()
                                self.setGame.score = 0
                                self.addCards.isEnabled = true
                            }
                        }
                }
                    , completion: {(position) in
                        if finished == true {
                            self.cardButtons = []
                            self.setGame = Set()
                            self.setGame.score = 0
                            self.addCards.isEnabled = true
                        }
                        }
                )
        }
        )
    }
    
    // MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGame = Set()
        print("Deck: \(setGame.fullDeck.count)")
    
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            
           // discardDeck = CGRect(origin: CGPoint(x: self.mainView.bounds.width * 0.70, y: self.mainView.bounds.height * 0.90), size: CGSize(width: mainView.bounds.width * 0.1, height: mainView.bounds.height * 0.1))
            orientation = true
            print(orientation)
        } else if UIDevice.current.orientation.isLandscape {
            
            orientation = false
            print(orientation)
            
             //discardDeck = CGRect(origin: CGPoint(x: self.mainView.bounds.width * 0.70 , y: self.mainView.bounds.height * 0.90 ), size: CGSize(width: mainView.bounds.height * 0.1, height: mainView.bounds.width * 0.1))
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        cardButtons.forEach {
//            $0.flipingCard(animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateViewsWhenNeeded(delay: 5.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //updateViewsWhenNeeded()
        //updateViewFromModel()
    }
    
    private func addingCards() {
        
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
    //
    private func handleSetState(){
        
        let cards = selectedButtons.map {$0.card!}
       
        if cards.count == 3 && setGame.ifSetThenRemove(cards: cards) {
            
            self.hints.cards = setGame.hints
            setGameUI()
        
            selectedButtons.forEach {
                animateRemoval(for: $0)
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

            setCardView.bounds.size = CGSize(width: setCardView.frame.size.width * 1.4, height: setCardView.frame.size.height * 1.4)

        }
            , completion: { (finished) in
                UIView.transition(with: setCardView, duration: 2.0, options: [], animations: {
                    setCardView.center = self.mainView.center
                }
                    , completion: { (completed) in
                        
                        UIView.transition(with: setCardView, duration: 2, options: [], animations: {

                            setCardView.frame = self.discardDeck
                            
                        }
                            , completion: { finishes in
                                if finished {
                                    UIView.transition(with: setCardView, duration: 1, options: [.transitionFlipFromTop], animations: {
                                        setCardView.isFaceUp = false
                                    }
                                        , completion: { (finished) in
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
    
    var animationFinished = false
    
    func updateViewFromModel() {
        
        var buttonsFrames = [CGRect]()
        let rectForGrid = CGRect(x: mainView.bounds.origin.x, y: mainView.bounds.origin.y, width: mainView.bounds.width, height: mainView.bounds.height * 0.8)
        let grid = aspectRatioGrid(for: rectForGrid , withNoOfFrames: setGame.playingCards.count)
        for index in self.cardButtons.indices {
            let insetXY = (grid[index]?.height ?? 400)/100
            let buttonFrame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
            //cardButtons[index].frame = grid[index]?.insetBy(dx: insetXY, dy: insetXY) ?? CGRect.zero
            buttonsFrames.append(buttonFrame)
        }
        
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
        //let faceDownCards =  cardButtons.filter {$0.isFaceUp == false}
        //let timeInterval = (timeDuration / Double(faceDownCards.count))
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

