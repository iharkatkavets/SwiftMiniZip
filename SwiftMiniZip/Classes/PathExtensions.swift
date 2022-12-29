//
//  StringExtensions.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 29/12/2022.
//

import Foundation

extension Path {
    var isFolder: Bool {
        return hasSuffix("/")
    }
}
