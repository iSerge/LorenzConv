//
//  FormattedFileReader.swift
//  LorenzConv
//
//  Created by Serge on 24/03/15.
//  Copyright (c) 2015 Serge Ivanov. All rights reserved.
//

import Cocoa

extension String {
    
    // java, javascript, PHP use 'split' name, why not in Swift? :)
    func split(splitter: String) -> [String] {
        let regEx = NSRegularExpression(pattern: splitter, options: NSRegularExpressionOptions(), error: nil)
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = regEx?.stringByReplacingMatchesInString (self, options: NSMatchingOptions(),
            range: NSMakeRange(0, countElements(self)),
            withTemplate:stop)
        if let str = modifiedString{
            return str.componentsSeparatedByString(stop)
        } else {
            return [String]()
        }
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

class FormattedFileReader: NSWindowController, NSTableViewDataSource {

    @IBOutlet weak var table: NSTableView!
    
    dynamic var isCommaSep: Bool = true { didSet { self.updateTable() } }
    dynamic var isTabSep: Bool = false { didSet { self.updateTable() } }
    dynamic var isSemicolonSep: Bool = false { didSet { self.updateTable() } }
    dynamic var customSep: String = "" { didSet { self.updateTable() } }

    dynamic var firstLineIsHeader: Bool = true { didSet { self.updateTable() } }
    dynamic var skipLines: Int = 0 { didSet { self.updateTable() } }
    
    dynamic var xColumn: Int = 0 { didSet { canProceed = -1 != xColumn && -1 != yColumn} }
    dynamic var yColumn: Int = 1 { didSet { canProceed = -1 != xColumn && -1 != yColumn } }
    
    dynamic var canProceed: Bool = true
    
    dynamic var lines: [String] = [String]() { didSet { self.updateTable() } }
    var splitter: String = ""
    
    var tableData: [String:[String]] = [String:[String]]()
    var nRows: Int = 0
    
    override func setNilValueForKey(key: String) {
        switch(key){
            case "xColumn":
                self.xColumn = -1
                break;
            case "yColumn":
                self.yColumn = -1
                break;
            default:
                super.setNilValueForKey(key)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.updateTable()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return nRows
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if let rowData = tableData[tableColumn!.identifier!]{
            if row < rowData.count {
                return rowData[row]
            }
        }
        return ""
    }
    
    @IBAction func okButton(sender: AnyObject){
        NSApp.stopModalWithCode(NSModalResponseOK)
        window?.close()
    }

    @IBAction func cancelButton(sender: AnyObject){
        NSApp.stopModalWithCode(NSModalResponseCancel)
        window?.close()
    }

    func updateTable(){
        splitter = ""

        if isCommaSep {
            splitter += "(,)"
        }

        if isTabSep {
            if !splitter.isEmpty {
                splitter += "|"
            }
            splitter += "(\t)"
        }

        if isSemicolonSep {
            if !splitter.isEmpty {
                splitter += "|"
            }
            splitter += "(;)"
        }
        
        if !customSep.isEmpty {
            if !splitter.isEmpty {
                splitter += "|"
            }
            splitter += "(\(customSep))"
        }

        var skipL = skipLines
        if firstLineIsHeader {
            skipL += 1
        }
        
        nRows = min(10, lines.count - skipL)

        var headers: [String]
        if firstLineIsHeader {
            headers = lines[skipLines].split(splitter)
        } else {
            headers = [String]()
        }

        var nColumns = headers.count
        
        tableData = [String:[String]]()
        
        for row: Int in 0...nRows-1 {
            let rowData = lines[skipL+row].split(splitter)
            for col: Int in 0...rowData.count-1 {
                if var column = tableData["\(col)"] {
                    column[row] = rowData[col]
                    tableData["\(col)"] = column
                } else {
                    var column = [String](count: nRows, repeatedValue: "")
                    column[row] = rowData[col]
                    tableData["\(col)"] = column
                }
            }
            nColumns = max(nColumns, rowData.count)
        }
        
        while table.numberOfColumns > 0 {
            table.removeTableColumn(table.tableColumns.first as NSTableColumn)
        }
        
        for i: Int in 0...nColumns-1{
            let tableColumn: NSTableColumn = {
                var column = NSTableColumn(identifier: "\(i)")
                if i < headers.count {
                    column.title = "\(headers[i]) (\(i))"
                } else {
                    column.title = "(\(i))"
                }
                return column
            }()
            
            table.addTableColumn(tableColumn)
        }
        
        table.reloadData()
    }
    
    var graphData: ([Float],[Float]) {
        var xData = [Float]()
        var yData = [Float]()

        xData.reserveCapacity(lines.count)
        yData.reserveCapacity(lines.count)

        var skipL = skipLines
        if firstLineIsHeader {
            skipL += 1
        }
        
        for i: Int in skipL...lines.count-1 {
            let rowData = lines[i].split(splitter)
            if xColumn < rowData.count && yColumn < rowData.count {
                xData.append(rowData[xColumn].floatValue)
                yData.append(rowData[yColumn].floatValue)
            }
        }
        
        return (xData, yData)
    }
}
