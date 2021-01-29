//
//  GameFrame.swift
//  Tetris
//
//  Created by Albertino Padin on 1/24/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit


class GameFrame {
    static let FRAME_NAME = "Frame"
    static let CATEGORY_BM: UInt32 = 0x1 << 0
    
    let frameNode: SKShapeNode
    let bottomNode: SKShapeNode
    
    init(frame: CGRect, edgeWidth: CGFloat) {
        frameNode = SKShapeNode(rectOf: frame.size)
        frameNode.strokeColor = .red
        frameNode.lineWidth = edgeWidth
        frameNode.position = CGPoint(x: 0.5, y: 0.5)
//        frameNode.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        // TODO: Define frameNode physics so that tetrominos can't pass through
//        frameNode.physicsBody?.isDynamic = false
//        frameNode.physicsBody?.categoryBitMask = GameFrame.CATEGORY_BM
//        frameNode.physicsBody?.collisionBitMask = Tetromino.CATEGORY_BM
////        frameNode.physicsBody?.contactTestBitMask = Tetromino.CATEGORY_BM
//        frameNode.name = GameFrame.FRAME_NAME
        
        let bottomNodeSize = CGSize(width: frame.size.width, height: 100)
        bottomNode = SKShapeNode(rectOf: bottomNodeSize)
        bottomNode.position = CGPoint(x: 0.5, y: -frame.size.height/2)
        bottomNode.fillColor = .cyan
//        let edgeBegin = CGPoint(x: -frame.size.width/2, y: -frame.size.height/2)
//        let edgeEnd = CGPoint(x: frame.size.width/2, y: -frame.size.height/2)
//        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: edgeBegin, to: edgeEnd)
        bottomNode.physicsBody = SKPhysicsBody(rectangleOf: bottomNodeSize)
        bottomNode.physicsBody?.isDynamic = false
        bottomNode.physicsBody?.usesPreciseCollisionDetection = true
        bottomNode.physicsBody?.categoryBitMask = GameFrame.CATEGORY_BM
        bottomNode.physicsBody?.collisionBitMask = Tetromino.CATEGORY_BM
        bottomNode.physicsBody?.contactTestBitMask = Tetromino.CATEGORY_BM
        bottomNode.name = GameFrame.FRAME_NAME
    }

}
