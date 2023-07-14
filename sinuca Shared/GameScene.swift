//
//  GameScene.swift
//  sinuca Shared
//
//  Created by Hilton Pintor on 12/07/23.
//

import SpriteKit

class GameScene: SKScene {
    // MARK: - NODES AND CONSTANTS
    fileprivate var whiteBall : SKShapeNode?
    fileprivate var coloredBalls : [SKShapeNode] = []
    fileprivate let ballRadius : CGFloat = 20
    fileprivate let ballLinearDamping = 0.8
    fileprivate let ballRestitution = 0.7
    
    fileprivate var table : SKShapeNode?
    fileprivate let tableHeightPercentage = 0.8
    fileprivate let tableWidthPercentage = 0.9
    
    fileprivate let holeRadiusPercentage = 1.5
    
    fileprivate let colorBallName = "colorBall"
    fileprivate let holeName = "hole"
    
    fileprivate let gameLogic: GameLogic = GameLogic(
        player1: Player(name: "Migge"),
        player2: Player(name: "Piku"),
        amountOfColoredBalls: 15
    )
    fileprivate var scoreBoard: SKLabelNode?
    
    fileprivate var cue: SKShapeNode?
    
    var lastMouseDown: NSEvent!
    var lastMouseUp: NSEvent!
    var lastMouseMoved: NSEvent!

    // MARK: - SCENE SETUP
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        // Remove gravity
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
        self.physicsWorld.contactDelegate = self
    }
    
    override func didSimulatePhysics() {
        let coloredBallsStopped = self.coloredBalls.reduce(
            true,
            { partialResult, coloredBall in
                partialResult && coloredBall.physicsBody!.velocity.length() < 8
            }
        )
        let whiteBallStopped = self.whiteBall!.physicsBody!.velocity.length() < 8
        
        if coloredBallsStopped && whiteBallStopped {
            self.cue?.isHidden = false
            updateCuePosition(event: self.lastMouseMoved)
            self.gameLogic.attemptToSwitchTurn()
            self.updateScoreBoard()
        } else {
            self.cue?.isHidden = true
        }
    }
    
    func setUpScene() {
        self.setupTable()
        self.setupWhiteBall()
        self.setupHoles()
        self.setupColorBalls()
        self.setupScoreBoard()
        self.setupCue()
    }
    
    // MARK: - Cue
    func setupCue() {
        self.cue = SKShapeNode.init(
            path: CGPath(
                rect: CGRect.init(
                    origin: CGPoint.zero,
                    size: CGSize.init(width: 10, height: -400)
                ),
                transform: nil),
            centered: false
        )
        self.addChild(self.cue!)
    }
    
    func updateCuePosition(event: NSEvent?) {
        guard let event = event else {
            return
        }
        let mouseLocation = event.location(in: self)
        let angle = atan2(mouseLocation.y - self.cue!.position.y , mouseLocation.x - self.cue!.position.x)
        self.cue!.zRotation = angle - .pi/2
        
        let mouseToBall = (mouseLocation - whiteBall!.position).normalized() * -50
        let cueNewPosition = CGPoint(
            x: whiteBall!.position.x + mouseToBall.dx,
            y: whiteBall!.position.y + mouseToBall.dy
        )
        self.cue?.position = cueNewPosition
    }
    
    // MARK: - SCOREBOARD
    func setupScoreBoard() {
        self.scoreBoard = SKLabelNode(text: "\(gameLogic.score())")
        self.scoreBoard?.position = CGPoint(x: 0, y: self.table!.frame.height/2 + 40)
        self.addChild(self.scoreBoard!)
    }
    
    func updateScoreBoard() {
        let score = gameLogic.score()
        var text = "\(score.0) \(score.1) x \(score.3) \(score.2)"
        switch score.4 {
        case .player1:
            text = "*" + text
        case .player2:
            text = text + "*"
        }
        self.scoreBoard?.text = text
    }
    
    // MARK: - TABLE
    func setupTable() {
        let tableSize = CGSize(
            width: self.scene!.size.width * tableWidthPercentage,
            height: self.scene!.size.height * tableHeightPercentage
        )
        self.table = SKShapeNode(rectOf: tableSize)
        if let table = self.table {
            table.physicsBody = SKPhysicsBody(edgeLoopFrom: table.frame)
            table.zPosition = 0
            table.fillColor = SKColor.init(hex: "#0e6f0eff")!
            table.strokeColor = SKColor.brown
            self.addChild(table)
        }
    }
    
    // MARK: - HOLES
    func setupHoles() {
        // TL
        makeHole(x: -self.table!.frame.width/2, y: self.table!.frame.height/2)

        // TM
        makeHole(x: self.table!.frame.midX, y: self.table!.frame.height/2)

        // TR
        makeHole(x: self.table!.frame.width/2, y: self.table!.frame.height/2)

        // BL
        makeHole(x: -self.table!.frame.width/2, y: -self.table!.frame.height/2)
        
        // BM
        makeHole(x: self.table!.frame.midX, y: -self.table!.frame.height/2)
        
        // BR
        makeHole(x: self.table!.frame.width/2, y: -self.table!.frame.height/2)
    }
    
    func makeHole(x: Double, y: Double) {
        let holeRadius = ballRadius * holeRadiusPercentage
        let hole = SKShapeNode(circleOfRadius: holeRadius)
        hole.position = CGPoint(x: x, y: y)
        hole.fillColor = SKColor.black
        hole.strokeColor = SKColor.black
        hole.physicsBody = SKPhysicsBody(circleOfRadius: holeRadius)
        hole.physicsBody?.isDynamic = false
        hole.name = holeName
        hole.zPosition = 1
        self.addChild(hole)
    }
    
    // MARK: - COLOR BALLS
    func setupColorBalls() {
        let diameter = ballRadius * 2
        self.coloredBalls = [
            //5
            makeBall(x: -self.table!.frame.width/2 + diameter*1, y: self.table!.frame.midY + diameter*2, color: "#FFFF00FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*1, y: self.table!.frame.midY + diameter, color: "#0000FFFF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*1, y: self.table!.frame.midY, color: "#FF0000FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*1, y: self.table!.frame.midY - diameter, color: "#800080FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*1, y: self.table!.frame.midY - diameter*2, color: "#FFA500FF"),
            //4
            makeBall(x: -self.table!.frame.width/2 + diameter*2, y: self.table!.frame.midY + diameter, color: "#008080FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*2, y: self.table!.frame.midY + ballRadius, color: "#A52A2AFF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*2, y: self.table!.frame.midY - ballRadius, color: "#000000FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*2, y: self.table!.frame.midY - diameter, color: "#EFF000FF"),
            //3
            makeBall(x: -self.table!.frame.width/2 + diameter*3, y: self.table!.frame.midY + ballRadius, color: "#FFC0CBFF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*3, y: self.table!.frame.midY, color: "#ADD8E6FF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*3, y: self.table!.frame.midY - ballRadius, color: "#800000FF"),
            //2
            makeBall(x: -self.table!.frame.width/2 + diameter*4, y: self.table!.frame.midY + ballRadius, color: "#CD853FFF"),
            makeBall(x: -self.table!.frame.width/2 + diameter*4, y: self.table!.frame.midY - ballRadius, color: "#800000FF"),
            //1
            makeBall(x: -self.table!.frame.width/2 + diameter*5, y: self.table!.frame.midY, color: "#D3D3D3FF")
        ]
    }
    
    func makeBall(x: Double, y: Double, color: String) -> SKShapeNode {
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = SKColor.init(hex: color)!
        ball.strokeColor = SKColor.init(hex: color)!
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        // by setting contactTestBitMask to the value of collisionBitMask we're saying, "tell me about every collision."
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.position = CGPoint(x: x, y: y)
        ball.name = colorBallName
        ball.zPosition = 2
        ball.physicsBody?.restitution = ballRestitution
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.linearDamping = ballLinearDamping
        self.addChild(ball)
        return ball
    }
    
    // MARK: - WHITE BALL
    func setupWhiteBall() {
        self.whiteBall = SKShapeNode(circleOfRadius: ballRadius)
        if let whiteBall = self.whiteBall {
            whiteBall.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
            whiteBall.physicsBody?.restitution = ballRestitution
            whiteBall.physicsBody?.allowsRotation = true
            whiteBall.fillColor = SKColor.init(hex: "#f9f1efff")!
            whiteBall.position = CGPoint(x: 0, y: 0)
            whiteBall.zPosition = 2
            whiteBall.physicsBody?.linearDamping = ballLinearDamping
            self.addChild(whiteBall)
        }
    }
}

// MARK: - COLLISIONS
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == colorBallName && nodeB.name == holeName {
            ballAndHoleCollision(ball: contact.bodyA.node!)
        } else if nodeB.name == colorBallName && nodeA.name == holeName {
            ballAndHoleCollision(ball: contact.bodyB.node!)
        }
    }
    
    func hitWhiteBall(mouselocation: CGPoint, duration: Double) {
        if let whiteBall = self.whiteBall {
            if let physicsBody = whiteBall.physicsBody {
                physicsBody.applyImpulse(
                    calculateImpulse(
                        ballPosition: whiteBall.position,
                        mousePosition: mouselocation,
                        duration: duration
                    )
                )
                self.gameLogic.hasHitWhiteBall()
            }
        }
    }
    
    func calculateImpulse(ballPosition: CGPoint, mousePosition: CGPoint, duration: Double) -> CGVector {
        let normalizedVector = (mousePosition - ballPosition).normalized()
        let strengthFactor = map(range: 0.0...1.2, domain: 10...300, value: duration)

        return normalizedVector * strengthFactor
    }

    func ballAndHoleCollision(ball: SKNode) {
        ball.removeFromParent()
        gameLogic.someoneScored()
        updateScoreBoard()
    }
}

#if os(OSX)
// MARK: Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        print("MOUSE DOWN")
        lastMouseDown = event
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("MOUSE ENTERED")
    }
    
    override func mouseMoved(with event: NSEvent) {
        self.lastMouseMoved = event
        self.updateCuePosition(event: self.lastMouseMoved)
    }
    
    override func mouseExited(with event: NSEvent) {
        print("MOUSE EXITED")
    }
    
    override func mouseUp(with event: NSEvent) {
        lastMouseUp = event
        
        // Get mouse position in scene coordinates
        let location = event.location(in: self)
        self.hitWhiteBall(
            mouselocation: location,
            duration: lastMouseUp.timestamp - lastMouseDown.timestamp
        )
        
        // Reset
        lastMouseUp = nil
        lastMouseDown = nil
    }

}
#endif

