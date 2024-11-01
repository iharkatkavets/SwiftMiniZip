import Logging
import XCTest

class LoggingTestObserver: NSObject, XCTestObservation {
    static let initializeLogging: Void = {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .error
            return handler
        }
    }()

    override init() {
        super.init()
        _ = LoggingTestObserver.initializeLogging
    }
}
