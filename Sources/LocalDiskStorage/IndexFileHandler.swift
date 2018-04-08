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

    private func ensureIndexFileExists () throws -> Array<StorageIndex> {

        if self.indexFileExists() {
            return try self.loadIndexFile();
        }
        
        let emptyIndexes: Array<StorageIndex> = Array<StorageIndex>();
        // todo: remove.
        // emptyIndexes.append(StorageIndex(identifier: "AK8901", index: ["Jan"], file: "somefilename.ldsData"));
        // emptyIndexes.append(StorageIndex(identifier: "AKKJHKUKJHJ", index: ["Jana", "Hana"], file: "somefilename.ldsData"));
        
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
    
    private func loadIndexFile () throws -> Array<StorageIndex> {
        
        var fileContent: String;
        
        do {
            // Load a file.
            fileContent = try String(contentsOf: URL(fileURLWithPath: self.filePath), encoding: String.Encoding.utf8);
        } catch {
            throw IndexFileError.FileCouldNotBeLoaded;
        }
        
        // Remove new lines for parsing bytes.
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
}


enum IndexFileError: Error {
    case InvalidPath;
    case FileCouldNotBeCreated;
    case FileCouldNotBeLoaded;
    case FileCorrupted;
    case FileCouldNotBeSaved;
}