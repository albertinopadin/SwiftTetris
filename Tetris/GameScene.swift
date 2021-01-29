//
//  GameScene.swift
//  Tetris
//
//  Created by Albertino Padin on 1/3/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit
import GameplayKit


struct ColumnInfo {
    let extent: (left: CGFloat, right: CGFloat)
    var center: CGFloat {
        get {
            ((extent.right - extent.left) / 2) + extent.left
        }
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    let columns = 12
    let blockSize: CGSize
    let columnsInfo: [ColumnInfo]
    
    static func calculateBlockSize(viewFrameWidth: CGFloat, numberOfColumns: Int) -> CGSize {
        let blockWidth = viewFrameWidth / CGFloat(numberOfColumns)
        return CGSize(width: blockWidth, height: blockWidth)
    }
    
    static func calculateColumnsInfo(viewFrameWidth: CGFloat,
                                     numberOfColumns: Int,
                                     columnWidth: CGFloat) -> [ColumnInfo] {
        var infos = [ColumnInfo]()
        let frameWidthHalf: CGFloat = viewFrameWidth*0.5
        for i in 0..<numberOfColumns {
            infos.append(ColumnInfo(extent: (CGFloat(i)*columnWidth - frameWidthHalf,
                                             CGFloat(i)*columnWidth + columnWidth - frameWidthHalf)))
        }
        return infos
    }
    
    override init(size: CGSize) {
        blockSize = GameScene.calculateBlockSize(viewFrameWidth: size.width,
                                                 numberOfColumns: columns)
        columnsInfo = GameScene.calculateColumnsInfo(viewFrameWidth: size.width,                                                        numberOfColumns: columns,
                                                     columnWidth: blockSize.width)
        
        print("Columns Info:")
        columnsInfo.forEach { ci in
            print("""
                left extent: \(ci.extent.left);
                right extent: \(ci.extent.right);
                center: \(ci.center)
                """)
        }
        
        super.init(size: size)
        setupPhysicsWorld()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhysicsWorld() {
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let gameFrame = GameFrame(frame: view.frame, edgeWidth: 6)
        self.addChild(gameFrame.frameNode)
        self.addChild(gameFrame.bottomNode)
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
    
    func getClosestColumnCenter(touchPoint: CGPoint) -> CGFloat {
        var closestCenter: CGFloat = 0.0
        columnsInfo.forEach { ci in
            if (touchPoint.x >= ci.extent.left && touchPoint.x <= ci.extent.right) {
                closestCenter = ci.center
            }
        }
        return closestCenter
    }
    
    func getClosestColumnPosition(touchPoint: CGPoint) -> CGPoint {
        let closestXCenter = getClosestColumnCenter(touchPoint: touchPoint)
        print("Closest X Center: \(closestXCenter)")
        return CGPoint(x: closestXCenter, y: touchPoint.y)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let randomTetronimo = createRandomTetrisShape()
        let randomRotation = getTetrominoRotationRandom()
        randomTetronimo.position = getClosestColumnPosition(touchPoint: pos)
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node!
        let bodyB = contact.bodyB.node!
        
        if bodyA.name == Tetromino.TETROMINO_NAME && bodyB.name == GameFrame.FRAME_NAME {
            print("didBegin contact!")
            bodyA.removeAllActions()
        }
        
        if bodyB.name == Tetromino.TETROMINO_NAME && bodyA.name == GameFrame.FRAME_NAME {
            print("didBegin contact!")
            bodyB.removeAllActions()
        }
    }
    
}
