//
//  GameScene.swift
//  Tetris
//
//  Created by Albertino Padin on 1/3/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let columns = 12
    let blockSize: CGSize
    
    static func calculateBlockSize(viewFrameWidth: CGFloat, numberOfColumns: Int) -> CGSize {
        let blockWidth = viewFrameWidth / CGFloat(numberOfColumns)
        return CGSize(width: blockWidth, height: blockWidth)
    }
    
    override init(size: CGSize) {
        blockSize = GameScene.calculateBlockSize(viewFrameWidth: size.width,
                                                 numberOfColumns: columns)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let gameFrame = GameFrame(frameSize: view.frame.size, edgeWidth: 10)
        self.addChild(gameFrame.frameNode)
    }
    
    func createRandomTetrisShape() -> Tetromino {
        let randomShapeType = TetrominoType.allCases.randomElement()!
        let randomTetronimo = Tetromino(type: randomShapeType, blockSize: blockSize)
        return randomTetronimo
    }
    
    func getTetrominoRotationRandom() -> SKAction {
        if Int.random(in: 0...1) == 1 {
            return Tetromino.ROTATE_CW_ACTION
        } else {
            return Tetromino.ROTATE_CCW_ACTION
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        let randomTetronimo = createRandomTetrisShape()
        let randomRotation = getTetrominoRotationRandom()
        randomTetronimo.position = pos
        randomTetronimo.addToScene(self)
//        randomTetronimo.stepDown()
//        randomTetronimo.runAction(SKAction.sequence([SKAction.wait(forDuration: 1.0),
//                                                     randomRotation,
//                                                     SKAction.wait(forDuration: 1.0),
//                                                     SKAction.fadeOut(withDuration: 1.0),
//                                                     SKAction.removeFromParent()]))
        randomTetronimo.runAction(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            randomRotation,
            SKAction.wait(forDuration: 1.0),
            Tetromino.STEP_DOWN_ACTION
        ])))
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
