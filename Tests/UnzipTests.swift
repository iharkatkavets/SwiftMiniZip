//
//  UnzipTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 13/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftMiniZip

final class UnzipTests: XCTestCase {
    var sandboxDirURL: URL!
    
    override func setUpWithError() throws {
        sandboxDirURL = try makeSandboxDirectory()
    }
    
    override func tearDownWithError() throws {
        try removeSandboxDirectory(sandboxDirURL)
    }
    
    func testUnzip() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("regular", "zip")
        config.dstURL = sandboxDirURL
        let unzip = Unzip(config: config)
        
        try unzip.extract()
        
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("OriginFile.txt")))
    }
    
    func testUnzipProtected() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("complexprotected", "zip")
        config.dstURL = sandboxDirURL
        config.password = "complexprotected.zip"
        let unzip = Unzip(config: config)
        
        try unzip.extract()
        
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/file1.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/file1_1.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/file2.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/file2_2.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder3/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder3/file3.txt")))
    }
    
    func testFailsUnzipProtected() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("complexprotected", "zip")
        config.dstURL = sandboxDirURL
        config.password = "wrongPassword"
        let unzip = Unzip(config: config)
        
        XCTAssertThrowsError(try unzip.extract())
        XCTAssertFalse(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt")))
    }
    
    func testReadStructure() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("complex", "zip")
        let unzip = Unzip(config: config)
        
        let list = try unzip.readStructure()
        
        XCTAssertEqual("folder1/", list[0])
        XCTAssertEqual("folder1/file1.txt", list[1])
        XCTAssertEqual("folder1/folder1_1/", list[2])
        XCTAssertEqual("folder1/folder1_1/folder1_1_1/", list[3])
        XCTAssertEqual("folder1/folder1_1/folder1_1_1/file1_1_1.txt", list[4])
        XCTAssertEqual("folder1/folder1_1/file1_1.txt", list[5])
        XCTAssertEqual("folder2/", list[6])
        XCTAssertEqual("folder2/file2.txt", list[7])
        XCTAssertEqual("folder2/folder2_2/", list[8])
        XCTAssertEqual("folder2/folder2_2/file2_2.txt", list[9])
        XCTAssertEqual("folder3/", list[10])
        XCTAssertEqual("folder3/file3.txt", list[11])
    }
    
    func testExtractOneFile() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("regular", "zip")
        config.dstURL = sandboxDirURL
        let unzip = Unzip(config: config)
        
        let list = try unzip.readStructure()
        XCTAssertEqual("OriginFile.txt", list[0])
        try unzip.extract(["OriginFile.txt"])
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("OriginFile.txt")))
    }
    
    func testExtractInMemory() throws {
        var config = Unzip.Config()
        config.srcURL = fileURL("complexprotected", "zip")
        config.password = "complexprotected.zip"
        let unzip = Unzip(config: config)
        
        let fileData = try unzip
            .extractToMemory("folder1/folder1_1/folder1_1_1/file1_1_1.txt")
        
        let fileContent = "folder1/folder1_1/folder1_1_1/file1_1_1.txt\n"
        let expectedData = fileContent.data(using: .utf8)
        XCTAssertEqual(expectedData, fileData)
    }
}
