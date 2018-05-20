import Foundation;

extension String {
    
    /// An extension to String type for removing all new lines from String.
    mutating func removeNewLines () {
        self = self.components(separatedBy: CharacterSet.newlines).joined();
    }
    
    /// An extension to String type for determining whether String is actually a numeric value.
    public func isNumeric () -> Bool {
        return Double(self) != nil;
    }
}

