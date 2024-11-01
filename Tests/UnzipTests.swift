//
//  UnzipTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 13/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Logging
import XCTest

@testable import SwiftMiniZip

final class UnzipTests: XCTestCase {
    var sandboxDirURL: URL!
    let logger = Logger(label: "UnzipTests")

    override class func setUp() {
        super.setUp()
        XCTestObservationCenter.shared.addTestObserver(LoggingTestObserver())
    }

    override func setUpWithError() throws {
        sandboxDirURL = try makeSandboxDirectory()
    }

    override func tearDownWithError() throws {
        try removeSandboxDirectory(sandboxDirURL)
    }

    func testUnzipOriginFileWithoutPassword() throws {
        let config = Unzip.Config(fileURL("OriginFile.txt", "zip"), sandboxDirURL)

        try Unzip(config: config).extract()

        let unzipedFile = sandboxDirURL.appendingPathComponent("OriginFile.txt")
        let originFile = fileURL("OriginFile", "txt")

        let data1 = try! Data(contentsOf: unzipedFile)
        let data2 = try! Data(contentsOf: originFile)

        XCTAssertEqual(data1, data2)
    }

    func testUnzipOriginFileWithPassword() throws {
        var config = Unzip.Config(fileURL("OriginFile.txt.encrypted", "zip"), sandboxDirURL)
        config.password = "OriginFile.txt.encrypted.zip"

        try Unzip(config: config).extract()

        let unzipedFile = sandboxDirURL.appendingPathComponent("Tests/Resources/OriginFile.txt")
        let originFile = fileURL("OriginFile", "txt")

        let data1 = try! Data(contentsOf: unzipedFile)
        let data2 = try! Data(contentsOf: originFile)

        XCTAssertEqual(data1, data2)
    }

    func testUnzipProtected() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"), sandboxDirURL)
        config.password = "complexprotected.zip"
        try Unzip(config: config).extract()

        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/file1.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/")))
        XCTAssertTrue(
            isItemExists(
                sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt"))
        )
        XCTAssertTrue(
            isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/file1_1.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/file2.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/")))
        XCTAssertTrue(
            isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/file2_2.txt")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder3/")))
        XCTAssertTrue(isItemExists(sandboxDirURL.appendingPathComponent("folder3/file3.txt")))
    }

    func testUnzipFailsUsingWrongPassword() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"), sandboxDirURL)
        config.password = "wrongPassword"

        XCTAssertThrowsError(try Unzip(config: config).extract())
        XCTAssertFalse(
            isItemExists(
                sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt"))
        )
    }

    func testReadStructureOfComplexExistingZip() throws {
        let config = Unzip.Config(fileURL("complex", "zip"))

        let list = try Unzip(config: config).readStructure()

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

    func testExtractInMemoryExistingProtectedZip() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"))
        config.password = "complexprotected.zip"

        let fileData =
            try Unzip(config: config)
            .extractToMemory("folder1/folder1_1/folder1_1_1/file1_1_1.txt")

        let fileContent = "folder1/folder1_1/folder1_1_1/file1_1_1.txt\n"
        let expectedData = fileContent.data(using: .utf8)
        XCTAssertEqual(expectedData, fileData)
    }
}
