
import Foundation;


extension Data {
    
    /// Converts Data structure into formatted and structured String of Bytes.
    ///
    /// - Parameter bytesPerLine: How many bytes should be displayed in line. 16 by default.
    /// - Returns: formatted bytes string
    public func toFormattedBytesString (bytesPerLine: Int = 16) -> String {
        
        var result: String = "";
        
        for (index, byte) in self.enumerated() {
            
            if ((index + 1) % bytesPerLine) == 0 {
                result += "\(byte) \n";
                continue;
            }
            
            result += "\(byte) ";
            
        }
        
        return result;
    }
}
