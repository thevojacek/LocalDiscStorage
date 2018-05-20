import XCTest;
@testable import LocalDiscStorage;

class LocalDiscStorageTests: XCTestCase {
    
    /*
    private let storage: LocalDiscStorage?;
    
    override init () {
        let desktopURL = "/Users/janvojacek/Desktop";
        self.storage = try LocalDiscStorage(in: desktopURL);
    }
    */
    
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


    static var allTests = [
        ("testExample", testExample),
    ]
}
