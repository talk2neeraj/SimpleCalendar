//
//  CalendarView.swift
//  SimpleCalendar
//
//  Created by Neeraj Singh on 4/12/20.
//  Copyright © 2020 Neeraj Singh. All rights reserved.
//

import Cocoa

enum RectSide {
    case left
    case right
    case top
    case bottom
    
}

struct GridInfo {
    // hi = Horizontal grid Index
    // vi = Vertical grid Index
    // hc = Horizontal grid count
    // vc = Vertical grid count
    let hi: UInt, vi: UInt, hc: UInt, vc: UInt
    
    init(hi: UInt, vi: UInt, hc: UInt, vc: UInt) {
        self.hi = hi
        self.vi = vi
        self.hc = hc
        self.vc = vc
        precondition(hc > 0)
        precondition(vc > 0)
    }
}

class CalendarView: NSView {
    var currentGridDate = Date() {
        didSet {
            setNeedsDisplay(self.bounds)
        }
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    lazy var dayFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()


    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let graphicsContext = NSGraphicsContext.current else { return }
        graphicsContext.saveGraphicsState()
        defer {
            graphicsContext.restoreGraphicsState()
        }
        
        let gridDate  = currentGridDate
        guard let todayGrid = gridDate.gridInfo else { return }
        NSColor.white.setFill()
        NSColor.darkGray.setStroke()
        NSBezierPath.fill(self.bounds)
        let bound = self.bounds
        let hc:UInt = todayGrid.hc
        let vc:UInt = todayGrid.vc
        for hi in 0...hc {
            for vi in 0...vc {
                graphicsContext.cgContext.saveGState()
                defer {
                    graphicsContext.cgContext.restoreGState()
                }

                let grid = GridInfo(hi: hi, vi: vi, hc: hc, vc: vc)
                let gridRect = bound.gridRect(grid)
                graphicsContext.cgContext.clip(to: gridRect)
                
                if hi == 0 || hi == (hc - 1) {
                    NSColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1).setFill()
                    NSBezierPath.fill(self.bounds)
                }
                gridRect.bezierPath(drawSides(grid)).stroke()
                guard let date = grid.date(ref: gridDate) else { continue }
                var color = date.sameMonth(ref: gridDate) ? NSColor.black : NSColor.gray
                color = date.isToday ? NSColor.red : color
                dayFormatter.string(from: date).calendarStyle(color).draw(in: gridRect.insetBy(dx: 12, dy: 4))
            }
        }
    }
    
    func drawSides(_ grid: GridInfo) -> [RectSide] {
        var sides: [RectSide] = [.top, .right]
        if grid.hi == 0 { sides.append(.left) }
        if grid.vi == (grid.vc - 1) { sides.append(.bottom) }
        return sides
    }
}

extension Date {
    var gridInfo: GridInfo? {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.dateComponents([.weekday, .weekOfMonth], from: self)
        guard let weekDay = component.weekday else { return nil }
        guard let week = component.weekOfMonth else { return nil }
        return GridInfo(hi: UInt(weekDay - 1), vi: UInt(week - 1), hc: UInt(calendar.weekdaySymbols.count), vc: 6)
    }
    
    var isToday: Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDateInToday(self)
    }
    
    func sameMonth(ref date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDate(self, equalTo: date, toGranularity: .month) &&
                calendar.isDate(self, equalTo: date, toGranularity: .year)
    }
}

extension GridInfo {
    func date(ref date: Date) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.dateComponents([.year, .month], from: date)
        return DateComponents(calendar: calendar as Calendar, year: component.year, month: component.month, weekday: Int(self.hi + 1), weekOfMonth: Int(self.vi + 1)).date
    }
}

extension NSRect {

    func gridRect(_ grid: GridInfo) -> NSRect {
        let gridWidth = self.width / CGFloat(grid.hc)
        let gridHeight = self.height / CGFloat(grid.vc)
        let gridX = self.minX + CGFloat(grid.hi) * gridWidth
        let gridY = self.minY + CGFloat(grid.vi) * gridHeight
        return NSRect(x: gridX, y: gridY, width: gridWidth, height: gridHeight)
    }

    func bezierPath(_ sides: [RectSide]) -> NSBezierPath {
        let path = NSBezierPath()
        path.lineWidth = 1
        for side in sides {
            switch side {
            case .left:
                path.move(to: NSPoint(x: self.minX, y: minY))
                path.line(to: NSPoint(x: self.minX, y: maxY))
            case .right:
                path.move(to: NSPoint(x: self.maxX, y: minY))
                path.line(to: NSPoint(x: self.maxX, y: maxY))
            case .top:
                path.move(to: NSPoint(x: self.minX, y: minY))
                path.line(to: NSPoint(x: self.maxX, y: minY))
            case .bottom:
                path.move(to: NSPoint(x: self.minX, y: maxY))
                path.line(to: NSPoint(x: self.maxX, y: maxY))
            }
        }
        return path
    }

}


extension String {
    func calendarStyle(_ color: NSColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: self.count))
        let font = NSFont.systemFont(ofSize: 24)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: self.count))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
//        paragraphStyle.headIndent = 10
//        paragraphStyle.tailIndent  = 1
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.count))
        return attributedString
    }
}
