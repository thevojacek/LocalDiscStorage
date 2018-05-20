import Foundation


// SINGLETON class
class IdentifierGenerator {
    
    public static let generator: IdentifierGenerator = IdentifierGenerator()
    
    private let characterSet: Array<Character> = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "q", "w", "e", "r", "t", "z", "u",
        "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "y", "x", "c", "v", "b",
        "n", "m", "Q", "W", "E", "R", "T", "Z", "U", "I", "O", "P", "A", "S", "D", "F", "G",
        "H", "J", "K", "L", "Y", "X", "C", "V", "B", "N", "M"
    ]
    
    // Private init to disable initialization outside of this class.
    private init () {}
    
    public func generateUniqueIdentifier (_ usedIdentifiers: Array<String>) -> String {
        
        var length: UInt = 8
        var counter: UInt = 0
        var identifier = self.generateRandomString(length)
        
        while usedIdentifiers.contains(identifier) {
            
            if counter % 128 == 0 { // Increase a length of a identifier string every 128th try.
                length += 1
            }
            
            counter += 1
            identifier = self.generateRandomString(length)
        }
        
        return identifier
    }
    
    private func generateRandomString (_ length: UInt) -> String {
        
        let length = Int(length)
        var identifier: String = ""
        
        for _ in 0..<length {

            let random = arc4random_uniform(UInt32(self.characterSet.count))
            let character = "\(self.characterSet[Int(random)])"
            
            identifier += character
        }
        
        return identifier
    }
}
