import XCTest
@testable import Language_Byte_Watch_App

class ErrorHandlingTests: XCTestCase {
    var languageManager: MockErrorLanguageManager!
    var networkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        languageManager = MockErrorLanguageManager()
        networkManager = MockNetworkManager()
    }
    
    override func tearDown() {
        languageManager = nil
        networkManager = nil
        super.tearDown()
    }
    
    func testLanguageDataLoadingFailure() {
        // Given
        languageManager.shouldFailLoading = true
        languageManager.errorToThrow = DataError.invalidFormat
        
        // When/Then
        XCTAssertThrowsError(try languageManager.loadLanguageData()) { error in
            XCTAssertEqual(error as? DataError, DataError.invalidFormat)
        }
    }
    
    func testLanguageDataLoadingSuccess() {
        // Given
        languageManager.shouldFailLoading = false
        
        // When/Then
        XCTAssertNoThrow(try languageManager.loadLanguageData())
        XCTAssertTrue(languageManager.languageDataLoaded)
    }
    
    func testMissingLanguageError() {
        // Given
        let invalidCode = "xx-XX"
        
        // When/Then
        XCTAssertThrowsError(try languageManager.getLanguagePair(sourceCode: "en", targetCode: invalidCode)) { error in
            XCTAssertEqual(error as? DataError, DataError.languageNotFound)
        }
    }
    
    func testNetworkErrorHandling() async {
        // Given
        networkManager.shouldFailWithError = true
        networkManager.errorToThrow = NetworkError.noConnection
        
        // When
        do {
            let _ = try await networkManager.fetchData(from: "test-url")
            XCTFail("Should have thrown network error")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.noConnection)
        }
    }
    
    func testNetworkTimeoutHandling() async {
        // Given
        networkManager.shouldFailWithError = true
        networkManager.errorToThrow = NetworkError.timeout
        
        // When
        do {
            let _ = try await networkManager.fetchData(from: "test-url")
            XCTFail("Should have thrown timeout error")
        } catch {
            // Then
            XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
        }
    }
    
    func testNetworkServerErrorHandling() async {
        // Given
        networkManager.shouldFailWithError = true
        networkManager.errorToThrow = NetworkError.serverError(statusCode: 500)
        
        // When
        do {
            let _ = try await networkManager.fetchData(from: "test-url")
            XCTFail("Should have thrown server error")
        } catch let NetworkError.serverError(statusCode) {
            // Then
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testDataDecodingError() {
        // Given
        let invalidJSON = "not valid json"
        
        // When/Then
        XCTAssertThrowsError(try languageManager.decodeData(invalidJSON.data(using: .utf8)!) as TestDecodable) { error in
            XCTAssertTrue(error is DecodingError, "Should throw a DecodingError")
        }
    }
    
    func testRecoveryFromTempFailure() async {
        // Given - First try will fail with timeout
        networkManager.shouldFailWithError = true
        networkManager.errorToThrow = NetworkError.timeout
        
        // When - First attempt fails
        do {
            let _ = try await networkManager.fetchData(from: "test-url")
            XCTFail("Should have thrown timeout error on first attempt")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.timeout)
        }
        
        // Then - Second attempt succeeds
        networkManager.shouldFailWithError = false
        
        do {
            let data = try await networkManager.fetchData(from: "test-url")
            XCTAssertNotNil(data, "Should successfully fetch data on retry")
        } catch {
            XCTFail("Should not throw error on retry: \(error)")
        }
    }
    
    func testGracefulDegradation() {
        // Given - Missing premium words
        languageManager.isPremiumContentMissing = true
        
        // When
        let words = languageManager.getWordPairsWithFallback()
        
        // Then - Should return basic words even if premium content is missing
        XCTAssertFalse(words.isEmpty, "Should return fallback words")
        XCTAssertEqual(words.count, languageManager.fallbackWordCount, "Should return correct number of fallback words")
    }
}

// MARK: - Mock Classes and Errors

// Simple Decodable struct for testing decoding errors
struct TestDecodable: Decodable {
    let name: String
    let value: Int
}

enum DataError: Error, Equatable {
    case invalidFormat
    case languageNotFound
    case missingData
}

enum NetworkError: Error, Equatable {
    case noConnection
    case timeout
    case serverError(statusCode: Int)
}

class MockErrorLanguageManager {
    var shouldFailLoading = false
    var errorToThrow: Error?
    var languageDataLoaded = false
    var isPremiumContentMissing = false
    var fallbackWordCount = 10
    
    func loadLanguageData() throws {
        if shouldFailLoading {
            if let error = errorToThrow {
                throw error
            } else {
                throw DataError.missingData
            }
        }
        
        languageDataLoaded = true
    }
    
    func getLanguagePair(sourceCode: String, targetCode: String) throws -> Any {
        if targetCode == "xx-XX" {
            throw DataError.languageNotFound
        }
        
        return "MockLanguagePair"
    }
    
    func decodeData<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    func getWordPairsWithFallback() -> [Any] {
        // Return fallback words when premium content is missing
        if isPremiumContentMissing {
            return Array(repeating: "FallbackWord", count: fallbackWordCount)
        }
        
        // Return normal words
        return Array(repeating: "NormalWord", count: 20)
    }
}

class MockNetworkManager {
    var shouldFailWithError = false
    var errorToThrow: Error?
    
    func fetchData(from urlString: String) async throws -> Data {
        if shouldFailWithError {
            if let error = errorToThrow {
                throw error
            } else {
                throw NetworkError.noConnection
            }
        }
        
        return "Success".data(using: .utf8)!
    }
} 