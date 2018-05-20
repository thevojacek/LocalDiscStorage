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
    
    /*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        // let fileManager = FileManager();
        
        do {
            
            let desktopURL = "/Users/janvojacek/Desktop";
            
            // let storage = try LocalDiskStorage(in: URL(fileURLWithPath: fileManager.currentDirectoryPath));
            let storage = try LocalDiscStorage(in: desktopURL);
            let dataToStore: [String: Int] = [
                "Helen": 1289,
                "Jan": 3780,
                "Leet": 1337
            ];
            let index = ["Helen", "Jan", "Leet"];
            
            _ = try storage.save(identifier: "AK09W34", value: dataToStore, index: index);
            _ = try storage.save(identifier: "CK19E37", value: ["mobilePhone": "iPhone 7 Plus, JetBlack, 128GB"], index: index);
            _ = try storage.save(identifier: "CE12E37", value: ["notebook": "MacBook Pro 2016, 13inch"], index: nil);
            _ = try storage.save(identifier: nil, value: ["address": "Boleslavská 1776/2"], index: ["address"])
            
            let item = try storage.load(withId: "CK19E37");
            
            print(item!);
            print(storage.path);
            
            // Find method -> todo: use a result!
            let items = try storage.find(withIndexes: ["Jan"]);
            
            print(items?.count ?? 0);
            
        } catch {
            print(error.localizedDescription);
        }
        
        //XCTAssertEqual(LocalDiskStorage().text, "Hello, World!")
    }
    */

    static var allTests = [
        ("testSaveAndLoadFunctionality", testSaveAndLoadFunctionality)
        // ("testExample", testExample),
    ]
}
