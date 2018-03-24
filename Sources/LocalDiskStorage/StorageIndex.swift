
enum StorageIndexValues: String {
    case identifier = "identifier";
    case index = "index";
    case file = "file";
}

struct StorageIndex: Codable {
    var identifier: String;
    var index: Array<String>;
    var file: String;
    
    public func toDictionary () -> [String: Any] {
        return [
            "\(StorageIndexValues.identifier)": self.identifier,
            "\(StorageIndexValues.index)": self.index,
            "\(StorageIndexValues.file)": self.file
        ];
    }
}
