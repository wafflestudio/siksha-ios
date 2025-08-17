//
//  CalendarView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/04.
//

import SwiftUI
import JTAppleCalendar

class CalendarTapGestureRecognizer: UITapGestureRecognizer {
    var calendar: JTACMonthView?
}

class CalendarDelegate: NSObject, JTACMonthViewDelegate, JTACMonthViewDataSource {
    let formatter = DateFormatter()
    private let cal = Calendar(identifier: .gregorian)
    @Binding var selectedDate: String
    
    init(selectedDate: Binding<String>) {
        self._selectedDate = selectedDate
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateCell.reuseID, for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell {
            let dateCell = cell as! DateCell
            configureCell(cell: dateCell, cellState: cellState)
            
            formatter.dateFormat = "yyyy-MM-dd"
            
            if cellState.selectionType == .userInitiated {
                selectedDate = formatter.string(from: cellState.date)
            }
        }
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if let cell = cell {
            let dateCell = cell as! DateCell
            configureCell(cell: dateCell, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) -> Bool {
        if cellState.dateBelongsTo != .thisMonth {
            return false
       }
       return true
    }
    
    func configureCell(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo != .thisMonth {
            cell.background.layer.backgroundColor = UIColor.clear.cgColor
            cell.dateLabel.textColor = .white
            return
        }
        
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        let todayColor = UIColor(named: "Color/Foundation/Gray/200")
        let textColor = UIColor(named: "Color/Foundation/Gray/700")
        let selectedColor = UIColor(named: "Color/Foundation/Orange/500")
        
        if cellState.isSelected {
            cell.background.layer.backgroundColor = selectedColor!.cgColor
            cell.dateLabel.font = UIFont(name: "NanumSquareOTFB", size: 14)
            cell.dateLabel.textColor = .white
        } else {
            if formatter.string(from: cellState.date) == todayString {
                cell.background.layer.backgroundColor = todayColor!.cgColor
                cell.dateLabel.font = UIFont(name: "NanumSquareOTFB", size: 14)
                cell.dateLabel.textColor = textColor
            } else {
                cell.background.layer.backgroundColor = UIColor.clear.cgColor
                cell.dateLabel.font = UIFont(name: "NanumSquareOTFR", size: 14)
                cell.dateLabel.textColor = textColor
            }
        }
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.dateLabel.text = cellState.text
        
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        formatter.dateFormat = "yyyy.MM"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: DateHeader.reuseID, for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        
    
        let leftTap = CalendarTapGestureRecognizer(target: self, action: #selector(toPrevMonth(sender:)))
        let rightTap = CalendarTapGestureRecognizer(target: self, action: #selector(toNextMonth(sender:)))
        leftTap.calendar = calendar
        rightTap.calendar = calendar
        header.leftButton.addGestureRecognizer(leftTap)
        header.rightButton.addGestureRecognizer(rightTap)
        return header
    }
    
    @objc func toPrevMonth(sender: CalendarTapGestureRecognizer) {
        sender.calendar?.scrollToSegment(.previous)
    }
    
    @objc func toNextMonth(sender: CalendarTapGestureRecognizer) {
        sender.calendar?.scrollToSegment(.next)
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 60)
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let now = Date()
        let sixMonth = DateComponents(month: 6)
        let minusSixMonth = DateComponents(month: -6)
        
        let startDate = cal.date(byAdding: minusSixMonth, to: now) ?? now
        let endDate = cal.date(byAdding: sixMonth, to: now) ?? now
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, generateOutDates: .off)
    }
}

class DateHeader: JTACMonthReusableView {
    static let reuseID = "dateHeader"
    
    var monthTitle: UILabel
    var leftButton: UIButton
    var rightButton: UIButton

    override init(frame: CGRect) {
        let monthSize = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        monthTitle = UILabel(frame: monthSize)
        leftButton = UIButton()
        rightButton = UIButton()
        
        leftButton.frame = CGRect(x: 0, y: 0, width: 10, height: 16)
        rightButton.frame = CGRect(x: 0, y: 0, width: 10, height: 16)
        leftButton.setBackgroundImage(UIImage(named: "PrevDate"), for: .normal)
        rightButton.setBackgroundImage(UIImage(named: "NextDate"), for: .normal)
        
        super.init(frame: frame)
        
        self.addSubview(monthTitle)
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        
        monthTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        monthTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        monthTitle.textAlignment = .center
        monthTitle.translatesAutoresizingMaskIntoConstraints = false
        monthTitle.textColor = UIColor(red: 254/255, green: 140/255, blue: 89/255, alpha: 1)
        monthTitle.font = UIFont(name: "NanumSquareOTFEB", size: 15)
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -54).isActive = true
        leftButton.centerYAnchor.constraint(equalTo: monthTitle.centerYAnchor).isActive = true
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 54).isActive = true
        rightButton.centerYAnchor.constraint(equalTo: monthTitle.centerYAnchor).isActive = true
        
        var weekDay = [UILabel]()
        let dayName = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        for i in 0..<7 {
            weekDay.append(UILabel())
            weekDay[i].text = dayName[i]
            weekDay[i].textColor = .init(white: 51/255, alpha: 1)
            weekDay[i].font = UIFont(name: "NanumSquareOTFB", size: 13)
        }
        
        for i in 0..<7 {
            self.addSubview(weekDay[i])
            weekDay[i].textAlignment = .center
            weekDay[i].translatesAutoresizingMaskIntoConstraints = false
            weekDay[i].bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        }
        
        weekDay[0].leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        for i in 1..<7 {
            weekDay[i-1].trailingAnchor.constraint(equalTo: weekDay[i].leadingAnchor).isActive = true
            weekDay[i-1].widthAnchor.constraint(equalTo: weekDay[i].widthAnchor).isActive = true
        }
        
        weekDay[6].trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DateCell: JTACDayCell {
    static let reuseID = "dateCell"

    var background = UIView()
    var dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(self.background)
        contentView.addSubview(self.dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        background.layer.cornerRadius = 18
        background.translatesAutoresizingMaskIntoConstraints = false
        
        background.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        background.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        background.heightAnchor.constraint(equalToConstant: 36).isActive = true
        background.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) has not been implemented")
    }
}

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: String
    
    func makeCoordinator() -> CalendarDelegate {
        CalendarDelegate(selectedDate: _selectedDate)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CalendarView>) -> UIView {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = JTACMonthView()
        calendar.backgroundColor = .clear
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        
        calendar.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseID)
        
        calendar.register(DateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DateHeader.reuseID)
        
        calendar.calendarDelegate = context.coordinator
        calendar.calendarDataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.showsHorizontalScrollIndicator = false
        
        let selection = formatter.date(from: selectedDate) ?? Date()
        
        calendar.scrollToDate(selection, animateScroll: false)
        calendar.selectDates([selection])
        
        return calendar
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CalendarView>) {}
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(selectedDate: .constant("2021-05-21"))
    }
}
