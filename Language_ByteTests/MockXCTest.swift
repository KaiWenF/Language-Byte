import Foundation

// Mock XCTest for watchOS testing since XCTest has limitations on watchOS
public class XCTestCase {
    public init() {}
    
    public func setUp() {}
    public func tearDown() {}
    
    public func XCTFail(_ message: String, file: StaticString = #file, line: UInt = #line) {
        print("❌ Test failed: \(message)")
    }
    
    public func XCTAssertEqual<T: Equatable>(_ expression1: T, _ expression2: T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        if expression1 != expression2 {
            XCTFail("\(expression1) is not equal to \(expression2). \(message)")
        }
    }
    
    public func XCTAssertEqual<T: Equatable>(_ expression1: T, _ expression2: T, accuracy: T, _ message: String = "", file: StaticString = #file, line: UInt = #line) where T: FloatingPoint {
        if abs(expression1 - expression2) > accuracy {
            XCTFail("\(expression1) is not equal to \(expression2) within \(accuracy). \(message)")
        }
    }
    
    public func XCTAssertTrue(_ expression: Bool, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        if !expression {
            XCTFail("Expression is not true. \(message)")
        }
    }
    
    public func XCTAssertFalse(_ expression: Bool, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        if expression {
            XCTFail("Expression is not false. \(message)")
        }
    }
    
    public func XCTAssertNil(_ expression: Any?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        if expression != nil {
            XCTFail("Expression is not nil. \(message)")
        }
    }
    
    public func XCTAssertNotNil(_ expression: Any?, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        if expression == nil {
            XCTFail("Expression is nil. \(message)")
        }
    }
    
    public func XCTAssertNoThrow<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try expression()
        } catch {
            XCTFail("Threw error: \(error). \(message)")
        }
    }
    
    public func XCTAssertThrowsError<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ errorHandler: (Error) -> Void = { _ in }) {
        do {
            _ = try expression()
            XCTFail("Did not throw error. \(message)")
        } catch {
            errorHandler(error)
        }
    }
    
    public func measure(_ block: () -> Void) {
        let start = Date()
        block()
        let timeElapsed = Date().timeIntervalSince(start)
        print("⏱ Measured execution time: \(timeElapsed) seconds")
    }
    
    public func measureMetrics(_ metrics: [String], automaticallyStartMeasuring: Bool, block: () -> Void) {
        if automaticallyStartMeasuring {
            measure(block)
        } else {
            block()
        }
    }
    
    public func startMeasuring() {
        // Start measurement point
    }
    
    public func stopMeasuring() {
        // Stop measurement point
    }
} 