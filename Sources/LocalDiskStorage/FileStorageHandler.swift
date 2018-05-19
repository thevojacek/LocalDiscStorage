import Foundation;


class FileStorageHandler {
    
    private let path: String;
    
    init (path: String) throws {
        self.path = path.last == "/" ? (path) : (path + "/");
        
        if !FileStorageHandler.validPath(self.path) {
            throw FileStorageError.InvalidPath;
        }
    }
    
    /// Saves object into given file.
    ///
    /// - Parameters:
    ///   - data: Data to store.
    ///   - fileName: Name of a wile to which to write.
    /// - Throws: Throws errors.
    public func saveTo (data: StorageValue, toFile fileName: String) throws -> Void {

        let filePath: String = "\(self.path)\(fileName)";
        var fileContent: Array<StorageValue> = Array<StorageValue>()
        
        if FileStorageHandler.fileExists(atPath: filePath) {
            fileContent = try self.loadFile(fileName);
        }

        fileContent.append(data);

        try self.saveFile(withName: fileName, withContent: fileContent);
        
        // Reset fileContent for faster memory release.
        fileContent = Array<StorageValue>();
    }
    
    /// Loads items with given identifiers from a specified file.
    ///
    /// - Parameters:
    ///   - identifiers: Identifiers of object to load.
    ///   - fileName: File name from which to load.
    /// - Returns: Array of values.
    /// - Throws: Throws errors.
    public func loadItems (withIds identifiers: Array<String>, fromFile fileName: String) throws -> Array<StorageValue>? {
        
        // todo: merge with loadItem!! (uses similar logic)
        
        var loadedItems: Array<StorageValue> = Array<StorageValue>();
        var fileContent: Array<StorageValue> = try self.loadFile(fileName);

        for item in fileContent {
            
            if identifiers.contains(item.identifier) {
                loadedItems.append(item);
            }
            
            // Speeds-up this loop.
            if identifiers.count <= loadedItems.count {
                break;
            }
        }
        
        // For faster memory release.
        fileContent = Array<StorageValue>();
        
        return loadedItems.count > 0 ? loadedItems : nil;
    }
    
    /// Loads single object from a file.
    ///
    /// - Parameters:
    ///   - identifier: Identifier of a object to load.
    ///   - fileName: File name from which to load.
    /// - Returns: Returns requested object.
    /// - Throws: Throws errors.
    public func loadItem (withId identifier: String, fromFile fileName: String) throws -> StorageValue? {

        var loadedItem: StorageValue? = nil;
        var fileContent: Array<StorageValue> = try self.loadFile(fileName);
        
        for item in fileContent {
            if item.identifier == identifier {
                loadedItem = item;
                break;
            }
        }
        
        // For faster memory release.
        fileContent = Array<StorageValue>();
        
        return loadedItem;
    }
    
    private func loadFile (_ fileName: String) throws -> Array<StorageValue> {

        var fileContent: String;
        let fileUrl: URL = URL(fileURLWithPath: "\(self.path)\(fileName)");
        
        do {
            // Load a file.
            fileContent = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8);
        } catch {
            throw FileStorageError.FileCouldNotBeLoaded;
        }
        
        fileContent.removeNewLines();

        // Get Bytes.
        let bytes: Array<UInt8> = try fileContent.components(separatedBy: " ")
            .filter({ (component) -> Bool in
                return component != "";
            })
            .map { (component) in
                if !component.isNumeric() || Double(component)! < 0.0 || Double(component)! > 255.0 {
                    throw IndexFileError.FileCorrupted;
                }
                return UInt8(component)!;
        };
        
        // Decode with JSONDecoder and convert to array of "StorageIndex".
        let fileData = Data(bytes: bytes);
        let decoder = JSONDecoder();
        
        do {
            return try decoder.decode(Array<StorageValue>.self, from: fileData);
        } catch {
            throw FileStorageError.FileCorrupted;
        }
    }
    
    private func saveFile (withName fileName: String, withContent content: Array<StorageValue>) throws -> Void {
        
        let fileUrl: URL = URL(fileURLWithPath: "\(self.path)\(fileName)");
        
        // Encode.
        let encoder = JSONEncoder();
        let data = try! encoder.encode(content);
        
        // Format into bytes.
        let bytes = data.toFormattedBytesString(bytesPerLine: 32);
        
        do {
            // Save to a file.
            try bytes.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8);
            
        } catch {
            throw IndexFileError.FileCouldNotBeSaved;
        }
    }
    
    /// Gets size of a specified file.
    ///
    /// - Parameter filePath: File path.
    /// - Returns: Returns file size as UInt in bytes.
    /// - Throws: Throws errors.
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
    
    public static func fileExists (atPath filePath: String) -> Bool {
        return FileManager().fileExists(atPath: filePath);
    }
}

enum FileStorageError: Error {
    case InvalidPath;
    case FileNotExists;
    case FileCouldNotBeLoaded;
    case FileCorrupted;
}
