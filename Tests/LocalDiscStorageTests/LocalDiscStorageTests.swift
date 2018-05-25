import XCTest;
@testable import LocalDiscStorage;


class LocalDiscStorageTests: XCTestCase {

    private var storage: LocalDiscStorage?
    private var testPath: String?
    
    /// Looks up files in init directory and deletes all that are of type ".ldsData".
    ///
    /// - Parameters:
    ///   - path: Path in which to do the look up.
    private func cleanUpTestDirectory (_ path: String) {
        do {
            
            let fileManager = FileManager()
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for fileName in contents {
                let filePath = "\(path)/\(fileName)"
                
                if fileName.hasSuffix(".ldsData") && fileManager.isDeletableFile(atPath: filePath) {
                    try fileManager.removeItem(atPath: filePath)
                }
            }
        } catch {
            XCTFail("Folder could not be cleaned up.")
        }
    }
    
    override func setUp () {
        
        let fileManager = FileManager()
        self.testPath = fileManager.currentDirectoryPath
        
        do {
            self.storage = try LocalDiscStorage(in: self.testPath!)
        } catch {
            XCTFail("Test scenario failed when initializing storage.")
        }
    }
    
    override func tearDown () {
        // Clean up test working directory.
        guard let path = self.testPath else {
            return
        }
        
        self.cleanUpTestDirectory(path)
    }
    
    func testSaveAndLoadFunctionality () {
        
        let index: [String] = ["Prague"]
        let data: [String: Any] = [
            "City_Name": "Prague",
            "Citizens": 1_350_000
        ]
        
        do {
            
            guard let id: String = try self.storage?.save(identifier: nil, value: data, index: index) else {
                XCTFail("Data was not saved properly.")
                return
            }
            
            guard let item: [String: Any] = try self.storage?.load(withId: id) else {
                XCTFail("Saved data was not loaded properly.")
                return
            }
            
            let savedCity = item["City_Name"]! as? String
            let originalCity = data["City_Name"]! as? String
            XCTAssert(savedCity == originalCity, "Corrupted data in saved item.")
            
            let savedCitizens = item["Citizens"]! as? Int
            let originalCitizens = data["Citizens"]! as? Int
            XCTAssert(savedCitizens == originalCitizens, "Corrupted data in saved item.")
            
        } catch {
            XCTFail("Unexpected runtime exception during testing.")
            return
        }
    }
    
    func testSaveWithCustomIdentifierAndWithoutIndex () {
        
        let id: String = "city_brno"
        let data: [String: Any] = [
            "City_Name": "Brno",
            "Citizens": 500_000
        ]
        
        do {
            
            guard let savedId: String = try self.storage?.save(identifier: id, value: data, index: nil) else {
                XCTFail("Data was not saved properly.")
                return
            }
            
            XCTAssert(savedId == id, "Saved custom ID does not match!")
            
        } catch {
            XCTFail("Unexpected runtime exception during testing.")
            return
        }
    }
    
    func testShouldBeAbleToInitializeSecondStorageFromSameIndexFile () {
        
        let data: [String: Any] = ["number": 16_000_000]
        
        do {
            
            guard let id: String = try self.storage?.save(identifier: nil, value: data, index: nil) else {
                XCTFail("Data was not saved properly.")
                return
            }
            
            let localStorage: LocalDiscStorage = try LocalDiscStorage(in: self.testPath!)
            
            guard let item = try localStorage.load(withId: id) else {
                XCTFail("Data could not be found.")
                return
            }
            
            XCTAssert(item["number"] as? Int == data["number"] as? Int, "Saved data does not match!")
            
        } catch {
            XCTFail("Unexpected runtime exception during testing.")
            return
        }
    }

    func testShouldReturnNilWhenTryingToLoadNonExistingItem () {
        
        do {
            
            let item: [String:Any]? = try self.storage?.load(withId: "some_non_existing_id")
            
            XCTAssert(item == nil, "Item must be nil.")
            
        } catch {
            XCTFail("Unexpected runtime exception during testing.")
            return
        }
    }
    
    func testShouldReturnNilWhenFindingByNonExistingIndex () {
        
        do {
            
            let items: [[String:Any]]? = try self.storage?.find(withIndexes: ["non", "existing", "index"])
            
            XCTAssert(items == nil, "Items must be nil.")
            
        } catch {
            XCTFail("Unexpected runtime exception during testing.")
            return
        }
    }

    static var allTests = [
        ("testSaveAndLoadFunctionality", testSaveAndLoadFunctionality),
        ("testSaveWithCustomIdentifier", testSaveWithCustomIdentifierAndWithoutIndex),
        ("testShouldBeAbleToInitializeSecondStorageFromSameIndexFile", testShouldBeAbleToInitializeSecondStorageFromSameIndexFile),
        ("testShouldReturnNilWhenTryingToLoadNonExistingItem", testShouldReturnNilWhenTryingToLoadNonExistingItem),
        ("testShouldReturnNilWhenFindingByNonExistingIndex", testShouldReturnNilWhenFindingByNonExistingIndex)
    ]
}
