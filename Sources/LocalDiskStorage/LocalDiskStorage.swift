import Foundation;

public class LocalDiskStorage {
    
    private let initPath: String;
    private let fileSizeLimit: Int;
    
    private let indexHandler: IndexFileHandler;
    private let fileHandler: FileStorageHandler;

    public var path: String {
        get { return self.initPath; }
    }
    
    convenience init (in path: String) throws {
        try self.init(in: path, withFileSizeLimit: 16_000_000);
    }
    
    init (in path: String, withFileSizeLimit fileSizeLimit: Int) throws {
        self.initPath = path;
        self.fileSizeLimit = fileSizeLimit;
        self.indexHandler = try IndexFileHandler(path: path); // todo: translate exceptions?
        self.fileHandler = try FileStorageHandler(path: path); // todo: translate exceptions?
    }
    
    public func save (identifier: String, value: [String: Any]) throws {

        let entity: StorageValue = StorageValue(identifier: identifier, storeValue: value);
        let fileToSave: String = self.getFileNameToSave();
        
        try self.fileHandler.saveTo(data: entity, toFile: fileToSave);
        
        // file handler class for file saving -> file handler
        // create an index -> file index handler
    }
    
    private func getFileNameToSave () -> String {

        let allFileNames = self.indexHandler.getListOfAllFiles();
        
        if allFileNames.count == 0 {
            return self.generateNewFileName();
        }
        
        for fileName in allFileNames {
            do {
                if try FileStorageHandler.getFileSize(fileName) < UInt(self.fileSizeLimit) {
                    return fileName;
                }
            } catch { continue; }
        }
        
        return self.generateNewFileName(allFileNames.count);
    }
    
    private func generateNewFileName (_ count: Int = 0) -> String {
        
        var count: Int = count;
        var matched: Bool = false;
        var name: String = "data_\(count).ldsData";
        var iterations: Int = 0;
        
        while (!matched) {
            name = "data_\(count).ldsData";
            
            if !FileStorageHandler.fileExists(name) {
                matched = true;
                break;
            }
            
            if iterations > 999 {
                name = "data_\(arc4random_uniform(UInt32(1_000_000))).ldsData";
                if !FileStorageHandler.fileExists(name) {
                    matched = true;
                    break;
                }
            }
            
            count += 1;
            iterations += 1;
        }
        
        return name;
    }
}
