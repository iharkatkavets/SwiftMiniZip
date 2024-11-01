//
//  UnzipTests.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 13/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Logging
import Testing

@testable import SwiftMiniZip

final class UnzipTests {
    let sandboxDirURL = try! makeSandboxDirectory()
    let logger = Logger(label: "UnzipTests")

    init() {
        LoggingTestObserver.initializeLogging
    }

    deinit {
        try! removeSandboxDirectory(sandboxDirURL)
    }

    @Test func testUnzipOriginFileWithoutPassword() throws {
        let config = Unzip.Config(fileURL("OriginFile.txt", "zip"), sandboxDirURL)

        try Unzip(config: config).extract()

        let unzipedFile = sandboxDirURL.appendingPathComponent("OriginFile.txt")
        let originFile = fileURL("OriginFile", "txt")

        let data1 = try! Data(contentsOf: unzipedFile)
        let data2 = try! Data(contentsOf: originFile)

        #expect(data1 == data2)
    }

    @Test func testUnzipOriginFileWithPassword() throws {
        var config = Unzip.Config(fileURL("OriginFile.txt.encrypted", "zip"), sandboxDirURL)
        config.password = "OriginFile.txt.encrypted.zip"

        try Unzip(config: config).extract()

        let unzipedFile = sandboxDirURL.appendingPathComponent("Tests/Resources/OriginFile.txt")
        let originFile = fileURL("OriginFile", "txt")

        let data1 = try! Data(contentsOf: unzipedFile)
        let data2 = try! Data(contentsOf: originFile)

        #expect(data1 == data2)
    }

    @Test func testUnzipProtected() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"), sandboxDirURL)
        config.password = "complexprotected.zip"
        try Unzip(config: config).extract()

        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder1/")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder1/file1.txt")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/")))
        #expect(
            isItemExists(
                sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt"))
        )
        #expect(
            isItemExists(sandboxDirURL.appendingPathComponent("folder1/folder1_1/file1_1.txt")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder2/")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder2/file2.txt")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/")))
        #expect(
            isItemExists(sandboxDirURL.appendingPathComponent("folder2/folder2_2/file2_2.txt")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder3/")))
        #expect(isItemExists(sandboxDirURL.appendingPathComponent("folder3/file3.txt")))
    }

    func testUnzipFailsUsingWrongPassword() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"), sandboxDirURL)
        config.password = "wrongPassword"

        #expect(throws: (any Error).self) { try Unzip(config: config).extract() }
        #expect(
            !isItemExists(
                sandboxDirURL.appendingPathComponent("folder1/folder1_1/folder1_1_1/file1_1_1.txt"))
        )
    }

    func testReadStructureOfComplexExistingZip() throws {
        let config = Unzip.Config(fileURL("complex", "zip"))

        let list = try Unzip(config: config).readStructure()

        #expect("folder1/" == list[0])
        #expect("folder1/file1.txt" == list[1])
        #expect("folder1/folder1_1/" == list[2])
        #expect("folder1/folder1_1/folder1_1_1/" == list[3])
        #expect("folder1/folder1_1/folder1_1_1/file1_1_1.txt" == list[4])
        #expect("folder1/folder1_1/file1_1.txt" == list[5])
        #expect("folder2/" == list[6])
        #expect("folder2/file2.txt" == list[7])
        #expect("folder2/folder2_2/" == list[8])
        #expect("folder2/folder2_2/file2_2.txt" == list[9])
        #expect("folder3/" == list[10])
        #expect("folder3/file3.txt" == list[11])
    }

    func testExtractInMemoryExistingProtectedZip() throws {
        var config = Unzip.Config(fileURL("complexprotected", "zip"))
        config.password = "complexprotected.zip"

        let fileData =
            try Unzip(config: config)
            .extractToMemory("folder1/folder1_1/folder1_1_1/file1_1_1.txt")

        let fileContent = "folder1/folder1_1/folder1_1_1/file1_1_1.txt\n"
        let expectedData = fileContent.data(using: .utf8)
        #expect(expectedData == fileData)
    }
}
