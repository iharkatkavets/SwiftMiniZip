//
//  ZipperTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 10/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Logging
import Testing

@testable import SwiftMiniZip

final class ZipTests {
    var sandboxDirURL = try! makeSandboxDirectory()
    let logger = Logger(label: "ZipTests")

    init() {
        LoggingTestObserver.initializeLogging
    }

    deinit {
        try! removeSandboxDirectory(sandboxDirURL)
    }

    @Test func testGenZipItemFiles() throws {
        let d1 = try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        let f1 = try createFile(d1.appendingPathComponent("file1.txt"), randString())
        let d2 = try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        let f2 = try createFile(d2.appendingPathComponent("file2.txt"), randString())
        let dd2 = try createFolder(d2.appendingPathComponent("folderInFolder2"))
        let dd2f2 = try createFile(dd2.appendingPathComponent("file2.txt"), randString())

        let outZip = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        var config = Zip.Config()
        config.srcs = [f1, f2, dd2f2]
        config.dstURL = outZip

        let zipItems = Zip(config: config).generateZipItems(from: config.srcs)

        #expect(zipItems[0].fileName == "file1.txt")
        #expect(zipItems[1].fileName == "file2.txt")
        #expect(zipItems[2].fileName == "file2.txt")
    }

    @Test func testGenZipItemsFolders() throws {
        let d1 = try createFolder(sandboxDirURL.appendingPathComponent("folder1"))
        try createFile(d1.appendingPathComponent("file1.txt"), randString())
        let d2 = try createFolder(sandboxDirURL.appendingPathComponent("folder2"))
        try createFile(d2.appendingPathComponent("file2.txt"), randString())
        let dd2 = try createFolder(d2.appendingPathComponent("folderInFolder2"))
        try createFile(dd2.appendingPathComponent("file2.txt"), randString())

        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        var config = Zip.Config()
        config.srcs = [d1, d2, dd2]
        config.dstURL = zipLocation

        let zipItems = Zip(config: config).generateZipItems(from: config.srcs)

        #expect(zipItems[0].fileName == "folder1/file1.txt")
        #expect(zipItems[1].fileName == "folder2/file2.txt")
        #expect(zipItems[2].fileName == "folder2/folderInFolder2/file2.txt")
    }

    @Test func testZipSingleFileWithoutPassword() throws {
        let folderURL = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let filename = randString()
        let fileURL = try createFile(folderURL.appendingPathComponent(filename), randString())

        let zipLocation = sandboxDirURL.appendingPathComponent("\(filename).zip")
        let config = Zip.Config([fileURL], zipLocation)
        try Zip(config: config).perform()

        #expect(isItemExists(zipLocation))
    }

    @Test func testZipSingleFileWithPassword() throws {
        let folderURL = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let filename = randString()
        let fileURL = try createFile(folderURL.appendingPathComponent(filename), randString())

        let zipLocation = sandboxDirURL.appendingPathComponent("\(filename).zip")
        var config = Zip.Config([fileURL], zipLocation)
        config.password = randString()
        logger.info("password=\(config.password!)")
        try Zip(config: config).perform()

        #expect(isItemExists(zipLocation))
    }

    @Test func testZipMultipleFilesWithoutPassword() throws {
        let d1 = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let f1 = try createFile(d1.appendingPathComponent(randString()), randString())
        let d2 = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let f2 = try createFile(d2.appendingPathComponent(randString()), randString())

        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        var config = Zip.Config()
        config.srcs = [d1, f1, d2, f2]
        config.dstURL = zipLocation

        try Zip(config: config).perform()

        #expect(isItemExists(zipLocation))
    }

    @Test func testZipMultipleFilesWithPassword() throws {
        let d1 = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let f1 = try createFile(d1.appendingPathComponent(randString()), randString())
        let d2 = try createFolder(sandboxDirURL.appendingPathComponent(randString()))
        let f2 = try createFile(d2.appendingPathComponent(randString()), randString())

        let zipLocation = sandboxDirURL.appendingPathComponent("\(randString()).zip")
        var config = Zip.Config()
        let password = randString()
        config.srcs = [d1, f1, d2, f2]
        config.dstURL = zipLocation
        config.password = password

        try Zip(config: config).perform()

        #expect(isItemExists(zipLocation))
    }
}
