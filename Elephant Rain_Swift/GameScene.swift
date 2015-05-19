//
//  GameScene.swift
//  Elephant Rain_Swift
//
//  Created by Etienne Wojahn on 29/08/14.
//  Copyright (c) 2014 Etienne Wojahn. All rights reserved.
//
import SpriteKit

class Human : SKSpriteNode {}
class RainDrop : SKSpriteNode {}
class Ground : SKSpriteNode {}
class Umbrella : SKSpriteNode {}
class Cloud : SKSpriteNode {}

struct ContactCategory {
    static let drop : UInt32 = 0x1 << 0;
    static let human : UInt32 = 0x1 << 1;
    static let ground : UInt32 = 0x1 << 2;
    static let umbrella : UInt32 = 0x1 << 3;
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIAlertViewDelegate {
    
    let multiplier_peopleSpeed : Double = 3;
    let multiplier_raindropSpeed : Double = 0.5;
    
    var lastUpdateTimeInterval : NSTimeInterval = 0;
    var lastTimerTimeInterval : NSTimeInterval = 0;
    var lastHumanWalkTimeInterval : NSTimeInterval = 0;
    var lastRainSpawnTimeInterval : NSTimeInterval = 0;
    
    var drops : NSMutableArray = NSMutableArray();
    var humans : NSMutableArray = NSMutableArray();
    
    var umbrella : Umbrella?;
    var timeLabel = SKLabelNode(text: "00:00");
    
    var level = 1;
    var seconds = 0;
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, -2);
        
        startGame();
    }
    
    func startGame () {
        
        self.removeAllChildren();
        
        self.seconds = 0;
        self.level = 1;
        
        self.scene!.paused = false;
        
        self.timeLabel = SKLabelNode(text: "00:00");
        self.timeLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 150);
        self.timeLabel.fontSize = 50;
        self.timeLabel.fontColor = UIColor.whiteColor()
        self.timeLabel.fontName = "HelveticaNeue-Bold";
        self.addChild(self.timeLabel);
        
        CreateManager.createBackground(self);
        CreateManager.createGround(self);
        umbrella = CreateManager.createUmbrella(self);
        
        CreateManager.createClouds(self);
        
        self.createAllPeople();
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            self.umbrella!.runAction(SKAction.moveToX(touch.locationInNode(self).x, duration: 0));
        }
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch : AnyObject = touches.first!
        
        let inScene = touch.locationInNode(self);
        let prevPosition = touch.previousLocationInNode(self);
        
        let translation = CGPointMake(inScene.x - prevPosition.x, inScene.y - prevPosition.y);
        
        self.panForTranslation(translation);
        
    }
    
    func panForTranslation(translation : CGPoint) {
        let currentPos = umbrella?.position;
        
        umbrella?.position = CGPointMake(currentPos!.x + translation.x , currentPos!.y);
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        var timeSinceLast = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        
        if(timeSinceLast >= 1) {
            timeSinceLast = (1.0 / 60.0);
            self.lastUpdateTimeInterval = currentTime;
        }
        
        updateRainWithTimeSinceLastUpdate(timeSinceLast);
        updateMovementWithTimeSinceLastUpdate(timeSinceLast);
        updateTimeWithTimeSinceLastUpdate(timeSinceLast);
    }
    
    func updateRainWithTimeSinceLastUpdate(timeSinceLast : CFTimeInterval) {
        var difficulty : Double = multiplier_raindropSpeed / Double(self.level) ;

        self.lastRainSpawnTimeInterval += timeSinceLast;
        if(self.lastRainSpawnTimeInterval > NSTimeInterval(difficulty)) {
            self.lastRainSpawnTimeInterval = 0;
            self.drops.addObject(CreateManager.createRainDrop(self));
        }
       
    }
    
    func updateMovementWithTimeSinceLastUpdate(timeSinceLast : CFTimeInterval) {
        
        var difficulty : Double = self.multiplier_peopleSpeed / Double(self.level) ;
        self.lastHumanWalkTimeInterval += timeSinceLast;
        
        if(self.lastHumanWalkTimeInterval > NSTimeInterval(difficulty)) {
            self.lastHumanWalkTimeInterval = 0;
            
            let range : CGFloat = (self.frame.width);
            
            for h in self.humans {
                let rnd : CGFloat = CGFloat(arc4random() % UInt32(range));
                h.runAction(SKAction.moveToX(rnd, duration: 2))
            }
            
        }
        
    }
    
    func updateTimeWithTimeSinceLastUpdate(timeSinceLast : CFTimeInterval) {
        
        self.lastTimerTimeInterval += timeSinceLast;
        if(self.lastTimerTimeInterval > 1) {
            self.lastTimerTimeInterval = 0;
            self.seconds += 1;
            
            if(self.seconds % 10 == 0) {
                println("level up");
                self.level += 1;
            }
            
            self.timeLabel.text = String(format: "%d", self.seconds);
            
        }
        
    }
    
    func createAllPeople() {
        self.humans = NSMutableArray();
        
        for i in 0...10 {
            self.humans.addObject(CreateManager.createCharacter(self));
        }
        
    }
    
    func didBeginContact(contact : SKPhysicsContact){
        var firstBody : SKPhysicsBody;
        var secondBody : SKPhysicsBody;
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        } else {
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if (firstBody.node!.isKindOfClass(RainDrop)) {
            if(secondBody.node!.isKindOfClass(Human)) {
                
                self.removeHuman(secondBody)
                
            }
            firstBody.node!.removeFromParent();
            
        }
        
    }
    
    func removeHuman (human : SKPhysicsBody) {
        
        CreateManager.createVanishParticle(self, node: human.node!);
        
        human.node!.removeFromParent();
        
        if(!self.checkForEnd()) {
            self.scene!.paused = true;
            var alert = UIAlertView(title: "GAME OVER!", message: "Alle leute sind gestorben", delegate: self, cancelButtonTitle: "Restart");
            alert.show();
        }
        
    }
    
    func checkForEnd () -> Bool{
        var humanLeft = false;
        var allChildren = self.children;
        
        for n in allChildren {
            if (n.isKindOfClass(Human)) {
                return true;
            }
        }
        
        return humanLeft;
    
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        self.startGame();
        
    }
}
