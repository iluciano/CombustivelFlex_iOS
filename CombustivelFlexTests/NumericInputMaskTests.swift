import XCTest
@testable import CombustivelFlex

final class NumericInputMaskTests: XCTestCase {
    func testMaskedFormatsTypedDigits() {
        XCTAssertEqual(NumericInputMask.masked("1"), "1.")
        XCTAssertEqual(NumericInputMask.masked("12"), "1.2")
        XCTAssertEqual(NumericInputMask.masked("123"), "1.23")
        XCTAssertEqual(NumericInputMask.masked("1234"), "12.34")
    }

    func testMaskedAllowsDeletingAutoInsertedSeparatorAndPreviousDigit() {
        XCTAssertEqual(
            NumericInputMask.masked("1", previousValue: "1."),
            ""
        )
    }

    func testMaskedAllowsDeletingSeparatorInsideValue() {
        XCTAssertEqual(
            NumericInputMask.masked("12", previousValue: "1.2"),
            "2."
        )
    }

    func testCompletedKeepsEmptyValueEmpty() {
        XCTAssertEqual(NumericInputMask.completed(""), "")
    }
}
