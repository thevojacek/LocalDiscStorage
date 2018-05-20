import Foundation;


class IndexFileHandler {
    
    private let path: String;
    private let fileName: String = "index.ldsData";
    private let filePath: String;
    
    private var indexes: Array<StorageIndex> = Array<StorageIndex>();
    
    init (path: String) throws {
        self.path = path;
        self.filePath = path.last == "/"
            ? (self.path + self.fileName)
            : (self.path + "/" + self.fileName);
        
        if !self.validPath() {
            throw IndexFileError.InvalidPath;
        }
        
        self.indexes = try self.ensureIndexFileExists();
    }

    /// Ensures that index file exists, if not, creates a new one.
    ///
    /// - Returns: Returns a content of the index file.
    /// - Throws: Throws errors.
    private func ensureIndexFileExists () throws -> Array<StorageIndex> {

        if self.indexFileExists() {
            return try self.loadIndexFile();
        }
        
        let emptyIndexes: Array<StorageIndex> = Array<StorageIndex>();
        
        // Save empty file.
        try self.saveIndexFile(data: emptyIndexes);
        
        return emptyIndexes;
    }

    private func validPath () -> Bool {
        var isDir: ObjCBool = true;
        return FileManager().fileExists(atPath: self.path, isDirectory: &isDir);
    }

    private func indexFileExists () -> Bool {
        return FileManager().fileExists(atPath: self.filePath);
    }
    
    /// Saves index file with a given data.
    ///
    /// - Parameter data: Array of "StorageIndex" which should be saved into index file.
    /// - Throws: Throws errors.
    private func saveIndexFile (data: Array<StorageIndex>) throws {
        
        // Encode "StorageIndex" data with JSONEncoder.
        let encoder = JSONEncoder();
        let data = try! encoder.encode(data);
        
        // Format into bytes.
        let bytes = data.toFormattedBytesString(bytesPerLine: 32);
        
        do {
            // Save to a file.
            try bytes.write(to: URL(fileURLWithPath: self.filePath), atomically: true, encoding: String.Encoding.utf8);
            
        } catch {
            throw IndexFileError.FileCouldNotBeSaved;
        }
    }
    
    /// Loads index file.
    ///
    /// - Returns: Returns parsed content of the index file.
    /// - Throws: Throws errors.
    private func loadIndexFile () throws -> Array<StorageIndex> {
        
        var fileContent: String;
        
        do {
            // Load a file.
            fileContent = try String(contentsOf: URL(fileURLWithPath: self.filePath), encoding: String.Encoding.utf8);
        } catch {
            throw IndexFileError.FileCouldNotBeLoaded;
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
            return try decoder.decode(Array<StorageIndex>.self, from: fileData);
        } catch {
            throw IndexFileError.FileCorrupted;
        }
    }
    
    /// Creates a new index.
    ///
    /// - Parameter index: New storage index to create and save.
    /// - Throws: Throws errors.
    public func createIndex (_ index: StorageIndex) throws -> Void {
        
        // todo: check identifier uniqueness even here (getAllIdentifiers method)??
        
        self.indexes.append(index);
        try self.saveIndexFile(data: self.indexes);
    }
    
    /// Gets an index by object identifier.
    ///
    /// - Parameter identifier: Identifier in form of string.
    /// - Returns: Returns index or nil.
    /// - Throws: Throws errors.
    public func getIndex (_ identifier: String) throws -> StorageIndex? {
        
        for index in self.indexes {
            if index.identifier == identifier {
                return index;
            }
        }
        
        return nil;
    }
    
    /// Gets all indexes which match the index values (array of strings).
    ///
    /// - Parameter indexes: Array of string indexes.
    /// - Returns: Returns array of "StorageIndex".
    /// - Throws: Throws errors.
    public func findIndexes (_ indexes: Array<String>) throws -> Array<StorageIndex>? {
        
        var matchedIndexes: Array<StorageIndex> = Array<StorageIndex>();

        for fileIndex in self.indexes {
            for index in fileIndex.index {
                if indexes.contains(index) {
                    matchedIndexes.append(fileIndex);
                    break;
                }
            }
        }
        
        return (matchedIndexes.count > 0) ? matchedIndexes : nil;
    }
    
    /// Gets list of all unique files that can be found in index file.
    ///
    /// - Returns: Returns set of file names.
    public func getListOfAllFiles () -> Set<String> {
        
        var set = Set<String>();
        
        for index in self.indexes {
            if !set.contains(index.file) {
                set.insert(index.file);
            }
        }
        
        return set;
    }
    
    /// Returns all existing identifiers.
    ///
    /// - Returns: All existing identifiers.
    public func getAllIdentifiers () -> Array<String> {
        return self.indexes.map { (index) -> String in
            return index.identifier;
        }
    }
    
    /// Checks, if given identifier exists.
    ///
    /// - Parameter identifier: Identifier in a form of string.
    /// - Returns: Returns boolean indicating whether object with given identifier exists.
    public func identifierExists (_ identifier: String) -> Bool {
        
        let index = self.indexes.first { (index) -> Bool in
            return index.identifier == identifier;
        }
        
        return index == nil ? false : true;
    }
}


enum IndexFileError: Error {
    case InvalidPath;
    case FileCouldNotBeCreated;
    case FileCouldNotBeLoaded;
    case FileCorrupted;
    case FileCouldNotBeSaved;
}
