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
    
    static let KEY_ROTATE_CW_ACTION = "rotate_cw"
    static let KEY_ROTATE_CCW_ACTION = "rotate_ccw"
    
    static let ROTATE_CW_ACTION = SKAction.rotate(byAngle: CGFloat(-Double.pi/2),
                                                  duration: 0.1)
    static let ROTATE_CCW_ACTION = SKAction.rotate(byAngle: CGFloat(Double.pi/2),
                                                   duration: 0.1)
    static let STEP_DOWN_ACTION = SKAction.moveBy(x: 0.0,
                                                  y: -DEFAULT_BLOCK_SIZE.height,
                                                  duration: 0.2)
    
    static let BLOCK_NAME = "Tetronimo_Block"
    static let TETROMINO_NAME = "Tetronimo"
    static let CATEGORY_BM: UInt32 = 0x1 << 1
    
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
            blocks.append(Tetromino.createBlock(size: blockSize,
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
        
        // Need to do this here, after the individual blocks have been positioned:
        let shapePhysicsBody = getShapePhysicsBody()
        setupPhysics(with: shapePhysicsBody)
    }
    
    static func createBlock(size: CGSize,
                            cornerRadius: CGFloat,
                            fillColor: SKColor,
                            strokeColor: SKColor) -> SKShapeNode {
        let block = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        block.fillColor = fillColor
        block.strokeColor = strokeColor
        return block
    }
    
    static func getShapePoints(inBlocks: [SKShapeNode]) -> [CGPoint] {
        var points = [CGPoint]()
        inBlocks.forEach { block in
            let blockPos = block.position
            let blockSize = block.frame.size
            let topLeft = CGPoint(x: blockPos.x - blockSize.width/2,
                                  y: blockPos.y + blockSize.height/2)
            let topRight = CGPoint(x: blockPos.x + blockSize.width/2,
                                  y: blockPos.y + blockSize.height/2)
            let botLeft = CGPoint(x: blockPos.x - blockSize.width/2,
                                  y: blockPos.y - blockSize.height/2)
            let botRight = CGPoint(x: blockPos.x + blockSize.width/2,
                                  y: blockPos.y - blockSize.height/2)
            points.append(contentsOf: [topLeft, topRight, botLeft, botRight])
        }
        
        points = points.reduce(into: [CGPoint]()) { filtered, point in
            if filtered.last != point {
                filtered.append(point)
            }
        }
        return points
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
    
    func getShapePhysicsBody() -> SKPhysicsBody {
        let physicsBodies = blocks.map { block in
            SKPhysicsBody(rectangleOf: block.frame.size, center: block.position)
        }
        
        return SKPhysicsBody(bodies: physicsBodies)
    }
    
    func setupPhysics(with physicsBody: SKPhysicsBody) {
        parentNode.physicsBody = physicsBody
        parentNode.physicsBody?.isDynamic = true
        parentNode.physicsBody?.usesPreciseCollisionDetection = true
        parentNode.physicsBody?.categoryBitMask = Tetromino.CATEGORY_BM
        parentNode.physicsBody?.collisionBitMask = Tetromino.CATEGORY_BM | GameFrame.CATEGORY_BM
        parentNode.physicsBody?.contactTestBitMask = Tetromino.CATEGORY_BM | GameFrame.CATEGORY_BM
        parentNode.name = Tetromino.TETROMINO_NAME
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
        parentNode.removeAction(forKey: Tetromino.KEY_ROTATE_CCW_ACTION)
        parentNode.run(Tetromino.ROTATE_CW_ACTION, withKey: Tetromino.KEY_ROTATE_CW_ACTION)
    }
    
    func rotateCounterClockwise() {
        parentNode.removeAction(forKey: Tetromino.KEY_ROTATE_CW_ACTION)
        parentNode.run(Tetromino.ROTATE_CCW_ACTION, withKey: Tetromino.KEY_ROTATE_CCW_ACTION)
    }
    
    func runAction(_ action: SKAction) {
        parentNode.run(action)
    }
    
    func stop() {
        parentNode.removeAllActions()
        parentNode.physicsBody?.isDynamic = false
    }
}
