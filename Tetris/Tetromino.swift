//
//  TetrisShape.swift
//  Tetris
//
//  Created by Albertino Padin on 1/3/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit


enum TetrominoType: CaseIterable {
    case Straight, Square, L, J, T, S, Z
}

class Tetromino {
    static let DEFAULT_BLOCK_SIZE = CGSize(width: 30.0, height: 30.0)
    static let DEFAULT_BLOCK_CORNER_RADIUS: CGFloat = 7.0
    
    static let DEFAULT_FILL_COLOR = SKColor.blue
    static let DEFAULT_STROKE_COLOR = SKColor.red
    
    static let ROTATE_CW_ACTION = SKAction.rotate(byAngle: CGFloat(-Double.pi/2),
                                                  duration: 0.1)
    static let ROTATE_CCW_ACTION = SKAction.rotate(toAngle: CGFloat(Double.pi/2),
                                                   duration: 0.1)
    static let STEP_DOWN_ACTION = SKAction.moveBy(x: 0.0,
                                                  y: -DEFAULT_BLOCK_SIZE.height,
                                                  duration: 0.2)
    
    var parentNode: SKNode
    var blocks: [SKShapeNode]
    var blockSize: CGSize
    
    var position: CGPoint {
        get {
            parentNode.position
        }
        set {
            parentNode.position = newValue
        }
    }
    
    init(type: TetrominoType, blockSize bsize: CGSize = Tetromino.DEFAULT_BLOCK_SIZE) {
        // TODO: SKSpriteNode provides better performance than SKShapeNode.
        //       would it be better to use SKSpriteNode?
        parentNode = SKNode()
        blocks = [SKShapeNode]()
        blockSize = bsize
        
        for _ in 0...3 {
            blocks.append(createBlock(size: blockSize,
                                      cornerRadius: Tetromino.DEFAULT_BLOCK_CORNER_RADIUS,
                                      fillColor: Tetromino.DEFAULT_FILL_COLOR,
                                      strokeColor: Tetromino.DEFAULT_STROKE_COLOR))
        }
        
        blocks.forEach { block in
            parentNode.addChild(block)
        }
        
        switch type {
        case .Straight:
            arrageStraight(blockSize: blockSize)
        case .Square:
            arrangeSquare(blockSize: blockSize)
        case .L:
            arrangeL(blockSize: blockSize)
        case .J:
            arrangeJ(blockSize: blockSize)
        case .T:
            arrangeT(blockSize: blockSize)
        case .S:
            arrangeS(blockSize: blockSize)
        case .Z:
            arrangeZ(blockSize: blockSize)
        }
        
        let center = calculateCenterInBlock()
        centralizeOn(point: center)
    }
    
    func createBlock(size: CGSize,
                     cornerRadius: CGFloat,
                     fillColor: SKColor,
                     strokeColor: SKColor) -> SKShapeNode {
        let block = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        block.fillColor = fillColor
        block.strokeColor = strokeColor
        return block
    }
    
    func setBlockPosition(block: SKShapeNode, x: CGFloat, y: CGFloat) {
        block.position = CGPoint(x: x, y: y)
    }
    
    func getNearestBlock(to point: CGPoint) -> SKShapeNode {
        var nearest = blocks.first!
        var smallestDistance: CGFloat = 1000000
        blocks.forEach { block in
            let distance = block.position.distanceSquared(to: point)
            if distance < smallestDistance {
                smallestDistance = distance
                nearest = block
            }
        }
        return nearest
    }
    
    func calculateCenter() -> CGPoint {
        var sumPoint = CGPoint(x: 0.0, y: 0.0)
        blocks.forEach { block in
            sumPoint += block.position
        }
        return CGPoint(x: sumPoint.x / CGFloat(blocks.count),
                       y: sumPoint.y / CGFloat(blocks.count))
    }
    
    func calculateCenterInBlock() -> CGPoint {
        let absoluteCenter = calculateCenter()
        let nearestCenterBlock = getNearestBlock(to: absoluteCenter)
        return nearestCenterBlock.position
    }
    
    func centralizeOn(point: CGPoint) {
        blocks.forEach { block in
            block.position -= point
        }
    }
    
    func arrageStraight(blockSize: CGSize) {
        var xPos: CGFloat = 0.0
        let yPos: CGFloat = 0.0
        blocks.forEach { block in
            setBlockPosition(block: block, x: xPos, y: yPos)
            xPos += blockSize.width
        }
    }
    
    func arrangeSquare(blockSize: CGSize) {
        let xPos: CGFloat = 10.0
        let yPos: CGFloat = 0.0
        
        let t1 = blocks[0], t2 = blocks[1]
        let b1 = blocks[2], b2 = blocks[3]
        
        setBlockPosition(block: t1, x: xPos, y: yPos)
        setBlockPosition(block: t2, x: xPos + blockSize.width, y: yPos)
        
        setBlockPosition(block: b1, x: xPos, y: yPos + blockSize.height)
        setBlockPosition(block: b2,
                         x: xPos + blockSize.width,
                         y: yPos + blockSize.height)
    }
    
    func arrangeL(blockSize: CGSize) {
        arrageStraight(blockSize: blockSize)
        let firstBlockPos = blocks.first!.position
        blocks.first?.position = CGPoint(x: firstBlockPos.x + blockSize.width,
                                         y: firstBlockPos.y + blockSize.height)
    }
    
    func arrangeJ(blockSize: CGSize) {
        arrageStraight(blockSize: blockSize)
        let lastBlockPos = blocks.last!.position
        blocks.last?.position = CGPoint(x: lastBlockPos.x - blockSize.width,
                                        y: lastBlockPos.y + blockSize.height)
    }
    
    func arrangeT(blockSize: CGSize) {
        arrageStraight(blockSize: blockSize)
        let firstBlockPos = blocks.first!.position
        blocks.first?.position = CGPoint(x: firstBlockPos.x + (blockSize.width * 2),
                                         y: firstBlockPos.y + blockSize.height)
    }
    
    func arrangeS(blockSize: CGSize) {
        arrangeSquare(blockSize: blockSize)
        let bottom2 = blocks[2...3]
        bottom2.forEach { block in
            let ogPos = block.position
            block.position = CGPoint(x: ogPos.x - blockSize.width, y: ogPos.y)
        }
    }
    
    func arrangeZ(blockSize: CGSize) {
        arrangeSquare(blockSize: blockSize)
        let bottom2 = blocks[2...3]
        bottom2.forEach { block in
            let ogPos = block.position
            block.position = CGPoint(x: ogPos.x + blockSize.width, y: ogPos.y)
        }
    }
    
    func addToScene(_ scene: SKScene) {
        scene.addChild(parentNode)
    }
    
    func removeFromScene() {
        parentNode.removeFromParent()
    }
    
    func stepDown() {
        // Add animation for this:
//        parentNode.position.y += defBlockSize.height
        parentNode.run(Tetromino.STEP_DOWN_ACTION)
    }
    
    func rotateClockwise() {
        parentNode.run(Tetromino.ROTATE_CW_ACTION)
    }
    
    func rotateCounterClockwise() {
        parentNode.run(Tetromino.ROTATE_CCW_ACTION)
    }
    
    func runAction(_ action: SKAction) {
        parentNode.run(action)
    }
}
