//
//  ViewController.swift
//  SwiftMiniZip
//
//  Created by Ihar Katkavets on 12/04/2022.
//  Copyright (c) 2022 Ihar Katkavets. All rights reserved.
//

import UIKit
import SwiftMiniZip

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let fm = FileManager.default
            let outZipFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("example.zip")
            let outUnzipContentURL = FileManager.default.temporaryDirectory.appendingPathComponent("unzip_example.jpg")
            [outZipFileURL, outUnzipContentURL].forEach {
                try? fm.removeItem(at: $0)
            }
            
            let bundle = Bundle.main
            let password = "HappyCoding!"
            let exampleImageURL = bundle.url(forResource: "example", withExtension: "jpg")!
            var zipConfig = Zip.Config([exampleImageURL], outZipFileURL)
            zipConfig.password = "HappyCoding!"
            try Zip(config: zipConfig).perform()
            print("successfully zipped to \(outZipFileURL)")
            
            var config = Unzip.Config(outZipFileURL, outUnzipContentURL)
            config.password = password
            try Unzip(config: config).perform()
            print("successfully unzipped to \(outZipFileURL)")
        }
        catch {
            print("Oh no :(")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

