//
//  ArrayExtensions.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 29/12/2022.
//

import Foundation

extension Array where Element == Path {
    func filterDepth(_ depth: Int) -> [Path] {
        var result = [Path]()
        for path in self {
            let components = path.components(separatedBy: "/")
            if path.isFolder && components.count - 2 == depth{
                result.append(path)
            }
            else if !path.isFolder && components.count - 1 == depth {
                result.append(path)
            }
        }
        return result
    }
}
