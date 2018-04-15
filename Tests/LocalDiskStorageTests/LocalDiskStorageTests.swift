import XCTest;
@testable import LocalDiskStorage;

class LocalDiskStorageTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        // let fileManager = FileManager();
        
        do {
            
            let desktopURL = "/Users/janvojacek/Desktop";
            
            // let storage = try LocalDiskStorage(in: URL(fileURLWithPath: fileManager.currentDirectoryPath));
            let storage = try LocalDiskStorage(in: desktopURL);
            let dataToStore: [String: Int] = [
                "Helen": 1289,
                "Jan": 3780,
                "Leet": 1337
            ];
            let index = ["Helen", "Jan", "Leet"];
            
            try storage.save(identifier: "AK09W34", value: dataToStore, index: index);
            try storage.save(identifier: "CK19E37", value: ["mobilePhone": "iPhone 7 Plus, JetBlack, 128GB"], index: nil);
            try storage.save(identifier: "CE12E37", value: ["notebook": "MacBook Pro 2016, 13inch"], index: nil);
            
            print(storage.path);
            
        } catch {
            print(error.localizedDescription);
        }
        
        //XCTAssertEqual(LocalDiskStorage().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
