//
//  XCTestHelpers.swift
//  SwiftMiniZip_Tests
//
//  Created by Ihar Katkavets on 10/12/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Testing

@discardableResult
func fileURL(_ filename: String, _ extensions: String?) -> URL {
    let url = Bundle.module.url(forResource: filename, withExtension: extensions)!
    return url
}

@discardableResult
func createFolder(_ url: URL) throws -> URL {
    try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    return url
}

@discardableResult
func createFile(_ url: URL, _ content: String) throws -> URL {
    try content.write(to: url, atomically: true, encoding: .utf8)
    return url
}

func isItemExists(_ url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    return exists
}

func randString() -> String {
    return UUID().uuidString
}

func randDate() -> Date {
    return Date(timeIntervalSince1970: Double.random(in: 0..<Double.greatestFiniteMagnitude))
}

func randDouble() -> Double {
    return Double.random(in: 0..<Double.greatestFiniteMagnitude)
}

func makeSandboxDirectory() throws -> URL {
    let fm = FileManager.default
    var sandboxURL = fm.temporaryDirectory
    sandboxURL.appendPathComponent(randString())
    try fm.createDirectory(at: sandboxURL, withIntermediateDirectories: true)
    return sandboxURL
}

func removeSandboxDirectory(_ url: URL) throws {
    try FileManager.default.removeItem(at: url)
}

func areFilesEqual(_ file1: URL, _ file2: URL) -> Bool {
    guard let data1 = try? Data(contentsOf: file1),
        let data2 = try? Data(contentsOf: file2)
    else {
        return false
    }

    return data1 == data2
}
