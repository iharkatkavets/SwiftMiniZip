import Logging
import Testing

class LoggingTestObserver {
    static let initializeLogging: Void = {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = .error
            return handler
        }
    }()
}
