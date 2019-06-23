import XCTest
@testable import SECHDRParser

final class SECHDRParserTests: XCTestCase {
    func testValidHdr() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let parser = SECHDRParser()
        
        let hdr = """
<SEC-HEADER>0001104659-19-025328.hdr.sgml : 20190430
<ACCEPTANCE-DATETIME>20190430162156
<ACCESSION-NUMBER>0001104659-19-025328
<TYPE>10-Q
<PUBLIC-DOCUMENT-COUNT>119
<PERIOD>20190331
<FILING-DATE>20190430
<DATE-OF-FILING-DATE-CHANGE>20190430
<FILER>
<COMPANY-DATA>
<CONFORMED-NAME>INTERNATIONAL BUSINESS MACHINES CORP
<CIK>0000051143
<ASSIGNED-SIC>3570
<IRS-NUMBER>130871985
<STATE-OF-INCORPORATION>NY
<FISCAL-YEAR-END>1231
</COMPANY-DATA>
<FILING-VALUES>
<FORM-TYPE>10-Q
<ACT>34
<FILE-NUMBER>001-02360
<FILM-NUMBER>19782072
</FILING-VALUES>
<BUSINESS-ADDRESS>
<STREET1>1 NEW ORCHARD ROAD
<CITY>ARMONK
<STATE>NY
<ZIP>10504
<PHONE>9144991900
</BUSINESS-ADDRESS>
<MAIL-ADDRESS>
<STREET1>1 NEW ORCHARD RD
<CITY>ARMONK
<STATE>NY
<ZIP>10504
</MAIL-ADDRESS>
</FILER>
</SEC-HEADER>
"""
        var result: [String: Any]?
        do {
            result = try parser.parse(data: hdr)
//            print(result)
        } catch let error {
            print(error)

        }
        
        XCTAssert(result != nil)
    }

    static var allTests = [
        ("testValidHdr", testValidHdr),
    ]
}
