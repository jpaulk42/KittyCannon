//
//  GameScene.swift
//  KittyCannon.v002
//
//  Created by James Paulk on 2/21/16.
//  Copyright (c) 2016 James Paulk. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate
{
// MARK: - Properies
    let background1 = SKSpriteNode(imageNamed: "Background")
    let background2 = SKSpriteNode(imageNamed: "Background")

    lazy var mainLayer = SKNode()

    lazy var cannon = SKSpriteNode()
    lazy var kitty = SKSpriteNode()
    lazy var rat = SKSpriteNode()
    lazy var leftEdge = SKSpriteNode()
    lazy var rightEdge = SKSpriteNode()
    lazy var mainMenuButton = SKSpriteNode()
    let pauseButton = SKSpriteNode(imageNamed: "Pause")
    let resumeButton = SKSpriteNode(imageNamed: "Resume")

    let kittyTexture = SKTexture(imageNamed: "Kitty")

    lazy var reloadLabel = SKLabelNode()
    lazy var scoreLabel = SKLabelNode()
    lazy var healthLabel = SKLabelNode()
    lazy var ammoLabel = SKLabelNode()
	lazy var ammoPlusOneLabel = SKLabelNode()
	lazy var maxAmmoPlusOneLabel = SKLabelNode()
	lazy var scorePlusNumber = SKLabelNode()
	lazy var healthPlusOneLabel = SKLabelNode()

    lazy var reloadSelector = SKAction()
    lazy var reloadAction = SKAction()
	lazy var spawnRatAction = SKAction()

	var music = AVAudioPlayer()
    
    let ratKilledSound = SKAction.playSoundFileNamed("ratKilled.mp3", waitForCompletion: false)
    let shootKittySound = SKAction.playSoundFileNamed("meow1.mp3", waitForCompletion: false)
    let cannonHitSound = SKAction.playSoundFileNamed("alert.mp3", waitForCompletion: false)

	let green = SKColor.green
	let yellow = SKColor.yellow
	let orange = SKColor.orange
	let red = SKColor.red
	let purple = SKColor.purple
    
    let menu = Menu()
    
    var motionManager = CMMotionManager()
    
    var canShoot = true
    var didShoot = false
    var gameOver = false
    var gamePaused = false
    var cannonHit = false
    var reloading = false
    var ratHit = false
    var boss1Hit = false
    var bossHitCannon = false
	var stayPaused = false

	var scaleIt = true
	var theScale: CGFloat = 0.8
    
    var health = 3
    var ammoCount = 5
	var maxAmmo = 5
    var playerSpeed = 20
    var ratCounter = 0
    var playerScore = 0
    var playerHighScore = 0
    var savedHighScore = 0
    var enemySpawnCounter = 0
    var ratSpeedIncrement:CGFloat = 1.0
    var boss1Health = 3

	var randomHealthAdjuster: UInt32 = 0

    enum CollisionType: UInt32
    {
        case cannon = 1
        case kitty = 2
        case rat = 4
        case edge = 8
        case boss = 16
        case bottom = 32
    }
 //MARK: - didMoveToView:
    override func didMove(to view: SKView)
    {
		let white = SKShapeNode(rectOf: (self.scene?.size)!)
		white.fillColor = SKColor.white
		white.strokeColor = SKColor.white
		white.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
		white.zPosition = 10
		white.alpha = 1.0
		white.name = "playButton"
		self.addChild(white)
		let loading = SKLabelNode(text: "Loading...")
		loading.fontSize = 15
		loading.fontName = "akaDylan Collage"
		loading.fontColor = SKColor.black
		loading.position = CGPoint(x: ((self.scene?.frame.height)! * 0.5) - 150 , y: (self.scene?.frame.height)! * 0.5)
		loading.zPosition = 11
		self.addChild(loading)
		let url: URL = URL(fileURLWithPath: Bundle.main.path(forResource: "bgmusickittycannon", ofType: "mp3")!)
		do
		{
			music = try AVAudioPlayer(contentsOf: url)
		}
		catch
		{
			print("could not load music")
		}

		let theSelector: Selector = #selector(GameScene.pauseBG)
		NotificationCenter.default.addObserver(self, selector: theSelector, name: NSNotification.Name(rawValue: "pauseTheGame"), object: nil)

		if UIScreen.main.bounds.height < 500
		{
			self.scaleIt = true
		}
		else if UIScreen.main.bounds.height > 700
		{
			self.scaleIt = true
			self.theScale = 1.2
		}
		else
		{
			self.scaleIt = false
			self.theScale = 1.0
		}

		if difficultyMultiplier == 2.25
		{
			self.background1.color = UIColor.orange
			self.background2.color = UIColor.orange
			self.background1.colorBlendFactor = 0.8
			self.background2.colorBlendFactor = 0.8
			if let savedScore = UserDefaults.standard.object(forKey: "highMedium")
			{
				self.playerHighScore = Int(savedScore as! NSNumber)
			}
		}
		else if difficultyMultiplier > 3
		{
			self.background1.color = UIColor.red
			self.background2.color = UIColor.red
			self.background1.colorBlendFactor = 0.9
			self.background2.colorBlendFactor = 0.9
			if let savedScore = UserDefaults.standard.object(forKey: "highHard")
			{
				self.playerHighScore = Int(savedScore as! NSNumber)
			}
		}
		else if difficultyMultiplier == 1
		{
			self.background1.color = UIColor.clear
			self.background2.color = UIColor.clear
			if let savedScore = UserDefaults.standard.object(forKey: "highEasy")
			{
				self.playerHighScore = Int(savedScore as! NSNumber)
			}
		}
		self.background1.anchorPoint = CGPoint.zero
		self.background1.size.width = UIScreen.main.bounds.width
		self.background1.position = CGPoint(x: 0, y: 0)
		self.background1.zPosition = -15
		self.addChild(self.background1)

		self.background2.anchorPoint = CGPoint.zero
		self.background2.position = CGPoint(x: 0, y: self.background1.size.height)
		self.background2.size.width = UIScreen.main.bounds.width
		self.background2.zPosition = -15
		self.addChild(self.background2)

		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)

		self.createEdges()
		
		self.addChild(self.mainLayer)
		
		self.spawnCannon()

		self.menu.setScore(self.playerScore)
		self.menu.setHighScore(self.playerHighScore)
		self.menu.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height - 150)
		self.menu.zPosition = 4
		self.mainLayer.addChild(self.menu)
		self.menu.isHidden = true

		self.mainMenuButton = SKSpriteNode(imageNamed: "MainMenu")
		self.mainMenuButton.xScale = 0.5
		self.mainMenuButton.yScale = 0.5
		self.mainMenuButton.position = CGPoint(x: self.frame.width - 25, y: self.frame.height - 25)
		self.mainMenuButton.name = "mainmenu"
		self.mainMenuButton.isHidden = true
		self.mainMenuButton.zPosition = 3
		self.mainLayer.addChild(self.mainMenuButton)

		self.scoreLabel.fontName = "akaDylan Collage"
		self.scoreLabel.text = "0"
		self.scoreLabel.fontSize = 30
		self.scoreLabel.fontColor = UIColor(red: 0.170, green: 0.790, blue: 0.289, alpha: 1.00)
		self.scoreLabel.position = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height - 35)
		self.scoreLabel.zPosition = 3
		self.scoreLabel.isHidden = true
		self.mainLayer.addChild(self.scoreLabel)

		self.pauseButton.position = CGPoint(x: 25.0, y: self.frame.height - 25)
		self.pauseButton.xScale = 0.5
		self.pauseButton.yScale = 0.5
		self.pauseButton.isHidden = true
		self.pauseButton.name = "pause"
		self.pauseButton.zPosition = 3
		self.mainLayer.addChild(self.pauseButton)

		self.resumeButton.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
		self.resumeButton.isHidden = true
		self.resumeButton.name = "resume"
		self.resumeButton.zPosition = 3
		self.mainLayer.addChild(self.resumeButton)
		
		self.healthLabel.text = "Life: \(self.health)"
		self.healthLabel.fontName = "akaDylan Collage"
		self.healthLabel.fontSize = 20
		self.healthLabel.name = "healthLabel"
		self.healthLabel.fontColor = UIColor(red: 0.170, green: 0.790, blue: 0.289, alpha: 1.00)
		self.healthLabel.position = CGPoint(x: self.frame.width - 50, y: 3)
		self.healthLabel.zPosition = 3
		self.healthLabel.isHidden = true
		self.mainLayer.addChild(self.healthLabel)

		self.healthPlusOneLabel.text = "+1 HP"
		self.healthPlusOneLabel.fontName = "akaDylan Collage"
		self.healthPlusOneLabel.fontSize = 20
		self.healthPlusOneLabel.fontColor = SKColor.cyan
		self.healthPlusOneLabel.position = CGPoint(x: self.healthLabel.position.x - 10, y: self.healthLabel.position.y + 35)
		self.healthPlusOneLabel.zPosition = 3
		self.healthPlusOneLabel.alpha = 0.0
		self.mainLayer.addChild(self.healthPlusOneLabel)
		
		self.ammoLabel.text = "Kitties: \(self.ammoCount)/\(maxAmmo)"
		self.ammoLabel.fontName = "akaDylan Collage"
		self.ammoLabel.fontSize = 19
		self.ammoLabel.fontColor = UIColor(red: 0.170, green: 0.790, blue: 0.289, alpha: 1.00)
		self.ammoLabel.position = CGPoint(x: 90, y: 3)
		self.ammoLabel.zPosition = 3
		self.ammoLabel.isHidden = true
		self.mainLayer.addChild(self.ammoLabel)

		self.maxAmmoPlusOneLabel.text = "+1 Max Ammo"
		self.maxAmmoPlusOneLabel.fontName = "akaDylan Collage"
		self.maxAmmoPlusOneLabel.fontSize = 18
		self.maxAmmoPlusOneLabel.fontColor = SKColor.cyan
		self.maxAmmoPlusOneLabel.position = CGPoint(x: self.ammoLabel.position.x , y: self.ammoLabel.position.y + 65)
		self.maxAmmoPlusOneLabel.zPosition = 3
		self.maxAmmoPlusOneLabel.alpha = 0.0
		self.mainLayer.addChild(self.maxAmmoPlusOneLabel)

		self.ammoPlusOneLabel.text = "+1 Ammo"
		self.ammoPlusOneLabel.fontName = "akaDylan Collage"
		self.ammoPlusOneLabel.fontSize = 18
		self.ammoPlusOneLabel.fontColor = SKColor.cyan
		self.ammoPlusOneLabel.position = CGPoint(x: self.ammoLabel.position.x , y: self.ammoLabel.position.y + 35)
		self.ammoPlusOneLabel.zPosition = 3
		self.ammoPlusOneLabel.alpha = 0.0
		self.mainLayer.addChild(self.ammoPlusOneLabel)

		self.scorePlusNumber.text = "+1"
		self.scorePlusNumber.fontName = "akaDylan Collage"
		self.scorePlusNumber.fontSize = 20
		self.scorePlusNumber.fontColor = SKColor.cyan
		self.scorePlusNumber.position = CGPoint(x: self.scoreLabel.position.x , y: self.scoreLabel.position.y - 23)
		self.scorePlusNumber.zPosition = 3
		self.scorePlusNumber.alpha = 0.0
		self.mainLayer.addChild(self.scorePlusNumber)

		let wait = SKAction.wait(forDuration: 3)
		let performSelector = SKAction.perform(#selector(GameScene.spawnEnemy), onTarget: self.scene!)
		let sequence = SKAction.sequence([wait,performSelector])
		self.run(SKAction.repeatForever(sequence), withKey: "spawnEnemyForever")
		
		//add reload label//
		self.reloadLabel.fontName = "akaDylan Collage"
		self.reloadLabel.fontSize = 30
		self.reloadLabel.fontColor = UIColor.red
		self.reloadLabel.text = "Reloading..."
		self.reloadLabel.position = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
		self.reloadLabel.zPosition = 3
		self.reloadLabel.isHidden = true
		self.mainLayer.addChild(self.reloadLabel)
		
		self.reloadSelector = SKAction.perform(#selector(GameScene.resetAmmo), onTarget: self.scene!)
		self.reloadAction = SKAction.sequence([SKAction.wait(forDuration: 1), self.reloadSelector])
		self.mainLayer.run(SKAction.repeatForever(self.reloadAction))
		loading.removeFromParent()
		self.gameIsOver()

		if difficultyMultiplier == 1
		{
			randomHealthAdjuster = 2
		}
		else if difficultyMultiplier == 2.25
		{
			randomHealthAdjuster = 3
		}
		else if difficultyMultiplier == 3.5
		{
			randomHealthAdjuster = 4
		}

		white.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.8),SKAction.wait(forDuration: 0.0)]), completion: { [unowned white] in

			white.removeFromParent()
		}) 
		if soundOn
		{
			music.numberOfLoops = -1
			music.volume = 0.72
			music.play()
		}
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
        for touch in touches
        {
            let node = mainLayer.atPoint(touch.location(in: mainLayer))

            switch node.name
            {
				case nil:

					shoot()

				case "mainmenu"?:
					music.stop()
					if  let scene = MainMenu(fileNamed: "MainMenu")
					{
						scene.size = CGSize(width: 1080, height: 1920)
						scene.scaleMode = .aspectFill
						self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1.2))
					}

				case "resume"? where gamePaused == true:

					resume()
					if reloading == true
					{
						reloadLabel.isHidden = false
					}

				case "pause"? where gamePaused == false:

					pause()
					if reloading == true
					{
						reloadLabel.isHidden = true
					}

				case "playButton"? where gameOver == true:

					newGame()

				default:

					break
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstContactBody = SKPhysicsBody()
        var secondContactBody = SKPhysicsBody()
            
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask
        {
            firstContactBody = contact.bodyA
            secondContactBody = contact.bodyB
        }
        else
        {
            firstContactBody = contact.bodyB
            secondContactBody = contact.bodyA
        }
        
        ///////////////////////// RAT TO KITTY CONTACT //////////////////////////////////
            
        if firstContactBody.categoryBitMask == CollisionType.boss.rawValue && secondContactBody.categoryBitMask == CollisionType.kitty.rawValue
        {
            boss1Hit = true
            explosion(contact.contactPoint, fileNamed: "RatExplosion.sks")
            if soundOn == true
            {
                run(ratKilledSound)
            }
            secondContactBody.node?.removeFromParent()
        }
            
        else if firstContactBody.categoryBitMask == CollisionType.rat.rawValue && secondContactBody.categoryBitMask == CollisionType.kitty.rawValue
        {
            ratHit = true
            explosion(contact.contactPoint, fileNamed: "RatExplosion.sks")
            if soundOn == true
            {
                run(ratKilledSound)
            }
            firstContactBody.node?.removeFromParent()
            secondContactBody.node?.removeFromParent()
        }
        
        //////////////////////////////////// RAT TO CANNON CONTACT //////////////////////////////////////////
        if firstContactBody.categoryBitMask == CollisionType.boss.rawValue && secondContactBody.categoryBitMask == CollisionType.cannon.rawValue
        {
            explosion(contact.contactPoint, fileNamed: "RatExplosion.sks")
            if soundOn == true
            {
                run(cannonHitSound)
            }
            firstContactBody.node?.removeFromParent()
            bossHitCannon = true
        }
        else if firstContactBody.categoryBitMask == CollisionType.rat.rawValue && secondContactBody.categoryBitMask == CollisionType.cannon.rawValue
        {
            firstContactBody.node?.removeFromParent()
            if soundOn == true
            {
                run(cannonHitSound)
            }
            explosion(contact.contactPoint, fileNamed: "RatExplosion.sks")
            cannonHit = true
        }

        /////////////////////////////RAT TO BOTTOM CONTACT ////////////////////////////////////////////
        if firstContactBody.categoryBitMask == CollisionType.bottom.rawValue && secondContactBody.categoryBitMask == CollisionType.rat.rawValue
        {
            secondContactBody.node?.removeFromParent()
			secondContactBody.node?.removeAllActions()
        }
        else if firstContactBody.categoryBitMask == CollisionType.bottom.rawValue && secondContactBody.categoryBitMask == CollisionType.boss.rawValue
        {
            if boss1Health < 3
            {
                boss1Health = 3
            }
            secondContactBody.node?.removeFromParent()
        }
    }
   
    override func update(_ currentTime: TimeInterval)
	{
		if stayPaused == true
		{
			pause()
		}
        if gameOver == false
        {
            backgroundScrollUpdate()

            if let accelData = self.motionManager.accelerometerData
            {
                if let accelX: CGFloat = CGFloat(accelData.acceleration.x) * 930
                {
                    var movement = CGVector()
            
                    if accelData.acceleration.x > 0.1
                    {
                        movement = CGVector(dx: accelX, dy: 0)
            
                    }
                    else if accelData.acceleration.x < 0.1
                    {
                        movement = CGVector(dx: accelX, dy: 0)
                    }
            
                    self.cannon.physicsBody?.velocity = movement
                }
            }
        }
    }
    
    override func didSimulatePhysics()
	{
		mainLayer.enumerateChildNodes(withName: "kitty") { [unowned self] (node, pointer) -> Void in
            
            if !self.frame.contains(node.position)
            {
                node.removeFromParent()
                node.removeAllChildren()
				node.removeAllActions()
            }
        }
        
        if cannonHit == true
        {
            health -= 1
            cannonHit = false
            healthLabel.text = "Life: \(health)"
                
            if health == 0
            {
				reloadLabel.isHidden = true 
				explosion(cannon.position, fileNamed: "RatExplosion.sks")
                gameIsOver()
            }
        }

        if bossHitCannon == true
        {
            health = health - 2
            bossHitCannon = false
            healthLabel.text = "Life: \(health)"
            boss1Health = 3

            if health < 1
            {
                gameIsOver()
            }
        }

        if boss1Hit == true
        {
			if ammoCount < maxAmmo
			{
				ammoPlusOneLabel.removeAllActions()
				ammoPlusOneLabel.alpha = 1.0
				ammoPlusOneLabel.run(SKAction.fadeOut(withDuration: 1.0))
				ammoCount += 1
				ammoLabel.text = "Kitties: \(ammoCount)/\(maxAmmo))"
			}
            boss1Hit = false
            boss1Health -= 1
            if boss1Health == 0
            {
				if health < 14
				{
					health += 1
					healthLabel.text = "Life: \(health)"
				}
				if maxAmmo < 14
				{
					maxAmmo += 1
					maxAmmoPlusOneLabel.alpha = 1.0
					maxAmmoPlusOneLabel.run(SKAction.fadeOut(withDuration: 2.0))
				}
				scorePlusNumber.removeAllActions()
				scorePlusNumber.text = "+3"
				scorePlusNumber.alpha = 1.0
				scorePlusNumber.run(SKAction.fadeOut(withDuration: 2.0))
				healthPlusOneLabel.alpha = 1.0
				healthPlusOneLabel.run(SKAction.fadeOut(withDuration: 2.0))
                ammoLabel.text = "Kitties: \(ammoCount)/\(maxAmmo)"
                boss1Health = 3

                self.enumerateChildNodes(withName: "boss1", using: { [unowned self, unowned rat](node, pointer) -> Void in
                    node.removeFromParent()
                    node.removeAllChildren()
                })
            
                playerScore = playerScore + 3
                scoreLabel.text = String(playerScore)
				healthPlusOneLabel.alpha = 1.0
				ammoPlusOneLabel.alpha = 1.0
				healthPlusOneLabel.run(SKAction.fadeOut(withDuration: 1.5))
				ammoPlusOneLabel.run(SKAction.fadeOut(withDuration: 1.5))
            }
        }
            
        if ratHit == true
        {
            ratHit = false
            playerScore += 1
			scorePlusNumber.removeAllActions()
			scorePlusNumber.text = "+1"
			scorePlusNumber.alpha = 1.0
			scorePlusNumber.run(SKAction.fadeOut(withDuration: 2.0))
            scoreLabel.text = String(playerScore)
        }

        if gameOver == false
        {
            healthLabel.isHidden = false
            pauseButton.isHidden = false
            scoreLabel.isHidden = false
            ammoLabel.isHidden = false
        }
    }
////////////////////////////////////// MARK: GAMESTATE /////////////////////////////////////////////
    
    func gameIsOver()
    {
        menu.setScore(playerScore)
        
        if self.playerScore > self.playerHighScore
        {
			self.playerHighScore = self.playerScore

			if difficultyMultiplier == 1
			{
				self.savedHighScore = Int(UserDefaults.standard.set(self.playerHighScore, forKey: "highEasy"))
			}
			else if difficultyMultiplier == 2.25
			{
				self.savedHighScore = Int(UserDefaults.standard.set(self.playerHighScore, forKey: "highMedium"))
			}
			else if difficultyMultiplier == 3.5
			{
				self.savedHighScore = Int(UserDefaults.standard.set(self.playerHighScore, forKey: "highHard"))
			}
            self.menu.setHighScore(self.playerHighScore)
        }
        self.enumerateChildNodes(withName: "rat", using: { [unowned self, unowned rat](node, pointer) -> Void in
            node.removeFromParent()
            node.removeAllChildren()
        })
        
        mainLayer.enumerateChildNodes(withName: "kitty") { [unowned kitty, unowned mainLayer](node, pointer) -> Void in
            node.removeFromParent()
            node.removeAllChildren()
        }
        canShoot = false
        gameOver = true
        pauseButton.isHidden = true
		reloadLabel.isHidden = true
        menu.isHidden = false
		mainMenuButton.isHidden = false
        healthLabel.isHidden = true
        scoreLabel.isHidden = true
        ammoLabel.isHidden = true
        self.speed = 0.0
        mainLayer.speed = 0.0
		scorePlusNumber.alpha = 0.0
		ammoPlusOneLabel.alpha = 0.0
		maxAmmoPlusOneLabel.alpha = 0.0
		healthPlusOneLabel.alpha = 0.0
        cannon.isHidden = true
		self.motionManager.stopAccelerometerUpdates()
    }
    
    func newGame()
    {
		canShoot = true
		didShoot = false
		gameOver = false
		gamePaused = false
		cannonHit = false
		reloading = false
		ratHit = false
		boss1Hit = false
		enemySpawnCounter = 0
		boss1Health = 3
		ammoCount = 5
		maxAmmo = 5
		ratSpeedIncrement = 1.0
		ammoLabel.text = "Kitties: \(ammoCount)/\(maxAmmo)"
		health = 3
		self.speed = 1.0
		mainLayer.speed = 1.0
		spawnRatAction.speed = 1
		menu.isHidden = true
		playerScore = 0
		scoreLabel.text = "0"
		healthLabel.text = "Life: \(health)"
		cannon.isHidden = false
		mainMenuButton.isHidden = true
		reloadLabel.isHidden = true
		self.motionManager.startAccelerometerUpdates()
    }

	func pauseBG()
	{
		if gamePaused == false && gameOver == false
		{
			stayPaused = true
		}
		else if gamePaused == true
		{
			resume()
			stayPaused = true
		}
	}

    func pause()
    {
		if gamePaused == false
		{
			self.stayPaused = true
			self.canShoot = false
			self.gamePaused = true
			self.pauseButton.isHidden = true
			self.resumeButton.isHidden = false
			self.mainMenuButton.isHidden = false
			//self.paused = true
			self.scene?.isPaused = true
			if soundOn
			{
				music.stop()
			}
			self.scene?.view?.scene?.speed = 0.0
		}
    }

	func resume()
	{
		if gamePaused == true
		{
			self.stayPaused = false
			self.canShoot = true
			self.gamePaused = false
			self.pauseButton.isHidden = false
			self.resumeButton.isHidden = true
			self.mainMenuButton.isHidden = true
			self.scene?.isPaused = false
			if soundOn
			{
				music.play()
			}
			self.scene?.view?.scene?.speed = 1.0
		}
	}
    
    func resetAmmo()
    {
        if ammoCount < maxAmmo
        {
            ammoCount += 1
            ammoLabel.text = "Kitties: \(ammoCount)/\(maxAmmo)"
            canShoot = true
            reloadLabel.isHidden = true
            reloading = false
        }
    }
    
    func shoot()
    {
        if canShoot && ammoCount > 0
        {
			ammoCount -= 1
			spawnKittyProjectile()
			if soundOn == true
			{
				run(shootKittySound)
			}
			ammoLabel.text = "Kitties: \(ammoCount)/\(maxAmmo)"
        }
		else if ammoCount == 0
        {
			canShoot = false
			reloadLabel.isHidden = false
			reloading = true
        }
    }

////////////////////////////////// MARK: SPAWNING SPRITES //////////////////////////////////////////////////////////
    
    func spawnKittyProjectile()
    {
        kitty = SKSpriteNode(texture: kittyTexture)
        kitty.name = "kitty"
        kitty.position = CGPoint(x: cannon.position.x, y: cannon.position.y + 40)
        kitty.zPosition = 1
        kitty.physicsBody = SKPhysicsBody(circleOfRadius: kitty.size.height * 0.5)
        kitty.physicsBody?.isDynamic = true
        kitty.physicsBody?.allowsRotation = false
        kitty.physicsBody?.restitution = 1
        kitty.physicsBody?.linearDamping = 0.0
        kitty.physicsBody?.friction = 0.0
        kitty.physicsBody?.mass = 0.5
        kitty.physicsBody?.categoryBitMask = CollisionType.kitty.rawValue
        kitty.physicsBody?.collisionBitMask = CollisionType.rat.rawValue | CollisionType.boss.rawValue
        kitty.physicsBody?.contactTestBitMask = CollisionType.rat.rawValue | CollisionType.boss.rawValue
        kitty.physicsBody?.velocity = CGVector(dx: 0, dy: 320)
		if scaleIt
		{
			kitty.setScale(theScale)
		}
        mainLayer.addChild(kitty)
    }
    
    func spawnCannon()
    {
        let cannonTexture = SKTexture(imageNamed: "Cannon")
        cannon = SKSpriteNode(texture: cannonTexture)
        cannon.name = "cannon"
        cannon.position = CGPoint(x: self.size.width * 0.5, y: cannon.size.height * 0.5 + 10)
        cannon.zPosition = 2
        cannon.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: cannon.size.width - 10, height: cannon.size.height))
        cannon.physicsBody?.isDynamic = true
        cannon.physicsBody?.mass = 40
        cannon.physicsBody?.linearDamping = 0.0
        cannon.physicsBody?.friction = 0.0
        cannon.physicsBody?.restitution = 0.0
        cannon.physicsBody?.allowsRotation = false
        cannon.physicsBody?.categoryBitMask = CollisionType.cannon.rawValue
        cannon.physicsBody?.collisionBitMask = CollisionType.edge.rawValue
		if scaleIt && theScale < 1
		{
			cannon.setScale(theScale)
			cannon.position.y -= 8
		}
		else if scaleIt && theScale > 1
		{
			cannon.setScale(theScale)
			cannon.position.y += 8
		}
        mainLayer.addChild(cannon)
    }
    
    func spawnEnemy()
    {
        enemySpawnCounter += 1
        
        let uniform: UInt32 = UInt32(self.size.width) - 60
        let randomX: CGFloat = CGFloat(arc4random_uniform(uniform))
        let ratTexture = SKTexture(imageNamed: "Rat1")
        let ratTexture2 = SKTexture(imageNamed: "Rat2")
        
        rat = SKSpriteNode(texture: ratTexture)
        rat.position = CGPoint( x: 30 + randomX , y: self.size.height + rat.frame.height)
        rat.zPosition = 2
        rat.name = "rat"
        rat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rat.texture!.size().width - 40.0, height: rat.texture!.size().height - 10.0))
        rat.physicsBody?.isDynamic = true
        rat.physicsBody?.allowsRotation = false
        rat.physicsBody?.restitution = 0.0
        rat.physicsBody?.linearDamping = 0.0
        rat.physicsBody?.friction = 0.0
        rat.physicsBody?.mass = 1.0
        rat.physicsBody?.categoryBitMask = CollisionType.rat.rawValue
        rat.physicsBody?.collisionBitMask = CollisionType.kitty.rawValue | CollisionType.cannon.rawValue | CollisionType.edge.rawValue | CollisionType.bottom.rawValue
        rat.physicsBody?.contactTestBitMask = CollisionType.kitty.rawValue | CollisionType.cannon.rawValue | CollisionType.edge.rawValue | CollisionType.bottom.rawValue
        
        let animateRat = SKAction.animate(with: [ratTexture, ratTexture2],
            timePerFrame: 0.1)
        let animateForever = SKAction.repeatForever(animateRat)
        rat.run(animateForever)
        
        let randomVelocity:CGVector = CGVector(dx: 0, dy: -((ratSpeedIncrement * 110.0)))
		if ratSpeedIncrement < CGFloat(9.0 * difficultyMultiplier)
		{
			ratSpeedIncrement = ratSpeedIncrement + CGFloat(0.011 * difficultyMultiplier)
		}
        rat.physicsBody?.velocity = randomVelocity
		if scaleIt
		{
			rat.setScale(theScale)
		}
        if enemySpawnCounter == 16
        {
			let randomHealth: Int = Int(arc4random_uniform(randomHealthAdjuster))
			boss1Health = 2 + randomHealth
            enemySpawnCounter = 0
			rat.colorBlendFactor = 0.9
			let animateBoss = SKAction.animate(with: [SKTexture(imageNamed: "BossRat1"), SKTexture(imageNamed: "BossRat2")], timePerFrame: 0.1)
			let animateBossForever = SKAction.repeatForever(animateBoss)
			rat.run(animateBossForever)
			if theScale > 1
			{
				rat.setScale(1.7)
			}
			else if theScale == 1
			{
				rat.setScale(1.5)
			}
			else if theScale < 1
			{
				rat.setScale(1.3)
			}
			if boss1Health == 2
			{
				rat.color = green
			}
			else if boss1Health == 3
			{
				rat.color = yellow
			}
			else if boss1Health == 4
			{
				rat.color = orange
			}
			else if boss1Health == 5
			{
				rat.color = red
			}
			else if boss1Health == 6
			{
				rat.color = purple
			}
            rat.name = "boss1"
            rat.physicsBody?.categoryBitMask = CollisionType.boss.rawValue
            rat.physicsBody?.mass = 100
            rat.run(SKAction.moveBy(x: 0, y: -self.frame.height, duration: 8))
        }
        
        self.addChild(rat)

        spawnRatAction = self.action(forKey: "spawnEnemyForever")!
        
        if spawnRatAction.speed < CGFloat(13.0 * difficultyMultiplier)
        {
            spawnRatAction.speed += CGFloat(0.036 * difficultyMultiplier)
        }
    }
    
    func createEdges()
    {
        leftEdge = SKSpriteNode(color: UIColor.black, size: CGSize(width: 1, height: self.frame.height))
        leftEdge.anchorPoint = CGPoint.zero
        leftEdge.position = CGPoint(x: 0, y: 0)
        leftEdge.zPosition = 2
        leftEdge.physicsBody = SKPhysicsBody(rectangleOf: leftEdge.size)
        leftEdge.physicsBody?.isDynamic = false
        leftEdge.alpha = 0
        leftEdge.physicsBody?.categoryBitMask = CollisionType.edge.rawValue
        mainLayer.addChild(leftEdge)
        
        rightEdge = SKSpriteNode(color: UIColor.black, size: CGSize(width: 1, height: self.frame.height))
        rightEdge.anchorPoint = CGPoint.zero
        rightEdge.position = CGPoint(x: self.frame.width , y: 0)
        rightEdge.zPosition = 2
        rightEdge.alpha = 0
        rightEdge.physicsBody = SKPhysicsBody(rectangleOf: leftEdge.size)
        rightEdge.physicsBody?.isDynamic = false
        rightEdge.physicsBody?.categoryBitMask = CollisionType.edge.rawValue
        rightEdge.physicsBody?.collisionBitMask = CollisionType.cannon.rawValue
        mainLayer.addChild(rightEdge)

		let bottom = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.frame.width, height: 1))
		bottom.anchorPoint = CGPoint.zero
		bottom.position = CGPoint(x: 0, y: -40)
		bottom.zPosition = 2
		bottom.alpha = 1
		bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width * 2, height: 1))
		bottom.physicsBody?.isDynamic = false
		bottom.physicsBody?.categoryBitMask = CollisionType.bottom.rawValue
		bottom.physicsBody?.collisionBitMask = CollisionType.rat.rawValue
		mainLayer.addChild(bottom)
    }

    func backgroundScrollUpdate()
	{
        self.background1.position = CGPoint(x: self.background1.position.x, y: self.background1.position.y - 2)
        self.background2.position = CGPoint(x: self.background1.position.x, y: self.background2.position.y - 2)

        if self.background1.position.y == -self.background1.size.height
        {
            self.background1.position = CGPoint(x: 0, y: self.background2.position.y + self.background2.size.height)
        }
        if self.background2.position.y == -self.background2.size.height
        {
            self.background2.position = CGPoint(x: 0, y: self.background1.position.y + self.background1.size.height)
        }
    }
    
    func explosion(_ pos: CGPoint, fileNamed: String)
    {
		let explosionEmitter: SKEmitterNode! = SKEmitterNode(fileNamed: fileNamed)
		explosionEmitter.particlePosition = pos
		explosionEmitter.zPosition = 3
		if pos == cannon.position
		{
			explosionEmitter.setScale(2.0)
		}
		let moveExplosion = SKAction.moveBy(x: 0, y: -300, duration: 3)
		explosionEmitter.run(moveExplosion)
		self.addChild(explosionEmitter)
		
		self.run(SKAction.wait(forDuration: 1), completion: { [weak explosionEmitter] in
			explosionEmitter!.removeFromParent()
		})
    }
}
