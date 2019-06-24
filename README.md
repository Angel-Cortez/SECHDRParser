# SECHDRParser

A simple S.E.C header file parser made with Swift.

For additional information, please visit [S.E.C.](https://www.sec.gov/edgar/searchedgar/sampleheader.htm).<br>

## Getting Started

SwiftNIO primarily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on SwiftNIO in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/acort3255/SECHDRParser", from: "1.0.0")
]
```

## Usage

For convenience you can declare:

```swift

let parser = SECHDRParser()

do {
   result = try parser.parse(data: hdr)
} catch let error {
    print(error)
}
```

## Example

Imagine there's a header file with the following contents:

```
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
```

## Example

#### Read an `ACCESSION-NUMBER` from the above S.E.C filing.

```swift
let parser = SECHDRParser()

do {
    if let result = try parser.parse(data: hdr) {
        print(result["ACCESSION-NUMBER"]!)
        } catch let error {
            print(error)
    }
}
```

*Output:*
```
0001104659-19-0253282
```