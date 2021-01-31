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
    let minimumVerticalNormalContact: CGFloat = 0.99
    let columns = 12
    let rows: Int
    var rowCounts: [Int]
    var stoppedNodesRows: [[SKShapeNode?]]
    let blockSize: CGSize
    let columnsInfo: [ColumnInfo]
    let topMidpoint: CGPoint
    let screenMidpointX: CGFloat
    var activeTetromino: Tetromino?
    let defaultStepInterval: TimeInterval = 0.1
    let viewSize: CGSize
    let debounceTime: TimeInterval = 0.1
    var lastBlockStopTime: TimeInterval = 0.0
    var _currentTime: TimeInterval = 0.0
    
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
    
    static func calculateNumberOfRows(viewFrameHeight: CGFloat, blockHeight: CGFloat) -> Int {
        return Int(viewFrameHeight / blockHeight)
    }
    
    override init(size: CGSize) {
        print("View size: \(size)")
        viewSize = size
        blockSize = GameScene.calculateBlockSize(viewFrameWidth: size.width,
                                                 numberOfColumns: columns)
        columnsInfo = GameScene.calculateColumnsInfo(viewFrameWidth: size.width,                                                                          numberOfColumns: columns,
                                                     columnWidth: blockSize.width)
        
        screenMidpointX = 0
        topMidpoint = CGPoint(x: screenMidpointX, y: size.height/2)
        rows = GameScene.calculateNumberOfRows(viewFrameHeight: size.height, blockHeight: blockSize.height)
        print("Number of rows: \(rows)")
        rowCounts = [Int].init(repeating: 0, count: rows)
        stoppedNodesRows = [[SKShapeNode?]].init(repeating: [SKShapeNode?].init(repeating: nil, count: columns),
                                                 count: rows)
        super.init(size: size)
        setupPhysicsWorld()
//        printColumnsInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func printColumnsInfo() {
        print("Columns Info:")
        columnsInfo.forEach { ci in
            print("""
                left extent: \(ci.extent.left);
                right extent: \(ci.extent.right);
                center: \(ci.center)
                """)
        }
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapRecognizer)
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        rightSwipeRecognizer.direction = .right
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipeRecognizer.direction = .left
        
        view.addGestureRecognizer(rightSwipeRecognizer)
        view.addGestureRecognizer(leftSwipeRecognizer)
        
        // Start game:
        insertRandomTetrominoAtTop()
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let touchLocation = recognizer.location(in: self.view!)
            if let active = activeTetromino {
                if touchLocation.x > screenMidpointX {
                    print("Rotating cw")
                    active.rotateClockwise()
                } else {
                    print("Rotating CCW")
                    active.rotateCounterClockwise()
                }
            }
        }
    }
    
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        let direction = recognizer.direction
        print("Swipe direction: \(direction)")
        
        if direction == .right {
            activeTetromino?.moveRight()
        }
        
        if direction == .left {
            activeTetromino?.moveLeft()
        }
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
    
    func getClosestColumnCenter(atPoint pos: CGPoint) -> CGFloat {
        var closestCenter: CGFloat = 0.0
        columnsInfo.forEach { ci in
            if (pos.x >= ci.extent.left && pos.x <= ci.extent.right) {
                closestCenter = ci.center
            }
        }
        return closestCenter
    }
    
    func getClosestColumnPosition(atPoint pos: CGPoint) -> CGPoint {
        let closestXCenter = getClosestColumnCenter(atPoint: pos)
//        print("Closest X Center: \(closestXCenter)")
        return CGPoint(x: closestXCenter, y: pos.y)
    }
    
    func insertRandomTetromino(atPoint pos: CGPoint) {
        let randomTetronimo = createRandomTetrisShape()
        randomTetronimo.position = getClosestColumnPosition(atPoint: pos)
        randomTetronimo.addToScene(self)
        randomTetronimo.setStepdownAction(stepInterval: defaultStepInterval)
        activeTetromino = randomTetronimo
    }
    
    func insertRandomTetrominoAtTop() {
        insertRandomTetromino(atPoint: topMidpoint)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        _currentTime = currentTime
    }
    
    func insertIntoStoppedBlockArray(block: SKShapeNode, row: Int, column: Int) {
        stoppedNodesRows[row][column] = block
    }
    
    func getRowAndColumnFromPosition(position: CGPoint) -> (Int, Int) {
        print("Block position: \(position)")
        let halfHeight = viewSize.height/2
        let halfWidth = viewSize.width/2
        let blockWidthFloat = CGFloat(blockSize.width)
        let blockHeightFloat = CGFloat(blockSize.height)
        let row = Int(position.y / blockHeightFloat) + Int(halfHeight / blockHeightFloat)
        let column = Int(position.x / blockWidthFloat) + Int(halfWidth / blockWidthFloat)
        return (row, column)
    }
    
    func getBlockPositionInSceneCoordinates(_ block: SKShapeNode, parentPosition: CGPoint) -> CGPoint {
        let blockPositionInParent = block.position
        return parentPosition + blockPositionInParent
    }
    
    func constructPhysicsBody(block: SKShapeNode) -> SKPhysicsBody {
        let visibleBlockSize = block.frame.size
        let reducedSize = CGSize(width: visibleBlockSize.width *
                                        Tetromino.PHYSICS_BODY_SIZE_RATIO,
                                 height: visibleBlockSize.height *
                                        Tetromino.PHYSICS_BODY_SIZE_RATIO)
        
        let physicsBody = SKPhysicsBody(rectangleOf: reducedSize, center: block.position)
        physicsBody.isDynamic = false
        physicsBody.allowsRotation = false
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.categoryBitMask = Tetromino.CATEGORY_BM
        physicsBody.collisionBitMask = Tetromino.CATEGORY_BM | GameFrame.CATEGORY_BM
        physicsBody.contactTestBitMask = Tetromino.CATEGORY_BM | GameFrame.CATEGORY_BM
        return physicsBody
    }
    
    func transferBlockToSelf(block: SKShapeNode) {
        let blockParentPosition = block.parent!.position
        let blockParentRotation = block.parent!.zRotation
        let blockPosition = getBlockPositionInSceneCoordinates(block, parentPosition: blockParentPosition)
        block.removeFromParent()
        block.position = blockPosition
        block.rotateRelativeTo(origin: blockParentPosition, byRadians: blockParentRotation)
        addChild(block)
        block.physicsBody = constructPhysicsBody(block: block)
    }
    
    func insertStoppedTetrominoBlocksIntoSelf() {
        // Get position of each block
        // Based on position insert in internal array of arrays:
        activeTetromino!.blocks.forEach { block in
            let (row, column) = getRowAndColumnFromPosition(position: block.position)
            insertIntoStoppedBlockArray(block: block, row: row, column: column)
            transferBlockToSelf(block: block)
        }
        
        activeTetromino!.removeFromScene()
    }
    
    func calculateRows() {
        for (idx, row) in stoppedNodesRows.enumerated() {
            row.forEach { column in
                if let _ = column {
                    rowCounts[idx] += 1
                }
            }
        }
    }
    
    func removeStoppedNodeRow(rowIdx: Int) {
        stoppedNodesRows[rowIdx].forEach { node in
            if let node = node {
                node.physicsBody = nil
                node.removeFromParent()
                // TODO: WARNING: MEMORY LEAK CAN HAPPEN HERE!
            }
        }
        
        stoppedNodesRows[rowIdx].removeAll()
        stoppedNodesRows[rowIdx] = [SKShapeNode?].init(repeating: nil, count: columns)
    }
    
    func removeFullRows() {
        for (idx, rowCount) in rowCounts.enumerated() {
            if rowCount >= columns {
                removeStoppedNodeRow(rowIdx: idx)
            }
        }
    }
    
    func stopActiveTetromino() {
        activeTetromino?.stop()
//        insertStoppedTetrominoBlocksIntoSelf()  // <- BUG HERE!
//        calculateRows()
//        removeFullRows()
        // methodToRunToAnimateNonFullRowBlocksFalling()
        // recalculateRows() ???
        insertRandomTetrominoAtTop()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if _currentTime - lastBlockStopTime > debounceTime {
            let bodyA = contact.bodyA.node!
            let bodyB = contact.bodyB.node!
            
            print("Contact Normal: \(contact.contactNormal)")
            
            if bodyA.name == Tetromino.ACTIVE_TETROMINO_NAME &&
                bodyB.name == GameFrame.FRAME_NAME {
                print("didBegin contact [Block & Frame]")
                stopActiveTetromino()
                lastBlockStopTime = _currentTime
            }
            
            if bodyB.name == Tetromino.ACTIVE_TETROMINO_NAME &&
                bodyA.name == GameFrame.FRAME_NAME {
                print("didBegin contact [Block & Frame]")
                stopActiveTetromino()
                lastBlockStopTime = _currentTime
            }
            
            if (bodyA.name == Tetromino.ACTIVE_TETROMINO_NAME &&
                bodyB.name == Tetromino.STOPPED_TETROMINO_NAME) ||
               (bodyB.name == Tetromino.ACTIVE_TETROMINO_NAME &&
                bodyA.name == Tetromino.STOPPED_TETROMINO_NAME) {
                print("didBegin contact [Block & Block]")
                if contact.contactNormal.dy > minimumVerticalNormalContact {
                    stopActiveTetromino()
                    lastBlockStopTime = _currentTime
                }
            }
        }
    }
    
}
