//
//  PathExtensionsTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 29/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftMiniZip

final class PathExtensionsTests: XCTestCase {
    func testIsFolderForFilePath() {
        XCTAssertFalse("file".isFolder)
        XCTAssertFalse("folder/file".isFolder)
        XCTAssertFalse("folder/folder/file".isFolder)
    }
    
    func testIsFolderForFolder() {
        XCTAssertTrue("folder/".isFolder)
        XCTAssertTrue("folder/folder/".isFolder)
        XCTAssertTrue("folder/folder/folder/".isFolder)
    }
}
