import Foundation;


class FileStorageHandler {
    
    private let path: String;
    
    init (path: String) throws {
        self.path = path.last == "/" ? (path) : (path + "/");
        
        if !FileStorageHandler.validPath(self.path) {
            throw FileStorageError.InvalidPath;
        }
    }
    
    public func saveTo (data: StorageValue, toFile fileName: String) throws {

        // let fileContent: Array<StorageValue> = Array<StorageValue>();
        print(data.identifier);
        print(data.storeValue);
        print(fileName);
        
        if FileStorageHandler.fileExists(fileName) {
            // todo: load file and overwrite "fileContent"
            // load in different method
        }
    }
    
    private func loadFile (_ fileName: String) throws -> Array<StorageValue> {
        
        // todo: implement
        
        return Array<StorageValue>();
    }
    
    public static func getFileSize (_ filePath: String) throws -> UInt {
        do {
            let fileAttributes: [FileAttributeKey : Any] = try FileManager().attributesOfItem(atPath: filePath);
            
            guard let size: UInt = fileAttributes[FileAttributeKey.size] as? UInt else {
                throw FileStorageError.FileNotExists;
            }
            
            return size;
        } catch {
            throw FileStorageError.FileNotExists;
        }
    }
    
    public static func validPath (_ path: String) -> Bool {
        var isDir: ObjCBool = true;
        return FileManager().fileExists(atPath: path, isDirectory: &isDir);
    }
    
    public static func fileExists (_ filePath: String) -> Bool {
        return FileManager().fileExists(atPath: filePath);
    }
    
}

enum FileStorageError: Error {
    case InvalidPath;
    case FileNotExists;
}
