import Foundation

public class SECHDRParser {
    
    public init() {}
    
    var buffer: String!
    
    public func parse(data: String) throws -> [String: Any]? {
        let xmlCleaned: String = data.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
        // Used to remove the </SEC-HEADER> tag to make a SEC-HEADER a Data Tag
        // to allow for a much simpler BNF grammer
        buffer = String(xmlCleaned[..<xmlCleaned.index(xmlCleaned.endIndex, offsetBy: -13)]).replacingOccurrences(of: #"<(\/?|\!?)(DOCTYPE CORRECTION|PAPER|PRIVATE-TO-PUBLIC|DELETION|CONFIRMING-COPY|CAPTION|STUB|COLUMN|TABLE-FOOTNOTES-SECTION|FOOTNOTES|PAGE)>"#, with: "", options: .regularExpression)
        
        /* The replace above is done to remove the tags without data to prevent the breaking of the
         * parser
         * Reference: https://stackoverflow.com/questions/4867894/sgml-parser-in-java
         * Reference: https://www.sec.gov/info/edgar/pdsdissemspec910.pdf
         */
        
        
        do {
            return try parseSGML() ?? [:]
        } catch let error {
            throw error
        }
    }
    
    enum SECHDRParseError: Error {
        case noEndingTag(element: String)
    }
    
    private func isNextElementShell( index: Int) -> Bool {
        var isElementShell = false
        let next = index
        if next < buffer.count {
            isElementShell = buffer[buffer.index(buffer.startIndex, offsetBy: next)] == "<"
            
            if isElementShell {
                let results = skipUntil(string: ">",  index: next + 1)
                isElementShell = results.1 != -1 && charAt(index: results.1 + 1) == "<"
                
            }
        }
        return isElementShell
    }
    
    private func skipUntil(string: String,  index: Int) -> (Bool, Int) {
        
        if !(buffer.count > index) { return (false, -1) }
        
        var start: String.Index
        var end: String.Index
        
        var results = (false, -1)
        var next = index
        while next < buffer.count {
            start = buffer.index(buffer.startIndex, offsetBy: next)
            end = buffer.index(start, offsetBy: string.count)
            if buffer[start..<end] == string {
                results = (true, next)
                break
            }
            next += 1
        }
        
        return results
    }
    
    func charAt( index: Int) -> String? {
        if !(buffer.count > index) { return nil }
        
        return "\(buffer[buffer.index(buffer.startIndex, offsetBy: index)])"
    }
    
    
    func isEndTag( index: Int, key: String) -> (Bool, Int) {
        let newIndex = index + key.count + 3
        if (buffer.count < newIndex) { return (false, -1) }
        let start = buffer.index(buffer.startIndex, offsetBy: index)
        let end = buffer.index(start, offsetBy: key.count + 3)
        
        return (end <= buffer.endIndex && buffer[start..<end] == "</\(key)>", newIndex)
    }
    
    func findElementKey( index: Int) -> (String, Int) {
        var key = ""
        
        if "<" == buffer[buffer.index(buffer.startIndex, offsetBy: index)] {
            for i in index..<buffer.count {
                if buffer[buffer.index(buffer.startIndex, offsetBy: i)] == ">"{
                    return (key, i + 1)
                } else if buffer[buffer.index(buffer.startIndex, offsetBy: i)] != "<" && buffer[buffer.index(buffer.startIndex, offsetBy: i)] != "/" {
                    key = "\(key)\(buffer[buffer.index(buffer.startIndex, offsetBy: i)])"
                }
                
            }
        }
        
        return (key, -1)
    }
    
    func parseData(index: Int) throws -> (String, String, Int) {
        var data = ""
        var newIndex = index
        
        // Find Element Key
        let keySearch = findElementKey(index: index)
        let key = keySearch.0
        newIndex = keySearch.1
        
        // parseElementBody
        
        while newIndex < buffer.count {
            if buffer[buffer.index(buffer.startIndex, offsetBy: newIndex)] == "<" {
                
                break
            }
            data += "\(buffer[buffer.index(buffer.startIndex, offsetBy: newIndex)])"
            newIndex += 1
        }
        
        return (key, data, newIndex)
    }
    
    func parseElementBody(key: String,  index: Int) throws -> ([String: Any], Int) {
        
        var newIndex = index
        var element = [String: Any]()
        //    print("ParseElementBody: \(key)")
        
        while newIndex < buffer.count && !isEndTag( index: newIndex, key: key).0 {
            if isNextElementShell( index: newIndex) {
                do {
                    let parseResult = try parseElement( index: newIndex)
                    newIndex = parseResult.2
                    element[parseResult.0] = parseResult.1[parseResult.0]
                    
                    
                } catch let error {
                    throw error
                }
                
            } else {
                do {
                    let parseResult = try parseData(index: newIndex)
                    newIndex = parseResult.2
                    element[parseResult.0] = parseResult.1
                    
                } catch let error {
                    throw error
                }
            }
        }
        
        return (element, newIndex)
    }
    
    func parseElement(index: Int) throws -> (String, [String: Any], Int) {
        var newIndex = index
        var element = [String: Any]()
        
        // Find Element Key
        let keySearch = findElementKey(index: index)
        let key = keySearch.0
        newIndex = keySearch.1
        
        // parseElementBody
        do {
            let result = try parseElementBody(key: key, index: newIndex)
            element[key] = result.0
            newIndex = result.1

        } catch let error {
            throw error
        }
        
        
        // Find End Tag
        let isEndTagResult = isEndTag(index: newIndex, key: key)
        newIndex = isEndTagResult.1
        
        if !isEndTagResult.0 { throw SECHDRParseError.noEndingTag(element: key)}
        
        return (key, element, newIndex)
    }
    
    func parseSGML() throws -> [String: Any]? {
        
        // This a parse element, but sec header is neither a element or
        // data tag. As a temporary fix we are removing the end tag for SEC-HEADER
        // and calling parseElementBody to parse either a Element or Data Tag
        //try newParseElement( index: 0).1
        return try parseElementBody(key: "", index: 0).0
    }
}
