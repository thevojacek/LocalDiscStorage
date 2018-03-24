import Foundation;

public class LocalDiskStorage {
    
    private let initPath: String;
    private let memoryLimit: Int;
    
    private let indexHandler: IndexFileHandler;

    public var path: String {
        get { return self.initPath; }
    }
    
    init (in path: String) throws {
        self.initPath = path;
        self.memoryLimit = 0;
        self.indexHandler = try IndexFileHandler(path: path); // todo: translate exceptions
    }
    
    init (in path: String, withMaxMemoryOf memoryLimit: Int) throws {
        self.initPath = path;
        self.memoryLimit = memoryLimit;
        self.indexHandler = try IndexFileHandler(path: path); // todo: translate exceptions
        
        // todo: option -> cipher it
    }
    
    public func save (identifier: String, value: [String: Any]) throws {
        // todo: implement
        
        let jsonData: Data = try JSONSerialization.data(withJSONObject: value);
        var bytes: String = "";
        
        jsonData.forEach { (byte) in
            bytes += "\(byte) ";
        }
        
        // todo: SAVE BYTES AS STRING
        // todo: pick a file ?
        
        // todo: file handler class for file saving
        
        print("Saving \(identifier).");
        print(bytes);
    }
    
}





