import Foundation;

public class LocalDiskStorage {
    
    private let initPath: String;
    private let fileSizeLimit: Int;
    
    private let indexHandler: IndexFileHandler;

    public var path: String {
        get { return self.initPath; }
    }
    
    convenience init (in path: String) throws {
        try self.init(in: path, withFileSizeLimit: 16_000_000);
    }
    
    init (in path: String, withFileSizeLimit fileSizeLimit: Int) throws {
        self.initPath = path;
        self.fileSizeLimit = fileSizeLimit;
        self.indexHandler = try IndexFileHandler(path: path); // todo: translate exceptions
        
        // todo: option -> cipher it?
    }
    
    public func save (identifier: String, value: [String: Any]) throws {
        // todo: implement
        
        /*let jsonData: Data = try JSONSerialization.data(withJSONObject: value);
        var bytes: String = "";
        
        jsonData.forEach { (byte) in
            bytes += "\(byte) ";
        }*/

        let entity: StorageValue = StorageValue(identifier: identifier, storeValue: value);
        
        let json = """
            {
                "identifier": "id1337",
                "storeValue": { "one": 10, "two": 20 }
            }
        """.data(using: .utf8)!;
        
        let m = try JSONDecoder().decode(StorageValue.self, from: json);
        
        print(m.storeValue);
        print(entity.storeValue);
        
        // create entity for saving
        // pick a file -> file handler
        // file handler class for file saving -> file handler
        // create an index
        
        //print("Saving \(entity.identifier).");
    }
    
}





