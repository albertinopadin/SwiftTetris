//
//  ArrayExtension.swift
//  Tetris
//
//  Created by Albertino Padin on 1/30/21.
//  Copyright © 2021 Albertino Padin. All rights reserved.
//


extension Array {
    subscript(circular index: Int) -> Element? {
        guard !isEmpty else { return nil }
        guard index < 0 || index >= count else { return self[index] }
        if index >= 0 {
            return self[index % count]
        } else {
            var idx = count - (abs(index) % count)
            if idx == count {
                idx = 0
            }
            print("Index: \(idx)")
            return self[idx]
        }
    }
}
