//
//  Menu.swift
//  Kitty Cannon!
//
//  Created by James Paulk on 1/4/16.
//  Copyright © 2016 James Paulk. All rights reserved.
//
import SpriteKit

class Menu: SKNode
{
    var playerScore = Int()
    var playerHighScore = Int()
    
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var titleBG = SKSpriteNode()
	let diff = SKLabelNode(text: "Difficulty: Easy")
    
    override init()
	{
        super.init()
		
		var titleFontSize: CGFloat = 30
		if UIScreen.main.bounds.width <= 320
		{
			titleFontSize = 25
		}
		else if UIScreen.main.bounds.width > 320
		{
			titleFontSize = 30
		}
        titleBG = SKSpriteNode(imageNamed: "menuBG")
        titleBG.size = CGSize(width: UIScreen.main.bounds.width - 20, height: 260)
        titleBG.position = CGPoint(x: self.frame.width * 0.5, y: -40)
        titleBG.zPosition = 1
        titleBG.alpha = 0.95
        self.addChild(titleBG)
        
        let title = SKLabelNode(fontNamed: "akaDylan Collage")
        title.text = "KITTY CANNON!"
        title.fontSize = titleFontSize
        title.fontColor = UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0)
        title.position = CGPoint(x: self.frame.width * 0.5, y: 85)
        title.zPosition = 2
        titleBG.addChild(title)

		if difficultyMultiplier == 1
		{
			diff.text = "Difficulty: Easy"
		}
		else if difficultyMultiplier == 2.25
		{
			diff.text = "Difficulty: Medium"
		}
		else if difficultyMultiplier == 3.5
		{
			diff.text = "Difficulty: Hard"
		}
		diff.fontName = "akaDylan Collage"
		diff.fontSize = 22
		diff.fontColor = UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0)
		diff.zPosition = 2
		diff.position = CGPoint(x: self.frame.width * 0.5, y: 45)
		titleBG.addChild(diff)

        let scoreBoard = SKLabelNode(fontNamed: "akaDylan Collage")
        scoreBoard.text = "Score    |    Best "
        scoreBoard.fontSize = 25
        scoreBoard.fontColor = UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 1.0)
        scoreBoard.position = CGPoint(x: self.frame.width * 0.5, y: 10)
        scoreBoard.zPosition = 2
        titleBG.addChild(scoreBoard)
        
        let playButtonBG = SKSpriteNode(color: UIColor(colorLiteralRed: 0.3, green: 0.85, blue: 0.3, alpha: 0.0), size: CGSize(width: 88, height: 44))
        playButtonBG.name = "playButton"
        playButtonBG.position = CGPoint(x: self.frame.width * 0.5,  y: -85)
        playButtonBG.zPosition = 2
        titleBG.addChild(playButtonBG)
        
        let playButton = SKLabelNode(fontNamed: "akaDylan Collage")
        
        playButton.text = "tap to play"
        playButton.name = "playButton"
        playButton.fontSize = 35
        playButton.fontColor = UIColor(red: 0.1, green: 0.75, blue: 0.4, alpha: 1.0)
        playButton.position = CGPoint(x: self.frame.width * 0.5, y: -10)
        playButton.zPosition = 11
        playButtonBG.addChild(playButton)
        
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: -85, y: -35)
        scoreLabel.zPosition = 2
        titleBG.addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: "Helvatica")
        highScoreLabel.fontSize = 40
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.position = CGPoint(x: 80, y: -35)
        highScoreLabel.zPosition = 2
        titleBG.addChild(highScoreLabel)
        
        self.playerScore = 0
        self.playerHighScore = 0
    }
    
    func setScore(_ score: Int)
    {
        self.playerScore = score
        scoreLabel.text = String(playerScore)
    }
    
    func setHighScore(_ highScore: Int)
    {
        self.playerHighScore = highScore
        highScoreLabel.text = String(playerHighScore)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
