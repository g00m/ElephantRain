//
//  CreateManager.swift
//  swiftgame
//
//  Created by Stephen Chan on 6/4/14.
//  Copyright (c) 2014 Squid Ink Games. All rights reserved.
//

import SpriteKit

struct CreateManager {
   
    static func createBackground(parent : SKScene) -> (SKSpriteNode){
        let background = SKSpriteNode(imageNamed: "Background.png");
        background.position = CGPointMake(CGRectGetMidX(parent.frame), CGRectGetMidY(parent.frame));
        background.size = parent.size;
        parent.addChild(background);
        
        return (background);
    }
    
    static func createCharacter(parent : SKScene) -> Human{
        let atlas : SKTextureAtlas = SKTextureAtlas(named: "sprites");
        let f1 : SKTexture = atlas.textureNamed("Stickman_back.png");
        let f2 : SKTexture = atlas.textureNamed("Stickman.png");

        let characterFrames : Array = [f1,f2];
        
        let range : CGFloat = (parent.frame.width);
        let rnd : CGFloat = CGFloat(arc4random() % UInt32(range));
        
        let object : Human = Human(imageNamed: "Stickman.png");
        object.position =  CGPointMake(CGRectGetMinX(parent.frame) - 50 + rnd, CGRectGetMidY(parent.frame) - 150);
        
        let action : SKAction = SKAction.repeatActionForever(SKAction.animateWithTextures(characterFrames, timePerFrame: 0.1));
        object.runAction(action);
        
        object.physicsBody = SKPhysicsBody(rectangleOfSize: object.size);
        object.physicsBody!.categoryBitMask = ContactCategory.human;
        object.physicsBody!.collisionBitMask = ContactCategory.ground;
        object.physicsBody!.contactTestBitMask = ContactCategory.drop;
        
        parent.addChild(object);
        
        return object;
    }
    
    static func createRainDrop(parent : SKScene) -> RainDrop{
        let object : RainDrop = RainDrop(imageNamed: "Drop");
        let range : CGFloat = (parent.frame.width);
        let rnd : CGFloat = CGFloat(arc4random() % UInt32(range));
        
        object.position.x = CGFloat(CGRectGetMinX(parent.frame) + rnd);
        object.position.y = parent.frame.height + object.size.height;//CGFloat(CGRectGetMidY(parent.frame) - 10 + rnd);
        
        object.physicsBody = SKPhysicsBody(rectangleOfSize: object.size);
        object.physicsBody!.categoryBitMask = ContactCategory.drop;
        object.physicsBody!.contactTestBitMask = ContactCategory.human | ContactCategory.ground;
        
        parent.addChild(object);
        
        return object;
    }
    
    static func createGround(parent : SKScene) -> Ground{
        let object : Ground = Ground(imageNamed: "Ground");
        
        object.position.x = CGFloat(CGRectGetMidX(parent.frame));
        object.position.y = CGFloat(CGRectGetMinY(parent.frame) + object.size.height - 40);//CGFloat(CGRectGetMidY(parent.frame) - 10 + rnd);
        
        object.size.width = parent.size.width;
        
        object.physicsBody = SKPhysicsBody(rectangleOfSize: object.size);
        object.physicsBody!.categoryBitMask = ContactCategory.ground;
        object.physicsBody!.collisionBitMask = 0 ;
        
        object.physicsBody!.affectedByGravity = false;
        
        parent.addChild(object);
        
        return object;
    }
    
    static func createUmbrella(parent : SKScene) -> Umbrella {
        let object : Umbrella = Umbrella(imageNamed: "Umbrella");
        
        object.position.x = CGFloat(CGRectGetMidX(parent.frame));
        object.position.y = CGFloat(CGRectGetMidY(parent.frame));

        object.physicsBody = SKPhysicsBody(rectangleOfSize: object.size);
        object.physicsBody!.categoryBitMask = ContactCategory.umbrella;
        object.physicsBody!.collisionBitMask = 0;
        object.physicsBody!.contactTestBitMask = ContactCategory.drop;
        
        object.physicsBody!.affectedByGravity = false;
        
        parent.addChild(object);
        
        return object;
    }

    static func createVanishParticle (parent : SKScene, node : SKNode) {
        
        var smoke = SKEmitterNode(fileNamed: "SparkParticle");
        smoke.position = node.position;
        smoke.numParticlesToEmit = 1 * Int(smoke.particleBirthRate);
        parent.addChild(smoke);
        
    }
    
    // von 100
    // bis 200
    static func createClouds (parent : SKScene) {
        var movementAction = self.createCloudMovement(parent);
        let minCloud : Int = 15;
        
        for i in 15...(arc4random_uniform(30) + minCloud) {
            parent.addChild(self.createCloudObject(CGFloat(arc4random_uniform(UInt32(parent.frame.width))), parent: parent, action: self.createCloudMovement(parent)));
            
        }
    }
    
    static private func createCloudMovement (parent : SKScene) -> SKAction {
        //var movementAction : SKAction = SKAction.moveToX(CGFloat(CGRectGetMinX(parent.frame), duration: arc4random_uniform(2)));
        var movementAction = SKAction.moveToX(CGFloat(CGRectGetMinX(parent.frame) - 100), duration: NSTimeInterval(arc4random_uniform(100) + 5));
        
        
        return movementAction;
        
    }
    
    static private func createCloudObject (xPosition : CGFloat, parent : SKScene, action : SKAction) -> Cloud {
        var frameWidth = CGRectGetMaxX(parent.frame);
        var cloudName = String(format: "Cloud%d.png", arc4random_uniform(9) + 1);
        let object = Cloud(imageNamed: cloudName as String);
        
        object.position.x = xPosition;        
        object.position.y = CGFloat(CGRectGetMaxY(parent.frame)) - CGFloat(arc4random_uniform(150) + 100);
        
        object.runAction(action, completion: { () -> Void in
            parent.addChild(self.createCloudObject(CGFloat(CGRectGetMaxX(parent.frame)), parent : parent, action: action));
            object.removeFromParent();
        });
        
        return object;
    }
    
}
