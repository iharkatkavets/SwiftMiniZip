# SwiftMiniZip

The idea of that library to provide Swift wrappers around popular C [minizip](https://github.com/madler/zlib/tree/master/contrib/minizip) library

## Example

Zip operation
```swift
var config = Zip.Config()
config.srcs = [
  folder1URL, file2URL, folder3URL, file4URL
]
config.dstURL = zipFileURL
config.password = passwordStringIfNeeded
let zip = Zip(config: config)
try zip.perform()
```

Unzip operation
```swift
var config = Unzip.Config()
config.srcURL = zipFileURL
config.dstURL = destinationDirURL
config.password = passwordStringIfNeeded
let unzip = Unzip(config: config)        
try unzip.extract()
```

## Requirements

iOS 15.0, 
macOS 10.14

## Installation

In the Xcode press `File` -> `Add Packages` -> In the search field insert `https://github.com/iharkatkavets/SwiftMiniZip`. It might require to setup GitHub Account in the Xcode

## Author

Ihar Katkavets, job4ihar@gmail.com

## License

SwiftMiniZip is available under the MIT license. See the LICENSE file for more info.
