//
//  ArrayExtensionsTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 29/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftMiniZip

final class ArrayExtensionsTests: XCTestCase {
    func testFilterDepth0() {
        let paths: [Path] = ["folder/", "folder/file.txt", "file.txt", "folder/folder/"]
        let result = paths.filterDepth(0)
        XCTAssertEqual(["folder/","file.txt"], result)
    }
    
    func testFilterDepth1() {
        let paths: [Path] = ["folder/", "folder/file.txt", "file.txt", "folder/folder/"]
        let result = paths.filterDepth(1)
        XCTAssertEqual(["folder/file.txt", "folder/folder/"], result)
    }
    
    func testFilterDepth2() {
        let paths: [Path] = ["folder/", "folder/file.txt", "file.txt", "folder/folder/"]
        let result = paths.filterDepth(2)
        XCTAssertEqual([], result)
    }
}
