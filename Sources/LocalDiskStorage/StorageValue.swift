import Foundation;


class StorageValue: CodableAny {
    
    var identifier: String = "";
    var storeValue: [String: Any] = [String: Any]();
    
    public init (identifier: String, storeValue: [String: Any]) {
        super.init();
        self.identifier = identifier;
        self.storeValue = storeValue;
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder);
        
        guard var value = self.value as? Dictionary<String, Any> else {
            throw StorageValueError.DecodingError;
        }
        
        self.identifier = value["identifier"] as! String;
        self.storeValue = value["storeValue"] as! [String : Any];
    }
    
    public required init () {
        super.init();
    }
}


enum StorageValueError: Error {
    case DecodingError;
}
