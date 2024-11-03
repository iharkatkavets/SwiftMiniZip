# SwiftMiniZip

This is a Swift library wrapper around the popular C [minizip](https://github.com/madler/zlib) library. It provides a lightweight Swift API for creating `zip` archives, extracting them, listing the files contained in an archive without the need to extract the entire archive, and extracting specific files. It also supports encrypted (password-protected) archives and works in both Linux and macOS environments.


# Getting started

If you’re integrating the library into an Xcode project, just search for the string in the Xcode Package Manager:
```bash
https://github.com/iharkatkavets/SwiftMiniZip
```
If you use `Package.swift` as the source of truth in your project, then declare the dependency
```swift
.package(url: "https://github.com/iharkatkavets/SwiftMiniZip.git", from: "1.0.5"),
```
and add `SwiftMiniZip` as a dependency to your application/library target
```swift
.executableTarget(
  name: "MyApp",
  dependencies: [
    .product(name: "SwiftMiniZip", package: "SwiftMiniZip"),
  ]
)
```

# Example of Zip/Unzip Operations
```swift
import SwiftMiniZip

let fm = FileManager.default
let outZipFileURL = fm.temporaryDirectory.appendingPathComponent("example.zip")
let outUnzipContentURL = fm.temporaryDirectory.appendingPathComponent("unzip_example.jpg")
            
let bundle = Bundle.main
let password = "HappyCoding!"
let originImageURL = bundle.url(forResource: "example", withExtension: "jpg")!
var zipConfig = Zip.Config([originImageURL], outZipFileURL)
zipConfig.password = password
try Zip(config: zipConfig).perform()
            
var config = Unzip.Config(outZipFileURL, outUnzipContentURL)
config.password = password
try Unzip(config: config).perform()
```

# Example of Listing the Files Inside the Archive
```swift
import SwiftMiniZip

let filesInside = try Unzip(config: .init(outZipFileURL)).readStructure()
```

# Example of Extracting the concrete files from the Archive
```swift
import SwiftMiniZip

let data = try Unzip(config: config).extractToMemory("example.jpg")
```


## Requirements
Swift 5.10
Linux/macOS

## Author
Ihar Katkavets, job4ihar@gmail.com

## License
SwiftMiniZip is available under the MIT license. See the LICENSE file for more info.
