//
//  GameLogic.swift
//  sinuca
//
//  Created by Hilton Pintor on 12/07/23.
//

import Foundation

class Player {
    let name: String
    var score: Int
    
    init(name: String) {
        self.name = name
        self.score = 0
    }
    
    func increaseScore() {
        score += 1
    }
    
    func resetScore() {
        score = 0
    }
}

enum TurnOwner {
    case player1
    case player2
}

class Turn {
    var turnOwner: TurnOwner
    var amountScored: Int
    var hasHitWhiteBall: Bool
    
    init(turnOwner: TurnOwner, amountScored: Int) {
        self.turnOwner = turnOwner
        self.amountScored = amountScored
        self.hasHitWhiteBall = false
    }
}

class GameLogic {
    let player1: Player
    let player2: Player?
    let amountOfColoredBalls: Int
    var ballsInHole: Int // lá ele
    var turns: [Turn]
    
    init(player1: Player, player2: Player?, amountOfColoredBalls: Int) {
        self.player1 = player1
        self.player2 = player2
        self.amountOfColoredBalls = amountOfColoredBalls
        self.ballsInHole = 0
        self.turns = []
        startMatch()
    }
    
    func startMatch() {
        turns.append(Turn.init(turnOwner: .player1, amountScored: 0))
    }
    
    func hasHitWhiteBall() {
        let lastTurn = turns.last!
        lastTurn.hasHitWhiteBall = true
    }
    
    func attemptToSwitchTurn() {
        let lastTurn = turns.last!
        if lastTurn.hasHitWhiteBall {
            finishTurn()
        }
    }
    
    func finishTurn() {
        let lastTurn = turns.last!
        let nextPlayer: TurnOwner
        switch lastTurn.turnOwner {
        case .player1:
            nextPlayer = .player2
        case .player2:
            nextPlayer = .player1
        }
        turns.append(Turn.init(turnOwner: nextPlayer, amountScored: 0))
    }
    
    func score() -> (String, Int, String, Int, TurnOwner) {
        let lastTurn = turns.last!
        
        return (player1.name, player1.score, player2?.name ?? "", player2?.score ?? 0, lastTurn.turnOwner)
    }
    
    func someoneScored() {
        if let lastTurn = self.turns.last {
            lastTurn.amountScored += 1
            switch lastTurn.turnOwner {
            case .player1:
                player1Scored()

            case .player2:
                player2Scored()
            }
        }
    }
    
    func player1Scored() {
        player1.increaseScore()
        ballsInHole += 1
    }
    
    func player2Scored() {
        player2?.increaseScore()
        ballsInHole += 1
    }
    
    func isGameOver() -> Bool {
        return ballsInHole == amountOfColoredBalls
    }
}
