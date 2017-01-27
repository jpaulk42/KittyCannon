//
//  GameViewController.swift
//  KittyCannon.v002
//
//  Created by James Paulk on 2/21/16.
//  Copyright (c) 2016 James Paulk. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController
{

    override func viewDidLoad()
	{
        super.viewDidLoad()

        if let scene = MainMenu(fileNamed:"MainMenu")
		{
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill

            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate : Bool
	{
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
	{
        
        return .portrait
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden : Bool
	{
        return true
    }
}
