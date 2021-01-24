//
//  GameFrame.swift
//  Tetris
//
//  Created by Albertino Padin on 1/24/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit


class GameFrame {
    let frameNode: SKShapeNode
    
    init(frameSize: CGSize, edgeWidth: CGFloat) {
        frameNode = SKShapeNode(rectOf: frameSize)
        frameNode.strokeColor = .red
        frameNode.lineWidth = edgeWidth
        frameNode.position = CGPoint(x: 0.5, y: 0.5)
    }

}
