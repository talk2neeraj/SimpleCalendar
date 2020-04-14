//
//  CalendarViewController.swift
//  SimpleCalendar
//
//  Created by Neeraj Singh on 4/10/20.
//  Copyright © 2020 Neeraj Singh. All rights reserved.
//

import Cocoa

class CalendarViewController: NSViewController {
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var dateInfoField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDateInfoField()
    }
    
    private func showFollowingMonth(_ month: Int) {
        let calendar = Calendar(identifier: .gregorian)
        guard let newDate = calendar.date(byAdding: .month, value: month, to: calendarView.currentGridDate) else { return }
        calendarView.currentGridDate = newDate
        updateDateInfoField()
    }
    
    @IBAction func showPrevMonth(_ sender: Any) {
        showFollowingMonth(-1)
    }
    
    @IBAction func showNextMonth(_ sender: Any) {
        showFollowingMonth(1)
    }
    
    @IBAction func showToday(_ sender: Any) {
        calendarView.currentGridDate = Date()
        updateDateInfoField()
    }
    
    private func updateDateInfoField() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        dateInfoField.stringValue = formatter.string(from: calendarView.currentGridDate)

    }
}
