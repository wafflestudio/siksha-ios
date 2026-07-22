//
//  CalendarViewTests.swift
//  SikshaTests
//

import JTAppleCalendar
import SwiftUI
import XCTest

@testable import Siksha

@MainActor
final class CalendarViewTests: XCTestCase {
    func testSelectionPolicyRejectsDateOutsideCurrentMonthThroughDelegateWitness() async throws {
        let referenceDate = try XCTUnwrap(
            Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 7, day: 1))
        )
        let (delegate, _) = makeDelegate(currentDate: { referenceDate })
        let calendar = await makeCalendar(delegate: delegate)
        let outsideMonthState = try XCTUnwrap(
            (0..<6)
                .flatMap { row in (0..<7).compactMap { calendar.cellStatusForDate(at: row, column: $0) } }
                .first { $0.dateBelongsTo != .thisMonth }
        )
        let calendarDelegate: any JTACMonthViewDelegate = delegate

        XCTAssertFalse(
            calendarDelegate.calendar(
                calendar,
                shouldSelectDate: outsideMonthState.date,
                cell: nil,
                cellState: outsideMonthState,
                indexPath: IndexPath(item: 0, section: 0)
            )
        )
    }

    func testOnlyUserSelectionUpdatesBinding() async throws {
        let initialDate = "2026-01-01"
        let (delegate, selectedDate) = makeDelegate(selectedDate: initialDate)
        let calendar = await makeCalendar(delegate: delegate)
        let date = Date()
        var state = try XCTUnwrap(calendar.cellStatus(for: date))
        let cell = DateCell(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        state.selectionType = .programatic
        delegate.calendar(
            calendar,
            didSelectDate: date,
            cell: cell,
            cellState: state,
            indexPath: IndexPath(item: 0, section: 0)
        )
        XCTAssertEqual(selectedDate.value, initialDate)

        state.selectionType = .userInitiated
        delegate.calendar(
            calendar,
            didSelectDate: date,
            cell: cell,
            cellState: state,
            indexPath: IndexPath(item: 0, section: 0)
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        XCTAssertEqual(selectedDate.value, formatter.string(from: date))
    }

    func testDeselectingDateReconfiguresCell() async throws {
        let (delegate, _) = makeDelegate()
        let calendar = await makeCalendar(delegate: delegate)
        let date = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        let cell = DateCell(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        calendar.selectDates([date], triggerSelectionDelegate: false)
        let selectedState = try XCTUnwrap(calendar.cellStatus(for: date))
        delegate.configureCell(cell: cell, cellState: selectedState)
        let selectedBackgroundColor = cell.background.layer.backgroundColor

        calendar.deselect(dates: [date], triggerSelectionDelegate: false)
        let deselectedState = try XCTUnwrap(calendar.cellStatus(for: date))
        delegate.calendar(
            calendar,
            didDeselectDate: date,
            cell: cell,
            cellState: deselectedState,
            indexPath: IndexPath(item: 0, section: 0)
        )

        XCTAssertNotEqual(cell.background.layer.backgroundColor, selectedBackgroundColor)
        XCTAssertNotEqual(cell.dateLabel.textColor, .clear)
    }

    func testCalendarReconfiguresDequeuedDateCellForReuse() async throws {
        let (delegate, _) = makeDelegate()
        let calendar = await makeCalendar(delegate: delegate)
        let date = Date()
        let state = try XCTUnwrap(calendar.cellStatus(for: date))
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        let nextState = try XCTUnwrap(calendar.cellStatus(for: nextDate))

        let dequeuedCell = delegate.calendar(
            calendar,
            cellForItemAt: date,
            cellState: state,
            indexPath: IndexPath(item: 0, section: 0)
        )
        let cell = try XCTUnwrap(dequeuedCell as? DateCell)
        XCTAssertEqual(cell.reuseIdentifier, DateCell.reuseID)
        XCTAssertEqual(cell.dateLabel.text, state.text)

        delegate.calendar(
            calendar,
            willDisplay: cell,
            forItemAt: nextDate,
            cellState: nextState,
            indexPath: IndexPath(item: 1, section: 0)
        )

        XCTAssertEqual(cell.dateLabel.text, nextState.text)
    }

    func testHeaderRendersMonthAndWiresNavigation() async throws {
        var navigatedDestinations: [SegmentDestination] = []
        let (delegate, _) = makeDelegate(scrollToSegment: { _, destination in
            navigatedDestinations.append(destination)
        })
        let calendar = await makeCalendar(delegate: delegate)
        let startDate = Date()

        let header = try XCTUnwrap(
            delegate.calendar(
                calendar,
                headerViewForDateRange: (start: startDate, end: startDate),
                at: IndexPath(item: 0, section: 0)
            ) as? DateHeader
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        XCTAssertEqual(header.monthTitle.text, formatter.string(from: startDate))
        XCTAssertEqual(header.subviews.compactMap { ($0 as? UILabel)?.text }.count, 8)

        let previous = try XCTUnwrap(
            header.leftButton.gestureRecognizers?.compactMap { $0 as? CalendarTapGestureRecognizer }.first
        )
        let next = try XCTUnwrap(
            header.rightButton.gestureRecognizers?.compactMap { $0 as? CalendarTapGestureRecognizer }.first
        )
        guard case .previous = previous.destination else {
            return XCTFail("Expected previous-month navigation")
        }
        guard case .next = next.destination else {
            return XCTFail("Expected next-month navigation")
        }
        XCTAssertTrue(previous.calendar === calendar)
        XCTAssertTrue(next.calendar === calendar)

        delegate.navigateMonth(sender: next)
        delegate.navigateMonth(sender: previous)
        XCTAssertEqual(navigatedDestinations.count, 2)
        guard case .next = navigatedDestinations[0] else {
            return XCTFail("Expected next-month command")
        }
        guard case .previous = navigatedDestinations[1] else {
            return XCTFail("Expected previous-month command")
        }
    }

    private func makeDelegate(
        selectedDate: String = "2026-01-01",
        currentDate: @escaping () -> Date = Date.init,
        scrollToSegment: @escaping @MainActor (JTACMonthView, SegmentDestination) -> Void = { calendar, destination in
            calendar.scrollToSegment(destination)
        }
    ) -> (CalendarDelegate, ValueBox<String>) {
        let selectedDate = ValueBox(selectedDate)
        let binding = Binding(
            get: { selectedDate.value },
            set: { selectedDate.value = $0 }
        )
        return (
            CalendarDelegate(
                selectedDate: binding,
                currentDate: currentDate,
                scrollToSegment: scrollToSegment
            ),
            selectedDate
        )
    }

    private func makeCalendar(delegate: CalendarDelegate) async -> JTACMonthView {
        let calendar = JTACMonthView()
        calendar.frame = CGRect(x: 0, y: 0, width: 320, height: 360)
        calendar.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseID)
        calendar.register(
            DateHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DateHeader.reuseID
        )
        calendar.calendarDelegate = delegate
        calendar.calendarDataSource = delegate
        calendar.reloadData()
        calendar.layoutIfNeeded()
        await Task.yield()
        calendar.layoutIfNeeded()
        return calendar
    }
}

private final class ValueBox<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}
