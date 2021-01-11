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
    var blocks: [SKShapeNode]
    let defBlockSize = CGSize(width: 50.0, height: 50.0)
    let defBlockCornerRadius: CGFloat = 5.0
    
    let defFillColor = SKColor.blue
    let defStrokeColor = SKColor.red
    
    var position: CGPoint {
        get {
            blocks[3].position
        }
        set {
            // TODO: Set position of third block, and all other blocks
            //       relative to it.
        }
    }
    
    init(type: TetrominoType) {
        blocks = [SKShapeNode]()
        
        for _ in 0...4 {
            blocks.append(createBlock(size: defBlockSize,
                                      cornerRadius: defBlockCornerRadius,
                                      fillColor: defFillColor,
                                      strokeColor: defStrokeColor))
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
    
    func arrageStraight() {
        var xPos: CGFloat = 10.0
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
        blocks.forEach({ scene.addChild($0) })
    }
    
    func removeFromScene() {
        blocks.forEach({ $0.removeFromParent() })
    }
    
    
    // Add animations for these?
    func stepDown() {
        blocks.forEach { block in
            block.position.y += defBlockSize.height
        }
    }
    
    func rotateClockwise() {
        
    }
    
    func rotateCounterClockwise() {
        
    }
    
    func runAction(_ action: SKAction) {
        blocks.forEach({ $0.run(action) })
    }
}
