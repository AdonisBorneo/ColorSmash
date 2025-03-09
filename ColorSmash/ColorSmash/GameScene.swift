//
//  GameScene.swift
//  ColorSmash
//
//  Created by Adonis borneo Salihi on 08.03.2025..
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // Game elements
    private var scoreLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var heartsLabel: SKLabelNode?
    private var targetLine: SKSpriteNode?
    private var targetColorCircle: SKShapeNode?
    private var scoreContainer: SKShapeNode?
    private var targetContainer: SKShapeNode?
    private var heartsContainer: SKShapeNode?
    
    // Game state
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    private var hearts = 4
    private var isGameOver = false
    private var gameStarted = false
    private var gameSpeed: TimeInterval = 4.0
    private var lastSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 1.5
    private var targetColor: UIColor = .red
    private var difficultyLevel = 1
    
    // Available colors
    private let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple]
    
    // Safe area insets for notched devices
    private var topInset: CGFloat {
        return 100 // Increased safe area for notched devices
    }
    
    override func didMove(to view: SKView) {
        showStartScreen()
    }
    
    private func showStartScreen() {
        backgroundColor = .black
        
        // Create container
        let container = SKShapeNode(rectOf: CGSize(width: 300, height: 350), cornerRadius: 20)
        container.fillColor = UIColor(white: 0.1, alpha: 0.9)
        container.strokeColor = .clear
        container.lineWidth = 0
        container.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(container)
        
        // Game title
        let titleLabel = SKLabelNode(text: "COLOR SMASH")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 80)
        addChild(titleLabel)
        
        // High score
        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.fontSize = 25
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 20)
        addChild(highScoreLabel)
        
        // Instructions
        let instructionsLabel = SKLabelNode(text: "Match the colors")
        instructionsLabel.fontName = "AvenirNext-Bold"
        instructionsLabel.fontSize = 20
        instructionsLabel.fontColor = .white
        instructionsLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 20)
        addChild(instructionsLabel)
        
        let instructionsLabel2 = SKLabelNode(text: "when they hit the line!")
        instructionsLabel2.fontName = "AvenirNext-Bold"
        instructionsLabel2.fontSize = 20
        instructionsLabel2.fontColor = .white
        instructionsLabel2.position = CGPoint(x: size.width/2, y: size.height/2 - 45)
        addChild(instructionsLabel2)
        
        // Start button
        let startButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 30)
        startButton.fillColor = UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1.0)
        startButton.strokeColor = .clear
        startButton.lineWidth = 0
        startButton.position = CGPoint(x: size.width/2, y: size.height/2 - 90)
        startButton.name = "startButton"
        addChild(startButton)
        
        let startLabel = SKLabelNode(text: "START GAME")
        startLabel.fontName = "AvenirNext-Bold"
        startLabel.fontSize = 24
        startLabel.fontColor = .white
        startLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        addChild(startLabel)
        
        // Animate the start button
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        startButton.run(SKAction.repeatForever(pulse))
    }
    
    private func setupGame() {
        removeAllChildren()
        backgroundColor = .black
        
        // Setup unified game info container
        let gameInfoContainer = SKShapeNode(rectOf: CGSize(width: size.width - 40, height: 80), cornerRadius: 15)
        gameInfoContainer.position = CGPoint(x: size.width/2, y: size.height - topInset)
        gameInfoContainer.fillColor = UIColor(white: 0.15, alpha: 0.8)
        gameInfoContainer.strokeColor = .clear
        gameInfoContainer.lineWidth = 0
        addChild(gameInfoContainer)
        
        // Setup hearts label
        let heartsLbl = SKLabelNode(text: String(repeating: "❤️", count: hearts))
        heartsLbl.fontName = "AvenirNext-Bold"
        heartsLbl.fontSize = 30
        heartsLbl.verticalAlignmentMode = .center
        heartsLbl.position = CGPoint(x: 110, y: size.height - topInset)
        addChild(heartsLbl)
        heartsLabel = heartsLbl
        
        // Setup target color display
        let targetCircle = SKShapeNode(circleOfRadius: 25)
        targetCircle.position = CGPoint(x: size.width/2, y: size.height - topInset)
        targetCircle.lineWidth = 0
        targetColorCircle = targetCircle
        addChild(targetCircle)
        updateTargetColor()
        
        // Setup score labels
        let scoreLbl = SKLabelNode(text: "SCORE: 0")
        scoreLbl.fontName = "AvenirNext-Bold"
        scoreLbl.fontSize = 20
        scoreLbl.fontColor = .white
        scoreLbl.position = CGPoint(x: size.width - 110, y: size.height - topInset + 10)
        addChild(scoreLbl)
        scoreLabel = scoreLbl
        
        let highScoreLbl = SKLabelNode(text: "BEST: \(highScore)")
        highScoreLbl.fontName = "AvenirNext-Bold"
        highScoreLbl.fontSize = 16
        highScoreLbl.fontColor = .yellow
        highScoreLbl.position = CGPoint(x: size.width - 110, y: size.height - topInset - 15)
        addChild(highScoreLbl)
        highScoreLabel = highScoreLbl
        
        // Setup target line with gradient
        let gradientLine = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 6))
        gradientLine.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientLine.alpha = 0.3
        gradientLine.name = "targetLine"
        addChild(gradientLine)
        
        let targetLineNode = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 6))
        targetLineNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        targetLineNode.alpha = 0.8
        addChild(targetLineNode)
        targetLine = targetLineNode
        
        // Animate target line
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.5),
            SKAction.fadeAlpha(to: 0.4, duration: 0.5)
        ])
        targetLineNode.run(SKAction.repeatForever(pulseAction))
        
        gameStarted = true
    }
    
    private func updateHearts() {
        // Remove existing hearts
        self.childNode(withName: "heartsContainer")?.removeFromParent()
        
        // Create hearts container
        let heartsContainer = SKShapeNode(rectOf: CGSize(width: 140, height: 80), cornerRadius: 15)
        heartsContainer.position = CGPoint(x: 80, y: size.height - 50)
        heartsContainer.fillColor = UIColor(white: 0.15, alpha: 0.8)
        heartsContainer.strokeColor = .white
        heartsContainer.lineWidth = 2
        heartsContainer.name = "heartsContainer"
        addChild(heartsContainer)
        
        // Add hearts
        for i in 0..<hearts {
            let heart = SKSpriteNode(imageNamed: "heart") // Make sure to add heart image to assets
            heart.size = CGSize(width: 25, height: 25)
            heart.position = CGPoint(x: -45 + CGFloat(i * 30), y: 0)
            heartsContainer.addChild(heart)
        }
    }
    
    private func updateDifficulty() {
        let newLevel = score / 2000 + 1
        
        if newLevel > difficultyLevel {
            difficultyLevel = newLevel
            // Ensure minimum values for game speed and spawn interval
            gameSpeed = max(1.5, min(4.0, 4.0 - (Double(difficultyLevel) * 0.2)))
            spawnInterval = max(0.7, min(1.5, 1.5 - (Double(difficultyLevel) * 0.1)))
            
            showLevelUpEffect()
        }
    }
    
    private func showLevelUpEffect() {
        let levelUpLabel = SKLabelNode(text: "LEVEL UP!")
        levelUpLabel.fontName = "AvenirNext-Bold"
        levelUpLabel.fontSize = 30
        levelUpLabel.fontColor = .yellow
        levelUpLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        levelUpLabel.setScale(0)
        addChild(levelUpLabel)
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        levelUpLabel.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
    }
    
    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
            
            // Show new high score effect
            let newHighScoreLabel = SKLabelNode(text: "NEW HIGH SCORE!")
            newHighScoreLabel.fontName = "AvenirNext-Bold"
            newHighScoreLabel.fontSize = 30
            newHighScoreLabel.fontColor = .yellow
            newHighScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 150)
            addChild(newHighScoreLabel)
            
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
            let wait = SKAction.wait(forDuration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            
            newHighScoreLabel.run(SKAction.sequence([scaleUp, wait, fadeOut, remove]))
        }
    }
    
    private func updateTargetColor() {
        guard let newColor = colors.randomElement() else { return }
        targetColor = newColor
        targetColorCircle?.fillColor = targetColor
        targetColorCircle?.strokeColor = .clear
    }
    
    private func spawnCircle() {
        // Ensure we have colors to work with
        guard !colors.isEmpty else { return }
        
        var availableColors = colors.filter { $0 != targetColor }
        // Add target color twice to increase its probability
        availableColors.append(targetColor)
        availableColors.append(targetColor)
        
        guard let randomColor = availableColors.randomElement() else { return }
        
        let minX = 50.0
        let maxX = size.width - 50.0
        let randomX = CGFloat.random(in: minX...maxX)
        
        let circle = SKShapeNode(circleOfRadius: 30)
        circle.fillColor = randomColor
        circle.strokeColor = .clear
        circle.lineWidth = 0
        circle.position = CGPoint(x: randomX, y: -50)
        circle.name = "circle"
        circle.glowWidth = 0
        
        addChild(circle)
        
        // Ensure positive values for timing calculations
        let totalDistance = max(1, size.height + 100)
        let fadeStartY = size.height * 0.75
        let fadeStartTime = max(0, (fadeStartY + 50) / totalDistance * gameSpeed)
        let remainingTime = max(0, gameSpeed - fadeStartTime)
        
        // Move action
        let moveAction = SKAction.moveTo(y: size.height + 50, duration: gameSpeed)
        
        // Fade action
        let wait = SKAction.wait(forDuration: fadeStartTime)
        let fade = SKAction.fadeOut(withDuration: remainingTime)
        let fadeSequence = SKAction.sequence([wait, fade])
        
        // Check action
        let checkAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if circle.fillColor == self.targetColor {
                self.loseHeart()
            }
        }
        
        let removeAction = SKAction.removeFromParent()
        
        circle.run(SKAction.group([moveAction, fadeSequence]))
        circle.run(SKAction.sequence([
            SKAction.wait(forDuration: gameSpeed * 0.8),
            checkAction,
            SKAction.wait(forDuration: gameSpeed * 0.2),
            removeAction
        ]))
    }
    
    private func updateUI() {
        scoreLabel?.text = "SCORE: \(score)"
        highScoreLabel?.text = "BEST: \(highScore)"
        heartsLabel?.text = String(repeating: "❤️", count: hearts)
        
        // Animate hearts update
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        heartsLabel?.run(SKAction.sequence([scaleUp, scaleDown]))
        
        updateDifficulty()
    }
    
    private func loseHeart() {
        if !isGameOver {
            hearts -= 1
            
            // Shake the screen on miss
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -20, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05)
            ])
            scene?.run(shake)
            
            // Create miss effect
            if let targetLineNode = targetLine {
                createHitEffect(at: targetLineNode.position, success: false)
            }
            
            // Flash hearts red
            let redTint = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
            let removeTint = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
            heartsLabel?.run(SKAction.sequence([redTint, removeTint]))
            
            if hearts <= 0 {
                gameOver()
            } else {
                updateUI()
            }
        }
    }
    
    private func gameOver() {
        isGameOver = true
        updateHighScore()
        
        removeAction(forKey: "spawnCircles")
        
        // Create game over container
        let container = SKShapeNode(rectOf: CGSize(width: 300, height: 400), cornerRadius: 20)
        container.fillColor = UIColor(white: 0.1, alpha: 0.9)
        container.strokeColor = .clear // Remove outline
        container.lineWidth = 0
        container.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(container)
        
        // Game Over label
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        addChild(gameOverLabel)
        
        // Final score
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(score)")
        finalScoreLabel.fontName = "AvenirNext-Bold"
        finalScoreLabel.fontSize = 30
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(finalScoreLabel)
        
        // High score
        let highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.fontSize = 25
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        addChild(highScoreLabel)
        
        // Restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 30)
        restartButton.fillColor = UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1.0)
        restartButton.strokeColor = .clear // Remove outline
        restartButton.lineWidth = 0
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 120)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        let restartLabel = SKLabelNode(text: "PLAY AGAIN")
        restartLabel.fontName = "AvenirNext-Bold"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 130)
        addChild(restartLabel)
    }
    
    private func restartGame() {
        removeAllChildren()
        removeAllActions()
        
        score = 0
        hearts = 4
        isGameOver = false
        gameStarted = false
        gameSpeed = 4.0
        spawnInterval = 1.5
        difficultyLevel = 1
        
        showStartScreen()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver && gameStarted else { return }
        
        // Ensure positive time intervals
        let timeSinceLastSpawn = lastSpawnTime == 0 ? spawnInterval : currentTime - lastSpawnTime
        
        if timeSinceLastSpawn >= spawnInterval {
            spawnCircle()
            lastSpawnTime = currentTime
            
            // Ensure speed and interval stay within reasonable bounds
            gameSpeed = max(1.0, min(4.0, gameSpeed * 0.995))
            spawnInterval = max(0.5, min(1.5, spawnInterval * 0.998))
        }
    }
    
    private func createHitEffect(at position: CGPoint, success: Bool) {
        let emitter = SKEmitterNode()
        
        emitter.particleLifetime = 0.2
        emitter.numParticlesToEmit = 20
        emitter.particleBirthRate = 100
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = CGFloat.pi * 2
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -4
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.2
        emitter.particleColor = success ? .green : .red
        
        emitter.position = position
        addChild(emitter)
        
        let wait = SKAction.wait(forDuration: 0.2)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if !gameStarted {
            let nodes = nodes(at: location)
            if nodes.contains(where: { $0.name == "startButton" }) {
                setupGame()
            }
            return
        }
        
        if isGameOver {
            let nodes = nodes(at: location)
            if nodes.contains(where: { $0.name == "restartButton" }) {
                restartGame()
            }
            return
        }
        
        // Check all circles in the scene
        let hitZone: CGFloat = 50.0
        var hitCorrectColor = false
        var missedHit = false
        
        guard let targetLinePos = targetLine?.position.y else { return }
        
        enumerateChildNodes(withName: "circle") { node, stop in
            guard let circle = node as? SKShapeNode else { return }
            
            let distance = abs(circle.position.y - targetLinePos)
            if distance < hitZone {
                if circle.fillColor == self.targetColor {
                    hitCorrectColor = true
                    self.score += 500
                    self.createHitEffect(at: circle.position, success: true)
                    
                    let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
                    let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                    let remove = SKAction.removeFromParent()
                    circle.run(SKAction.sequence([scaleUp, fadeOut, remove]))
                    
                    self.updateTargetColor()
                    stop.pointee = true
                } else {
                    missedHit = true
                    self.loseHeart()
                    circle.run(SKAction.removeFromParent())
                    stop.pointee = true
                }
            }
        }
        
        if !hitCorrectColor && !missedHit {
            loseHeart()
        }
        
        updateUI()
    }
}
