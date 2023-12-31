//
//  Zipper.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 10/12/2022.
//

import Foundation
import os.log
import cminizip

public enum CompressionLevel: Int32 {
    case NoCompression
    case BestSpeed
    case Default
    case Best

    var zcompression: Int32 {
        switch self {
        case .NoCompression: return Z_NO_COMPRESSION
        case .BestSpeed: return Z_BEST_SPEED
        case .Default: return Z_DEFAULT_COMPRESSION
        case .Best: return Z_BEST_COMPRESSION
        }
    }
}

public class Zip {
    public struct Config {
        public var srcs = [URL]()
        public var dstURL: URL?
        public var password: String?
        public var compressionLevel: CompressionLevel = .Default
        public init() {}
    }
    
    let config: Config
    lazy var fm: FileManager = FileManager.default
    let zlibDeflateChunkSize = 16384
    let log = OSLog(subsystem: "Zip", category: "Zip")
    
    public init(config: Config) {
        self.config = config
    }
    
    public func perform() throws {
        try validateConfiguration()
        try validateDstLocation()
        
        let file = try createZipFile()
        try writeFilesTo(file)
        try closeZipFile(file)
    }
    
    func validateConfiguration() throws {
        guard config.srcs.count > 0 else { throw ConfigurationError() }
        guard config.dstURL != nil else { throw ConfigurationError() }
    }
    
    private func validateDstLocation() throws {
        if fm.fileExists(atPath: config.dstURL!.absoluteString) {
            throw FileExists(url: config.dstURL!)
        }
    }
    
    private func createZipFile() throws -> zipFile {
        guard let file = zipOpen(config.dstURL!.path, APPEND_STATUS_CREATE) else {
            throw MiniZipError()
        }
        os_log(.debug, log: log, "create zip file at %@", config.dstURL!.path)
        return file
    }
    
    private func writeFilesTo(_ zf: zipFile) throws {
        for item in generateZipItems(from: config.srcs) {
            guard let rd = fopen(item.path, "r") else { throw MiniZipError() }
            
            os_log(.debug, log: log, "zip file %@", item.path)
            var zi: zip_fileinfo = makeZipFileInfoForFile(item.path)
            
            if let password = config.password {
                let r = zipOpenNewFileInZip3(zf, item.fileName, &zi,
                                             nil, 0, nil, 0,
                                             nil,Z_DEFLATED,
                                             config.compressionLevel.zcompression, 0,
                                             -MAX_WBITS, DEF_MEM_LEVEL,
                                             Z_DEFAULT_STRATEGY, password, 0)
                guard r == Z_OK else { throw MiniZipError() }
            }
            else {
                let r = zipOpenNewFileInZip3(zf, item.fileName, &zi,
                                             nil, 0, nil,
                                             0, nil, Z_DEFLATED,
                                             config.compressionLevel.zcompression,
                                             0, -MAX_WBITS,
                                             DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                             nil, 0)
                guard r == Z_OK else { continue }
            }
            
            guard let readBuffer = malloc(zlibDeflateChunkSize) else { throw MiniZipError() }
            
            var length: Int = 0
            while (feof(rd) == 0) {
                length = fread(readBuffer, 1, zlibDeflateChunkSize, rd)
                zipWriteInFileInZip(zf, readBuffer, UInt32(length))
            }
            
            fclose(rd)
            zipCloseFileInZip(zf)
        }
    }
    
    private func makeDefaultZipFileInfo() -> zip_fileinfo {
        return zip_fileinfo(tmz_date: tm_zip(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0), dosDate: 0, internal_fa: 0, external_fa: 0)
    }
    
    private func makeZipFileInfoForFile(_ path: String) -> zip_fileinfo {
        var zi: zip_fileinfo = makeDefaultZipFileInfo()
        do {
            let attrs = try fm.attributesOfItem(atPath: path)
            if let fileDate = attrs[FileAttributeKey.modificationDate] as? Date {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fileDate)
                zi.tmz_date.tm_sec = Int32(UInt32(components.second!))
                zi.tmz_date.tm_min = Int32(components.minute!)
                zi.tmz_date.tm_hour = Int32(components.hour!)
                zi.tmz_date.tm_mday = Int32(components.day!)
                zi.tmz_date.tm_mon = Int32(components.month!) - 1
                zi.tmz_date.tm_year = Int32(components.year!)
            }
        }
        catch { }
        return zi
    }
    
    private func closeZipFile(_ zf: zipFile) throws {
       zipClose(zf, nil)
    }
    
    func generateZipItems(from urls: [URL]) -> [ZipItem] {
        var resultList = [ZipItem]()
        for url in urls {
            if isDirectory(url.path) {
                resultList.append(contentsOf: listDirectoryZipItems(url))
            }
            else {
                resultList.append(ZipItem(filePathURL: url, fileName: url.lastPathComponent))
            }
        }
        return resultList
    }
    
    private func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        _ = fm.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    func listDirectoryZipItems(_ directory: URL) -> [ZipItem] {
        var resultList = [ZipItem]()
        let directoryPath = directory.path
        guard let enumerator = fm.enumerator(atPath: directoryPath) else { return resultList }
        while let filePathComponent = enumerator.nextObject() as? String {
            let nextItemURL = directory.appendingPathComponent(filePathComponent)
            if isDirectory(nextItemURL.path) { continue }
            
            let directoryName = directory.lastPathComponent
            let fileName = (directoryName as NSString).appendingPathComponent(filePathComponent)
            resultList.append(ZipItem(filePathURL: nextItemURL, fileName: fileName))
        }
        return resultList
    }
}
