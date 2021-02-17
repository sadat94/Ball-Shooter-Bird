//
//  ViewController.swift
//  CourseWork 14170683
//
//  Created by Sadat Safuan on 07/12/2019.
//  Copyright © 2019 Sadat Safuan. All rights reserved.
//


import UIKit
import AVFoundation

// Delegate Image View
protocol subviewDelegate {
    func createBall()
    func shootingAngle(currentLocation: CGPoint)
}


class ViewController: UIViewController, subviewDelegate {
    
    // Main game dynamics
    var dynamicAnimator: UIDynamicAnimator!
    var dynamicItemBehavior: UIDynamicItemBehavior!
    var collisionBehavior: UICollisionBehavior!
    var birdCollisionBehaviour: UICollisionBehavior!
    
    // Array of balls and birds
    var ballViewArray: [UIImageView]    = []
    var birdViewArray: [UIImageView]    = []
    
    
    // Ball angles in terms of coordinates x,y
    var ballAngleX: CGFloat!
    var ballAngleY: CGFloat!
    
    
    
    // Initialise Timer
    var seconds = 20
    var timer = Timer()
    var timerTicker = Timer()
    
    
    // Different game levels
    var currentLevelNo = 1
    var scoreLevelUpgrade: Bool = false
    
    
   // Current game score/points
   var actualScore = 0
    

  // Replay button creation programatically
    let replayImage = UIImage(named: "replay.png")
    let replayButton = UIButton(type: UIButton.ButtonType.custom)
    
    
    
    // Obstacle objects creation
    var obstacleObject: UIImageView!
    let obstacleImageObject = UIImage(named: "square.png")
    var obstacleWidth: CGFloat?
    var obstacleHeight: CGFloat?
    var obstacleCurrentLocation: CGPoint?
    var obstacleObjectSize: CGSize?
    

    
    // UI main screen boundaries for screen fit programming
    let W = UIScreen.main.bounds.width
    let H = UIScreen.main.bounds.height
    
    
    
    // Sounds effect play when ball intersects with birds
       var player: AVAudioPlayer?
       var soundPlayer = AVAudioPlayer()
       let playSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Destroy", ofType: "mp3")!)
    

    
    // Bird array containing real images
    let birdRealImageArray           = [UIImage(named: "bird1.png")!,
                                        UIImage(named: "bird3.png")!,
                                        UIImage(named: "bird4.png")!,
                                        UIImage(named: "bird5.png")!,
                                        UIImage(named: "bird6.png")!,
                                        UIImage(named: "bird9.png")!,
                                        UIImage(named: "bird10.png")!,
                                        UIImage(named: "bird12.png")!,
                                        UIImage(named: "bird13.png")!
                
    ]
    
    // Updates ball angles (x,y) from DragImageView.swift
    func shootingAngle(currentLocation: CGPoint){
        ballAngleX = currentLocation.x
        ballAngleY = currentLocation.y
    }
    
    
    
    // Game background setup
    func backgroundSetup() {
        let backgroundPhoto = UIImageView(frame: UIScreen.main.bounds)
        backgroundPhoto.image = UIImage(named: "AngryBirds.png")
        self.view.insertSubview(backgroundPhoto, at: 0)
        
    }
    
    
    // Initialise timer for each game levels
    func initialiseTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)

    }
    
    // Updates timer
    @objc func updateTimer() {
        seconds -= 1
        Timing.text = "Time: " + " \(seconds)"
        
    }
    
    // Counts timer from 20 to 0
    func tickingTimer() {
        timerTicker = Timer.scheduledTimer(timeInterval: 20, target: self, selector: (#selector(ViewController.resetTimerCount)), userInfo: nil, repeats: true)
        backgroundSetup()
    }
    
    // Reset after timer ends
    @objc func resetTimerCount () {
        Score.text = "" + String(self.actualScore)
        
        self.timerTicker.invalidate()
        self.timer.invalidate()
        
        self.currentLevelNo += 1
        Level.text = "Level: " + String(currentLevelNo)

        collisionBehavior.removeBoundary(withIdentifier: "obstacleCollision" as NSCopying)


        for ballObjectView in self.ballViewArray {
            ballObjectView.removeFromSuperview()
        }
        
        for birdObjectView in self.birdViewArray {
            birdObjectView.removeFromSuperview()
        }
        
        self.Score.isHidden = false
        self.endview.isHidden = false
        self.view.bringSubviewToFront(endview)
    }
    
    
    
    
    
    
    // Create random obstacle squares in different sizes & positions
    func createObstacleSquare() {
        self.obstacleWidth = CGFloat(Int.random(in: Int(self.W*0.3)...Int(self.W*0.6)))
        self.obstacleHeight = CGFloat(Int.random(in: Int(self.H*0.3)...Int(self.H*0.6)))
        self.obstacleCurrentLocation = CGPoint(x: self.obstacleWidth!, y: self.obstacleHeight!)
        self.obstacleObjectSize = CGSize(width: Int.random(in: Int(self.W*0.1)...Int(self.W*0.3)),
                                height: Int.random(in: Int(self.H*0.1)...Int(self.H*0.3)))
        
        obstacleObject.frame = CGRect (origin: self.obstacleCurrentLocation!, size: self.obstacleObjectSize!)
        self.view.addSubview(obstacleObject)
        self.view.bringSubviewToFront(obstacleObject)
        collisionBehavior.addBoundary(withIdentifier: "obstacleCollision" as NSCopying, for: UIBezierPath(rect: obstacleObject.frame))
    }
    
    
    // Replay button inialisation
    @objc func buttonPressed(_ Sender:UIButton!) {
        self.endview.isHidden = true
        
        self.seconds = 20
        self.initialiseTimer()
        self.tickingTimer()
        
        self.generateBirdObjects()
        self.createObstacleSquare()
        self.actualScore = 0
        self.Score.text = "" + String(self.actualScore)
       
    }
    
    
    
    // Generates ball which are released from Aim object
    func createBall() {
        let ballViewImage = UIImageView(image: nil)
        ballViewImage.image = UIImage(named: "ball")
        ballViewImage.frame = CGRect(x: W*0.08, y: H*0.47, width: W*0.10, height: H*0.17)
        
        self.view.addSubview(ballViewImage)
        
        let currentAngleX = ballAngleX - self.Aim.bounds.midX
        let currentAngleY = ballAngleY - H*0.5
        
        ballViewArray.append(ballViewImage)
        dynamicItemBehavior.addItem(ballViewImage)
        dynamicItemBehavior.addLinearVelocity(CGPoint(x: currentAngleX*5, y: currentAngleY*5), for: ballViewImage)
        collisionBehavior.addItem(ballViewImage)
        
    }
    
    
    
    
    // Load the main view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start background music
       
        initialiseAll()
        
        self.Aim.center.x = self.W * 0.10
        self.Aim.center.y = self.H * 0.50
    
        
        Aim.myDelegate = self
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        dynamicItemBehavior = UIDynamicItemBehavior(items: ballViewArray)
        dynamicAnimator.addBehavior(dynamicItemBehavior)
        dynamicAnimator.addBehavior(birdCollisionBehaviour)
        
        collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior = UICollisionBehavior(items: ballViewArray)
    
        
        collisionBehavior.addBoundary(withIdentifier: "LEFTBOUNDARY" as NSCopying, from: CGPoint(x: self.W*0.0, y: self.H*0.0), to: CGPoint(x: self.W*0.0, y: self.H*1.0))
        collisionBehavior.addBoundary(withIdentifier: "TOPBOUNDARY" as NSCopying, from: CGPoint(x: self.W*0.0, y: self.H*0.0), to: CGPoint(x: self.W*1.0, y: self.H*0.0))
        collisionBehavior.addBoundary(withIdentifier: "BOTTOMBOUNDARY" as NSCopying, from: CGPoint(x: self.W*0.0, y: self.H*1.0), to: CGPoint(x: self.W*1.0, y: self.H*1.0))
        dynamicAnimator.addBehavior(collisionBehavior)
        
    }
         
    
    
    // Create various bird images and generate them in random location
    func generateBirdObjects(){
        let number = 5
        let birdSize = Int(self.H)/number-2
        
        for index in 0...1000{
            let when = DispatchTime.now() + (Double(index)/2)
            
            DispatchQueue.main.asyncAfter(deadline: when) {
                while true {
                    let randomHeightPosition = Int(self.H)/number * Int.random(in: 0...number)
                    let birdObjectView = UIImageView(image: nil)
                
                    birdObjectView.image = self.birdRealImageArray.randomElement()
                    birdObjectView.frame = CGRect(x: self.W-CGFloat(birdSize), y:  CGFloat(randomHeightPosition), width: CGFloat(birdSize),
                                     height: CGFloat(birdSize))
                
                    self.view.addSubview(birdObjectView)
                    self.view.bringSubviewToFront(birdObjectView)
                    for anyBirdView in self.birdViewArray {
                        
                        if birdObjectView.frame.intersects(anyBirdView.frame) {
                            birdObjectView.removeFromSuperview()
                            continue
                        }
                    }
                                   
                    self.birdViewArray.append(birdObjectView)
                    break;
                }
            }
        }
    }
    
    
    
    // Load images and game contents whenever the game starts
    func initialiseAll(){
        backgroundSetup()
        
        self.initialiseTimer()
        
        Level.text = "Level: " + String(currentLevelNo)
        Score.text = "" + String(actualScore) //score text added as an imageview
        Timing.text = "Time: " + String(seconds)
        
        Audio.sharedHelper.playAudio()
        
        self.generateBirdObjects()
            
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
            
        Aim.frame = CGRect(x:W*0.02, y: H*0.4, width: W*0.2, height: H*0.2)
        Aim.myDelegate = self
            
        birdCollisionBehaviour = UICollisionBehavior(items:birdViewArray)
        
        self.birdCollisionBehaviour.action = {
            for ballImageView in self.ballViewArray{
                for birdImageView in self.birdViewArray{
                    
                    
                if ballImageView.frame.intersects(birdImageView.frame) {
                        
                let initially = self.view.subviews.count
                        birdImageView.removeFromSuperview()
                        
                let index = self.birdViewArray.firstIndex(of:birdImageView)
                        self.birdViewArray.remove(at: index!)
                        let afterwards = self.view.subviews.count
                    
                            if (initially != afterwards) {
                                self.actualScore = self.actualScore + 1
                                self.Score.text = "" + String(self.actualScore)
                                
                                // play 'Destroy' sound effect when ball hits birds
                                do {
                                    self.soundPlayer = try AVAudioPlayer(contentsOf: self.playSound)
                                    self.soundPlayer.play()
                                } catch {
                                    
                                }
                            }
                        
                    }
                }
            }
                
            
        }
    
        
        
        obstacleObject = UIImageView(image: obstacleImageObject)
        
        
            self.endview.isHidden = true
            self.view.addSubview(endview)
            self.view.bringSubviewToFront(endview)
        
            
            // Replay button implementation
            replayButton.setImage(replayImage, for: .normal)
            replayButton.frame = CGRect(x:W*0.02, y: H*0.7, width: W*0.3, height: H*0.2)
            replayButton.center = CGPoint(x:W*0.5, y: H*0.5)
            replayButton.addTarget(self, action: #selector(ViewController.buttonPressed( _:)), for: .touchUpInside)
            
            // Show replay button and reset timing count
            self.endview.addSubview(self.replayButton)
            self.tickingTimer()

        
    }
    
    
    
    
    
    // Interface Builder outlets
       @IBOutlet var Score: UILabel!
       @IBOutlet var Timing: UILabel!
       @IBOutlet var Level: UILabel!
       
       @IBOutlet var endview: UIView!
       
       @IBOutlet var Aim: DragImageView!
       @IBOutlet var scoreImageView: UIImageView!
       @IBOutlet var timerImageView: UIImageView!
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

