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
                "Jan": 3780
            ];
            
            try storage.save(identifier: "AK09W34", value: dataToStore);
            
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
