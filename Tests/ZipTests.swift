//
//  ZipperTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 10/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftMiniZip

final class ZipTests: XCTestCase {
    var sandboxDirURL: URL!
    
    override func setUpWithError() throws {
        sandboxDirURL = try makeSandboxDirectory()
    }
    
    override func tearDownWithError() throws {
        try removeSandboxDirectory(sandboxDirURL)
    }
    
    func testGenZipItemsFiles() throws {
        try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(sandboxDirURL.appendingPathComponent("folder1/file1.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/file2.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2/folderInFolder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/folderInFolder2/file2.txt"), randString())
        
        var config = Zip.Config()
        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        config.srcs = [
            sandboxDirURL.appendingPathComponent("folder1/file1.txt"),
            sandboxDirURL.appendingPathComponent("folder2/file2.txt"),
            sandboxDirURL.appendingPathComponent("folder2/folderInFolder2/file2.txt"),
        ]
        config.dstURL = zipLocation
        let zip = Zip(config: config)
        
        let zipItems = zip.generateZipItems(from: config.srcs)
        
        XCTAssertEqual(zipItems[0].fileName, "file1.txt")
        XCTAssertEqual(zipItems[1].fileName, "file2.txt")
        XCTAssertEqual(zipItems[2].fileName, "file2.txt")
    }
    
    func testGenZipItemsFolders() throws {
        try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(sandboxDirURL.appendingPathComponent("folder1/file1.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/file2.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2/folderInFolder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/folderInFolder2/file2.txt"), randString())
        
        var config = Zip.Config()
        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        config.srcs = [
            sandboxDirURL.appendingPathComponent("folder1"),
            sandboxDirURL.appendingPathComponent("folder2"),
        ]
        config.dstURL = zipLocation
        let zip = Zip(config: config)
        
        let zipItems = zip.generateZipItems(from: config.srcs)
        
        XCTAssertEqual(zipItems[0].fileName, "folder1/file1.txt")
        XCTAssertEqual(zipItems[1].fileName, "folder2/file2.txt")
        XCTAssertEqual(zipItems[2].fileName, "folder2/folderInFolder2/file2.txt")
    }
    
    func testZipMultipleFiles() throws {
        try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(sandboxDirURL.appendingPathComponent("folder1/file1.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/file2.txt"), randString())
        
        var config = Zip.Config()
        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        config.srcs = [
            sandboxDirURL.appendingPathComponent("folder1"),
            sandboxDirURL.appendingPathComponent("folder1/file1.txt"),
            sandboxDirURL.appendingPathComponent("folder2"),
            sandboxDirURL.appendingPathComponent("folder2/file2.txt"),
        ]
        config.dstURL = zipLocation
        let zip = Zip(config: config)
        
        try zip.perform()
        
        XCTAssertTrue(isItemExists(zipLocation))
    }
    
    func testZipMultipleFilesWithPassword() throws {
        try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(sandboxDirURL.appendingPathComponent("folder1/file1.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/file2.txt"), randString())
        
        var config = Zip.Config()
        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        let password = randString()
        config.srcs = [
            sandboxDirURL.appendingPathComponent("folder1"),
            sandboxDirURL.appendingPathComponent("folder1/file1.txt"),
            sandboxDirURL.appendingPathComponent("folder2"),
            sandboxDirURL.appendingPathComponent("folder2/file2.txt"),
        ]
        config.dstURL = zipLocation
        config.password = password
        let zip = Zip(config: config)
        
        try zip.perform()
        
        XCTAssertTrue(isItemExists(zipLocation))
    }
    
    func testZipMultipleFiles2() throws {
        try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(sandboxDirURL.appendingPathComponent("folder1/file1.txt"), randString())
        try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(sandboxDirURL.appendingPathComponent("folder2/file2.txt"), randString())
        
        var config = Zip.Config()
        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        config.srcs = [
            sandboxDirURL.appendingPathComponent("folder1"),
            sandboxDirURL.appendingPathComponent("folder1/file1.txt"),
            sandboxDirURL.appendingPathComponent("folder2"),
            sandboxDirURL.appendingPathComponent("folder2/file2.txt"),
        ]
        config.dstURL = zipLocation
        let zip = Zip(config: config)
        
        try zip.perform()
        
        XCTAssertTrue(isItemExists(zipLocation))
    }
}
