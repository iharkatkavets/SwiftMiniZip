//
//  Unzipper.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 10/12/2022.
//

import Foundation
import os.log
import cminizip

public typealias Path = String

public class Unzip {
    public struct Config {
        public var srcURL: URL?
        public var dstURL: URL?
        public var password: String?
        public init() {}
    }
    
    let config: Config
    lazy var fm: FileManager = FileManager.default
    let log = OSLog(subsystem: "Unzip", category: "Unzip")
    
    public init(config: Config) {
        self.config = config
    }
    
    public func extract() throws {
        try validateSrcConfiguration()
        try validateDstConfiguration()
        
        let file = try createUnzipFile()
        try extractAll(file)
        closeUnzipFile(file)
    }
    
    public func readStructure() throws -> [Path] {
        try validateSrcConfiguration()
        
        let file = try createUnzipFile()
        let list = try readStructure(file)
        closeUnzipFile(file)
        return list
    }
    
    private func validateDstConfiguration() throws {
        guard config.dstURL != nil else { throw ConfigurationError() }
    }
    
    private func validateSrcConfiguration() throws {
        guard config.srcURL != nil else { throw ConfigurationError() }
        
        if fm.fileExists(atPath: config.srcURL!.absoluteString) {
            throw FileNotExists(url: config.srcURL!)
        }
    }
    
    private func createUnzipFile() throws -> unzFile {
        guard let file = unzOpen64(config.srcURL!.path) else {
            throw MiniZipError()
        }
        return file
    }
    
    var passwordIfProvided: [CChar]? {
        return config.password?.cString(using: String.Encoding.ascii)
    }
    
    private func extractAll(_ file: unzFile) throws {
        do {
            var status: Int32 = unzGoToFirstFile(file)
            while (status == UNZ_OK && status != UNZ_END_OF_LIST_OF_FILE) {
                try openCurrentFile(file)
                let filePath = try extractPath(file)
                let fullPath = makeFullPath(filePath)
                try createIntermediateDirectories(fullPath)
                let isDirectory = isStringEndsToSlash(filePath)
                
                if !isDirectory {
                    try extractFile(file, fullPath)
                }
                
                closeCurrentFile(file)
                status = unzGoToNextFile(file)
            }
        }
        catch {
            closeCurrentFile(file)
            throw error
        }
    }
    
    private func readStructure(_ file: unzFile) throws -> [Path] {
        do {
            var status: Int32 = unzGoToFirstFile(file)
            var list = [String]()
            while (status == UNZ_OK && status != UNZ_END_OF_LIST_OF_FILE) {
                try openCurrentFile(file)
                let filePath = try extractPath(file)
                list.append(filePath)
                closeCurrentFile(file)
                status = unzGoToNextFile(file)
            }
            return list
        }
        catch {
            closeCurrentFile(file)
            throw error
        }
    }
    
    private func setFilePermissions(_ path: String, _ ufi: unz_file_info64) {
        if ufi.external_fa != 0 {
            let permissions = (ufi.external_fa >> 16) & 0x1FF
            if permissions >= 0o400 && permissions <= 0o777 {
                do {
                    try fm.setAttributes([.posixPermissions : permissions], ofItemAtPath: path)
                } catch {
                    os_log(.error, log: log, "Failed to set permissions to file at %@, error: %@ ", path, error.localizedDescription)
                }
            }
        }
    }
    
    private func openCurrentFile(_ file: unzFile) throws {
        var status: Int32 = 0
        if let password = passwordIfProvided {
            status = unzOpenCurrentFilePassword(file, password)
        }
        else {
            status = unzOpenCurrentFile(file);
        }
        guard status == UNZ_OK else { throw MiniUnzipError() }
        
    }
    
    private func extractFileInfo(_ file: unzFile) throws -> unz_file_info64 {
        var ufi = unz_file_info64()
        memset(&ufi, 0, MemoryLayout<unz_file_info>.size)
        let status: Int32 = unzGetCurrentFileInfo64(file, &ufi, nil, 0, nil, 0, nil, 0)
        guard status == UNZ_OK else {
            unzCloseCurrentFile(file)
            throw MiniUnzipError()
        }
        return ufi
    }
    
    private func extractPath(_ file: unzFile) throws -> String {
        var ufi = try extractFileInfo(file)
        
        let fileNameBufferSize = Int(ufi.size_filename) + 1
        let fileNameBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: fileNameBufferSize)
        unzGetCurrentFileInfo64(file, &ufi, fileNameBuffer, UInt(fileNameBufferSize), nil, 0, nil, 0)
        fileNameBuffer[Int(ufi.size_filename)] = 0
        let filePath = String(cString: fileNameBuffer)
        fileNameBuffer.deallocate()
        
        guard filePath.count > 0 else {
            unzCloseCurrentFile(file)
            throw MiniUnzipError()
        }
        
        return filePath
    }
    
    private func isStringEndsToSlash(_ maybeDir: String) -> Bool {
        return maybeDir.hasSuffix("/") || maybeDir.hasSuffix("\\")
    }
    
    private func replaceBackslashesToForward(_ path: String) -> String {
        let corrected = path.replacingOccurrences(of: "\\", with: "/")
        return corrected
    }
    
    private func closeUnzipFile(_ uz: unzFile) {
        unzClose(uz)
    }
    
    private func makeFullPath(_ relativePath: String) -> String {
        let correctedPath = replaceBackslashesToForward(relativePath)
        let fullPath = config.dstURL!.appendingPathComponent(correctedPath).path
        return fullPath
    }
    
    private func createIntermediateDirectories(_ fullPath: String) throws {
        let isDirectory = isStringEndsToSlash(fullPath)
        let creationDate = Date()
        let directoryAttributes: [FileAttributeKey: Any]? = [.creationDate : creationDate,
                                                             .modificationDate : creationDate]
        do {
            if isDirectory {
                try fm.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
                os_log(.debug, log: log, "create directory %@", fullPath)
            }
            else {
                let parentDirectory = (fullPath as NSString).deletingLastPathComponent
                try fm.createDirectory(atPath: parentDirectory, withIntermediateDirectories: true, attributes: directoryAttributes)
                os_log(.debug, log: log, "create directory %@", parentDirectory)
            }
        }
        catch {
            throw MiniUnzipError()
        }
    }
    
    private func extractFile(_ file: unzFile, _ fullPath: String) throws {
        var writeBytes: UInt64 = 0
        let filePointer: UnsafeMutablePointer<FILE>? = fopen(fullPath, "wb")
        let bufferSize: UInt32 = 4096
        var readBytes: Int32 = 0
        var buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))
        
        repeat {
            readBytes = unzReadCurrentFile(file, &buffer, bufferSize)
            if readBytes > 0 {
                guard fwrite(buffer, Int(readBytes), 1, filePointer) != readBytes else {
                    throw MiniUnzipError()
                }
                writeBytes += UInt64(readBytes)
            }
        }
        while ((filePointer != nil) && (readBytes > 0))
                
        let crc_ret = unzCloseCurrentFile(file)
        if crc_ret == UNZ_CRCERROR {
            throw PasswordError()
        }
        
        let ufi = try extractFileInfo(file)
        guard writeBytes == ufi.uncompressed_size else {
            throw MiniUnzipError()
        }
        
        setFilePermissions(fullPath, ufi)
    }
    
    private func closeCurrentFile(_ file: unzFile) {
        unzCloseCurrentFile(file)
    }
    
    public func extract(_ list: [String]) throws {
        try validateDstConfiguration()
        try validateSrcConfiguration()
        
        let file = try createUnzipFile()
        for i in 0..<list.count {
            do {
                let path = list[i].cString(using: .ascii)
                guard unzLocateFile(file, path, 1) == UNZ_OK else {
                    throw MiniUnzipError()
                }
                try openCurrentFile(file)
                let filePath = try extractPath(file)
                let fullPath = makeFullPath(filePath)
                try createIntermediateDirectories(fullPath)
                let isDirectory = isStringEndsToSlash(filePath)
                
                if !isDirectory {
                    try extractFile(file, fullPath)
                }
                
                closeCurrentFile(file)
            }
            catch {
                closeCurrentFile(file)
                throw error
            }
        }
        closeUnzipFile(file)
    }
    
    public func extractToMemory(_ path: String) throws -> Data {
        try validateSrcConfiguration()
        
        let bufferSize: UInt32 = 4096
        var outData = Data(capacity: Int(bufferSize))
        let file = try createUnzipFile()
        do {
            let path = path.cString(using: .ascii)
            guard unzLocateFile(file, path, 1) == UNZ_OK else {
                throw MiniUnzipError()
            }
            try openCurrentFile(file)
            let filePath = try extractPath(file)
            let isDirectory = isStringEndsToSlash(filePath)
            
            if !isDirectory {
                var writeBytes: UInt64 = 0
                var readBytes: Int32 = 0
                var buffer = Array<CUnsignedChar>(repeating: 0, count: Int(bufferSize))
                
                repeat {
                    readBytes = unzReadCurrentFile(file, &buffer, bufferSize)
                    if readBytes > 0 {
                        outData.append(buffer, count: Int(readBytes))
                        writeBytes += UInt64(readBytes)
                    }
                }
                while ((readBytes > 0))
                        
                let crc_ret = unzCloseCurrentFile(file)
                if crc_ret == UNZ_CRCERROR {
                    throw PasswordError()
                }
            }
            closeCurrentFile(file)
        }
        catch {
            closeCurrentFile(file)
            throw error
        }
        closeUnzipFile(file)
        return outData
    }
}
