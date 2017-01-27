//
//  MainMenu.swift
//  KittyCannon.v002
//
//  Created by James Paulk on 2/21/16.
//  Copyright © 2016 James Paulk. All rights reserved.
//

import SpriteKit
import AVFoundation

var soundOn = true
var difficultyMultiplier = 0.0

class MainMenu: SKScene
{
    var soundButton: SKSpriteNode!
    var infoWindow: SKSpriteNode!
    var hardButton: SKSpriteNode!
    var mediumButton: SKSpriteNode!
    var easyButton: SKSpriteNode!
	var title: SKSpriteNode!
	var infoButton: SKSpriteNode!

	var moveItDown = false

    override func didMove(to view: SKView)
	{
		difficultyMultiplier = 0.0
		if UIScreen.main.bounds.height < 500
		{
			moveItDown = true
		}
        soundButton = self.childNode(withName: "sound") as! SKSpriteNode
        infoWindow = self.childNode(withName: "infoWindow") as! SKSpriteNode
        hardButton = self.childNode(withName: "hard") as! SKSpriteNode
        mediumButton = self.childNode(withName: "medium") as! SKSpriteNode
        easyButton = self.childNode(withName: "easy") as! SKSpriteNode
		title = self.childNode(withName: "Title") as! SKSpriteNode
		infoButton = self.childNode(withName: "info") as! SKSpriteNode

		if moveItDown
		{
			soundButton.position.y -= 140
			infoButton.position.y -= 140
			title.position.y -= 140
		}

        if let savedSound = UserDefaults.standard.object(forKey: "soundOn") as? Bool
        {
            soundOn = savedSound
        
            if soundOn == true
            {
                soundButton.texture = SKTexture(imageNamed: "SoundOn")
            }
            else
            {
                soundButton.texture = SKTexture(imageNamed: "SoundOff")
            }
        }
    }

    override func update(_ currentTime: TimeInterval)
	{
        switch difficultyMultiplier
        {
			case 0:

				easyButton.alpha = 1.0
				mediumButton.alpha = 1.0
				hardButton.alpha = 1.0

            case 1:

                easyButton.alpha = 0.6
                mediumButton.alpha = 1.0
                hardButton.alpha = 1.0

            case 2.25:

                mediumButton.alpha = 0.6
                easyButton.alpha = 1.0
                hardButton.alpha = 1.0

            case 3.5:

                hardButton.alpha = 0.6
                easyButton.alpha = 1.0
                mediumButton.alpha = 1.0

            default:
                break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
        for touch in touches
        {
            let node = self.atPoint(touch.location(in: self))

            switch node.name
            {
            case "sound"? where soundOn == true:

                soundOn = false
                soundButton.texture = SKTexture(imageNamed: "SoundOff")

            case "sound"? where soundOn == false:

                soundOn = true
                soundButton.texture = SKTexture(imageNamed: "SoundOn")

            case "info"?:

                let moveWindow = SKAction.move(to: CGPoint(x: self.frame.width * 0.5, y: 855), duration: 0.8)
                infoWindow.run(moveWindow)
				
				if infoWindow.position.x == self.frame.width * 0.5
				{
					moveWindowBack()
				}

            case "infoWindow"?:

				moveWindowBack()

            case "easy"?:

                difficultyMultiplier = 1
				loadGame()

            case "medium"?:

                difficultyMultiplier = 2.25
				loadGame()

            case "hard"?:

                difficultyMultiplier = 3.5
				loadGame()

            default:
                break
            }
            _ = UserDefaults.standard.set(soundOn, forKey: "soundOn")
        }
    }

	fileprivate func loadGame()
	{
		let white = SKShapeNode(rectOf: (self.scene?.size)!)
		white.fillColor = SKColor.white
		white.strokeColor = SKColor.white
		white.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
		white.zPosition = 10
		white.alpha = 0.0
		self.addChild(white)
		let loading = SKLabelNode(text: "Loading...")
		loading.fontSize = 40
		loading.fontName = "akaDylan Collage"
		loading.fontColor = SKColor.black
		loading.position = CGPoint(x:(self.scene?.frame.width)! * 0.5 , y: (self.scene?.frame.height)! * 0.5)
		loading.zPosition = 11
		loading.alpha = 0.0
		self.addChild(loading)
		loading.run(SKAction.fadeIn(withDuration: 0.9))
		white.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.8),SKAction.wait(forDuration: 0.1)]), completion: { [unowned self] in

			let game: GameScene = GameScene()
			game.size = UIScreen.main.bounds.size
			game.scaleMode = .aspectFill
			self.view?.presentScene(game)
		}) 
	}

	fileprivate func moveWindowBack()
	{
		let moveWindowBack = SKAction.move(to: CGPoint(x: -540, y: 855), duration: 0.8)
		infoWindow.run(moveWindowBack)
	}
}
