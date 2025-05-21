import XCTest
@testable import Language_Byte_Watch_App

class DataMigrationTests: XCTestCase {
    var migrationManager: MockMigrationManager!
    
    override func setUp() {
        super.setUp()
        migrationManager = MockMigrationManager()
        
        // Clear any previous migration state
        UserDefaults.standard.removeObject(forKey: "app_version")
        UserDefaults.standard.removeObject(forKey: "migration_v1_to_v2_completed")
        UserDefaults.standard.removeObject(forKey: "migration_v2_to_v3_completed")
    }
    
    override func tearDown() {
        migrationManager = nil
        super.tearDown()
    }
    
    func testFirstTimeAppLaunch() {
        // When app launches for the first time, no migration needed
        let result = migrationManager.checkAndPerformMigrations()
        
        XCTAssertTrue(result, "First time migration should succeed")
        XCTAssertFalse(migrationManager.v1ToV2MigrationPerformed, "V1 to V2 migration should not be performed on first launch")
        XCTAssertFalse(migrationManager.v2ToV3MigrationPerformed, "V2 to V3 migration should not be performed on first launch")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_version"), "3.0", "App version should be set correctly")
    }
    
    func testMigrationFromV1ToV3() {
        // Set up: Simulate app was previously on version 1.0
        UserDefaults.standard.set("1.0", forKey: "app_version")
        
        // Set up old format word data
        let oldWordPairs = [
            ["foreignWord": "hola", "translation": "hello", "category": "greetings"],
            ["foreignWord": "adiós", "translation": "goodbye", "category": "greetings"]
        ]
        
        migrationManager.oldWordPairs = oldWordPairs
        
        // Perform migration
        let result = migrationManager.checkAndPerformMigrations()
        
        // Verify migrations performed
        XCTAssertTrue(result, "Migration should succeed")
        XCTAssertTrue(migrationManager.v1ToV2MigrationPerformed, "V1 to V2 migration should be performed")
        XCTAssertTrue(migrationManager.v2ToV3MigrationPerformed, "V2 to V3 migration should be performed")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_version"), "3.0", "App version should be updated")
        
        // Verify data transformed correctly
        let migratedWordPairs = migrationManager.migratedWordPairs
        XCTAssertEqual(migratedWordPairs.count, 2, "Should have 2 migrated word pairs")
        
        XCTAssertEqual(migratedWordPairs[0].sourceWord, "hola", "Source word should be migrated correctly")
        XCTAssertEqual(migratedWordPairs[0].targetWord, "hello", "Target word should be migrated correctly")
        XCTAssertEqual(migratedWordPairs[0].category, "greetings", "Category should be migrated correctly")
        
        XCTAssertNotNil(migratedWordPairs[0].id, "ID should be generated during migration")
    }
    
    func testMigrationFromV2ToV3() {
        // Set up: Simulate app was previously on version 2.0
        UserDefaults.standard.set("2.0", forKey: "app_version")
        UserDefaults.standard.set(true, forKey: "migration_v1_to_v2_completed")
        
        // Set up V2 format word data (already has sourceWord and targetWord but no ID)
        let v2WordPairs = [
            ["sourceWord": "hola", "targetWord": "hello", "category": "greetings"],
            ["sourceWord": "adiós", "targetWord": "goodbye", "category": "greetings"]
        ]
        
        migrationManager.v2WordPairs = v2WordPairs
        
        // Perform migration
        let result = migrationManager.checkAndPerformMigrations()
        
        // Verify migrations performed
        XCTAssertTrue(result, "Migration should succeed")
        XCTAssertFalse(migrationManager.v1ToV2MigrationPerformed, "V1 to V2 migration should not be performed again")
        XCTAssertTrue(migrationManager.v2ToV3MigrationPerformed, "V2 to V3 migration should be performed")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_version"), "3.0", "App version should be updated")
        
        // Verify data transformed correctly
        let migratedWordPairs = migrationManager.migratedWordPairs
        XCTAssertEqual(migratedWordPairs.count, 2, "Should have 2 migrated word pairs")
        
        // In V2 to V3 migration, each word pair should now have an ID
        XCTAssertNotNil(migratedWordPairs[0].id, "ID should be generated during migration")
        XCTAssertNotNil(migratedWordPairs[1].id, "ID should be generated during migration")
    }
    
    func testMigrationAlreadyCompleted() {
        // Set up: Simulate app was already on version 3.0 with all migrations completed
        UserDefaults.standard.set("3.0", forKey: "app_version")
        UserDefaults.standard.set(true, forKey: "migration_v1_to_v2_completed")
        UserDefaults.standard.set(true, forKey: "migration_v2_to_v3_completed")
        
        // Perform migration check
        let result = migrationManager.checkAndPerformMigrations()
        
        // Verify no migrations performed
        XCTAssertTrue(result, "Migration check should succeed")
        XCTAssertFalse(migrationManager.v1ToV2MigrationPerformed, "V1 to V2 migration should not be performed again")
        XCTAssertFalse(migrationManager.v2ToV3MigrationPerformed, "V2 to V3 migration should not be performed again")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_version"), "3.0", "App version should remain the same")
    }
    
    func testMigrationV1ToV2Failure() {
        // Set up: Simulate app was previously on version 1.0
        UserDefaults.standard.set("1.0", forKey: "app_version")
        
        // Configure migration to fail
        migrationManager.shouldFailV1ToV2 = true
        
        // Perform migration
        let result = migrationManager.checkAndPerformMigrations()
        
        // Verify migration failed
        XCTAssertFalse(result, "Migration should fail")
        XCTAssertFalse(migrationManager.v1ToV2MigrationPerformed, "V1 to V2 migration should not complete")
        XCTAssertFalse(migrationManager.v2ToV3MigrationPerformed, "V2 to V3 migration should not be attempted")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "app_version"), "1.0", "App version should not be updated")
    }
    
    func testV1ToV2MigrationFields() {
        // Test that v1 to v2 migration correctly renames fields
        let oldFormat = ["foreignWord": "hola", "translation": "hello", "category": "greetings"]
        
        let newFormat = migrationManager.migrateV1WordPairToV2(oldFormat)
        
        XCTAssertEqual(newFormat["sourceWord"], "hola", "Should convert foreignWord to sourceWord")
        XCTAssertEqual(newFormat["targetWord"], "hello", "Should convert translation to targetWord")
        XCTAssertEqual(newFormat["category"], "greetings", "Should preserve category")
        XCTAssertNil(newFormat["foreignWord"], "Should remove old foreignWord field")
        XCTAssertNil(newFormat["translation"], "Should remove old translation field")
    }
    
    func testV2ToV3MigrationFields() {
        // Test that v2 to v3 migration correctly adds IDs
        let v2Format = ["sourceWord": "hola", "targetWord": "hello", "category": "greetings"]
        
        let v3Format = migrationManager.migrateV2WordPairToV3(v2Format)
        
        XCTAssertEqual(v3Format["sourceWord"], "hola", "Should preserve sourceWord")
        XCTAssertEqual(v3Format["targetWord"], "hello", "Should preserve targetWord")
        XCTAssertEqual(v3Format["category"], "greetings", "Should preserve category")
        XCTAssertNotNil(v3Format["id"], "Should add ID field")
    }
}

// MARK: - Mock Classes

class MockMigrationManager {
    var oldWordPairs: [[String: String]] = []
    var v2WordPairs: [[String: String]] = []
    var migratedWordPairs: [MockWordPair] = []
    var v1ToV2MigrationPerformed = false
    var v2ToV3MigrationPerformed = false
    var shouldFailV1ToV2 = false
    
    struct MockWordPair {
        var id: String
        var sourceWord: String
        var targetWord: String
        var category: String
    }
    
    func checkAndPerformMigrations() -> Bool {
        // Check current app version
        let currentVersion = UserDefaults.standard.string(forKey: "app_version") ?? "0.0"
        
        // Perform migrations based on version
        if currentVersion == "0.0" {
            // First launch, just set version
            UserDefaults.standard.set("3.0", forKey: "app_version")
            return true
        }
        
        // V1 to V2 migration (foreignWord/translation → sourceWord/targetWord)
        if currentVersion == "1.0" {
            let v1ToV2Success = migrateFromV1ToV2()
            if !v1ToV2Success {
                return false
            }
            
            // Update version after successful migration
            UserDefaults.standard.set("2.0", forKey: "app_version")
        }
        
        // V2 to V3 migration (add unique IDs)
        if currentVersion == "1.0" || currentVersion == "2.0" {
            let v2ToV3Success = migrateFromV2ToV3()
            if !v2ToV3Success {
                return false
            }
            
            // Update version after successful migration
            UserDefaults.standard.set("3.0", forKey: "app_version")
        }
        
        return true
    }
    
    func migrateFromV1ToV2() -> Bool {
        if shouldFailV1ToV2 {
            return false
        }
        
        // Check if migration already done
        if UserDefaults.standard.bool(forKey: "migration_v1_to_v2_completed") {
            return true
        }
        
        // Perform migration
        var migratedData: [[String: String]] = []
        
        for oldPair in oldWordPairs {
            let newPair = migrateV1WordPairToV2(oldPair)
            migratedData.append(newPair)
        }
        
        v2WordPairs = migratedData
        v1ToV2MigrationPerformed = true
        
        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: "migration_v1_to_v2_completed")
        
        return true
    }
    
    func migrateFromV2ToV3() -> Bool {
        // Check if migration already done
        if UserDefaults.standard.bool(forKey: "migration_v2_to_v3_completed") {
            return true
        }
        
        // Perform migration
        var migratedObjects: [MockWordPair] = []
        
        for v2Pair in v2WordPairs {
            let v3Pair = migrateV2WordPairToV3(v2Pair)
            
            // Create proper model object
            if let sourceWord = v3Pair["sourceWord"],
               let targetWord = v3Pair["targetWord"],
               let category = v3Pair["category"],
               let id = v3Pair["id"] {
                
                let wordPair = MockWordPair(
                    id: id,
                    sourceWord: sourceWord,
                    targetWord: targetWord,
                    category: category
                )
                
                migratedObjects.append(wordPair)
            }
        }
        
        migratedWordPairs = migratedObjects
        v2ToV3MigrationPerformed = true
        
        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: "migration_v2_to_v3_completed")
        
        return true
    }
    
    func migrateV1WordPairToV2(_ v1Pair: [String: String]) -> [String: String] {
        var v2Pair = [String: String]()
        
        // Convert foreignWord to sourceWord
        if let foreignWord = v1Pair["foreignWord"] {
            v2Pair["sourceWord"] = foreignWord
        }
        
        // Convert translation to targetWord
        if let translation = v1Pair["translation"] {
            v2Pair["targetWord"] = translation
        }
        
        // Copy category
        if let category = v1Pair["category"] {
            v2Pair["category"] = category
        }
        
        return v2Pair
    }
    
    func migrateV2WordPairToV3(_ v2Pair: [String: String]) -> [String: String] {
        var v3Pair = v2Pair
        
        // Add unique ID
        v3Pair["id"] = UUID().uuidString
        
        return v3Pair
    }
} 