//
//  ZipItem.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 12/12/2022.
//

import Foundation

struct ZipItem {
    let filePathURL: URL
    let fileName: String
    
    var path: String {
        return filePathURL.path
    }
}
