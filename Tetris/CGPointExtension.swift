//
//  CGPointExtension.swift
//  Tetris
//
//  Created by Albertino Padin on 1/17/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    func distanceSquared(to: CGPoint) -> CGFloat {
        let xDiff = to.x - self.x
        let yDiff = to.y - self.y
        return (xDiff*xDiff) + (yDiff*yDiff)
    }
}
