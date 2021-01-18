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
    static let ROTATE_CW_ACTION = SKAction.rotate(byAngle: CGFloat(-Double.pi/2),
                                                  duration: 0.1)
    static let ROTATE_CCW_ACTION = SKAction.rotate(toAngle: CGFloat(Double.pi/2),
                                                   duration: 0.1)
    
    var parentNode: SKNode
    var blocks: [SKShapeNode]
    let defBlockSize = CGSize(width: 50.0, height: 50.0)
    let defBlockCornerRadius: CGFloat = 5.0
    
    let defFillColor = SKColor.blue
    let defStrokeColor = SKColor.red
    
    var position: CGPoint {
        get {
            parentNode.position
        }
        set {
            parentNode.position = newValue
        }
    }
    
    init(type: TetrominoType) {
        parentNode = SKNode()
        blocks = [SKShapeNode]()
        
        for _ in 0...3 {
            blocks.append(createBlock(size: defBlockSize,
                                      cornerRadius: defBlockCornerRadius,
                                      fillColor: defFillColor,
                                      strokeColor: defStrokeColor))
        }
        
        blocks.forEach { block in
            parentNode.addChild(block)
        }
        
        switch type {
        case .Straight:
            arrageStraight()
        case .Square:
            arrangeSquare()
        case .L:
            arrangeL()
        case .J:
            arrangeJ()
        case .T:
            arrangeT()
        case .S:
            arrangeS()
        case .Z:
            arrangeZ()
        }
        
        let center = calculateCenter()
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
    
    func calculateCenter() -> CGPoint {
        var sumPoint = CGPoint(x: 0.0, y: 0.0)
        blocks.forEach { block in
            sumPoint += block.position
        }
        return CGPoint(x: sumPoint.x / CGFloat(blocks.count),
                       y: sumPoint.y / CGFloat(blocks.count))
    }
    
    func centralizeOn(point: CGPoint) {
        blocks.forEach { block in
            block.position -= point
        }
    }
    
    func arrageStraight() {
        var xPos: CGFloat = 0.0
        let yPos: CGFloat = 0.0
        blocks.forEach { block in
            setBlockPosition(block: block, x: xPos, y: yPos)
            xPos += defBlockSize.width
        }
    }
    
    func arrangeSquare() {
        let xPos: CGFloat = 10.0
        let yPos: CGFloat = 0.0
        
        let t1 = blocks[0], t2 = blocks[1]
        let b1 = blocks[2], b2 = blocks[3]
        
        setBlockPosition(block: t1, x: xPos, y: yPos)
        setBlockPosition(block: t2, x: xPos + defBlockSize.width, y: yPos)
        
        setBlockPosition(block: b1, x: xPos, y: yPos + defBlockSize.height)
        setBlockPosition(block: b2,
                         x: xPos + defBlockSize.width,
                         y: yPos + defBlockSize.height)
    }
    
    func arrangeL() {
        arrageStraight()
        let firstBlockPos = blocks.first!.position
        blocks.first?.position = CGPoint(x: firstBlockPos.x + defBlockSize.width,
                                         y: firstBlockPos.y + defBlockSize.height)
    }
    
    func arrangeJ() {
        arrageStraight()
        let lastBlockPos = blocks.last!.position
        blocks.last?.position = CGPoint(x: lastBlockPos.x - defBlockSize.width,
                                        y: lastBlockPos.y + defBlockSize.height)
    }
    
    func arrangeT() {
        arrageStraight()
        let firstBlockPos = blocks.first!.position
        blocks.first?.position = CGPoint(x: firstBlockPos.x + (defBlockSize.width * 2),
                                         y: firstBlockPos.y + defBlockSize.height)
    }
    
    func arrangeS() {
        arrangeSquare()
        let bottom2 = blocks[2...3]
        bottom2.forEach { block in
            let ogPos = block.position
            block.position = CGPoint(x: ogPos.x - defBlockSize.width, y: ogPos.y)
        }
    }
    
    func arrangeZ() {
        arrangeSquare()
        let bottom2 = blocks[2...3]
        bottom2.forEach { block in
            let ogPos = block.position
            block.position = CGPoint(x: ogPos.x + defBlockSize.width, y: ogPos.y)
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
        parentNode.position.y += defBlockSize.height
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
