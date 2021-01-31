//
//  SKShapeNodeExtension.swift
//  Tetris
//
//  Created by Albertino Padin on 1/30/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//

import SpriteKit


extension SKShapeNode {
    // Modified from: https://stackoverflow.com/questions/35683376/rotating-a-cgpoint-around-another-cgpoint
    func rotateRelativeTo(origin: CGPoint, byDegrees: CGFloat) {
        let dx = self.position.x - origin.x
        let dy = self.position.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let deg2rads = byDegrees * CGFloat(Double.pi / 180.0) // convert it to radians
        let newAzimuth = azimuth + deg2rads
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        self.position = CGPoint(x: x, y: y)
        self.zRotation = deg2rads
    }
    
    func rotateRelativeTo(origin: CGPoint, byRadians: CGFloat) {
        let dx = self.position.x - origin.x
        let dy = self.position.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byRadians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        self.position = CGPoint(x: x, y: y)
        self.zRotation = byRadians
    }
}
