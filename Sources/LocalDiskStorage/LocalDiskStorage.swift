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
        self.initPath = path.last == "/" ? path : "\(path)/";
        self.fileSizeLimit = fileSizeLimit;
        self.indexHandler = try IndexFileHandler(path: path); // todo: translate exceptions?
        self.fileHandler = try FileStorageHandler(path: path); // todo: translate exceptions?
    }
    
    public func save (identifier: String, value: [String: Any], index: Array<String>?) throws -> Void {
        
        // todo: implement unique identifier??
        // todo: implement method for unique identifier testing?
        
        let index = index ?? Array<String>();
        let fileToSave: String = self.getFileNameToSave();
        let entity: StorageValue = StorageValue(identifier: identifier, storeValue: value);
        let entityIndex: StorageIndex = StorageIndex(identifier: identifier, index: index, file: fileToSave);
        
        try self.fileHandler.saveTo(data: entity, toFile: fileToSave);
        try self.indexHandler.createIndex(entityIndex);
    }
    
    public func load (withId identifier: String) throws -> [String: Any]? {

        guard let index: StorageIndex = try self.indexHandler.getIndex(identifier) else {
            return nil;
        }
        
        guard let item: StorageValue = try self.fileHandler.loadItem(withId: identifier, fromFile: index.file) else {
            return nil;
        };

        return item.storeValue;
    }
    
    public func find (withIndexes indexes: Array<String>) throws -> Array<[String: Any]>? {

        guard let fileIndexes = try self.indexHandler.findIndexes(indexes) else {
            return nil;
        }
        
        let groupedFiles = self.getGroupedItemsFromIndexes(fileIndexes);
        var loadedItems: Array<[String: Any]> = Array<[String: Any]>();
        
        for group in groupedFiles {
            
            let items = try self.fileHandler.loadItems(withIds: group.itemIdentifiers, fromFile: group.fileName);
            
            if items != nil {
                items?.forEach({ (item) in loadedItems.append(item.storeValue) });
            }
        }
        
        return loadedItems.count > 0 ? loadedItems : nil;
    }
    
    private func getFileNameToSave () -> String {

        let allFileNames = self.indexHandler.getListOfAllFiles();
        
        if allFileNames.count == 0 {
            return self.generateNewFileName();
        }
        
        for fileName in allFileNames {
            do {
                if try FileStorageHandler.getFileSize("\(self.path)\(fileName)") < UInt(self.fileSizeLimit) {
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
            
            if !FileStorageHandler.fileExists(atPath: "\(self.path)\(name)") {
                matched = true;
                break;
            }
            
            if iterations > 999 {
                name = "data_\(arc4random_uniform(UInt32(1_000_000))).ldsData";
                if !FileStorageHandler.fileExists(atPath: "\(self.path)\(name)") {
                    matched = true;
                    break;
                }
            }
            
            count += 1;
            iterations += 1;
        }
        
        return name;
    }
    
    private func getGroupedItemsFromIndexes (_ fileIndexes: Array<StorageIndex>) -> Array<GroupedItems> {
        
        return fileIndexes.reduce(Array<GroupedItems>()) { (groupedItems, index) -> Array<GroupedItems> in
            
            var groupedItems = groupedItems;
            let groupedItemIndex = groupedItems.index(where: { (item) -> Bool in
                return item.fileName == index.file;
            });
            
            if groupedItemIndex == nil {
                groupedItems.append(GroupedItems(fileName: index.file, itemIdentifiers: [index.identifier]));
                return groupedItems;
            }

            groupedItems[groupedItemIndex!].itemIdentifiers.append(index.identifier);
            
            return groupedItems;
        };
    }
}

// todo: move to a separate file?
struct GroupedItems {
    public let fileName: String;
    public var itemIdentifiers: Array<String>;
}


