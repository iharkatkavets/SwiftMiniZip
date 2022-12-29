//
//  Errors.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 10/12/2022.
//

import Foundation

public struct ConfigurationError: Error { }

public struct FileExists: Error {
    let url: URL
}

public struct FileNotExists: Error {
    let url: URL
}

public struct MiniZipError: Error { }
public struct MiniUnzipError: Error { }
public struct PasswordError: Error { }
