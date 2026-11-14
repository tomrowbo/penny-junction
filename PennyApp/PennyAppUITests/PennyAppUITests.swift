import XCTest

@MainActor
final class PennyAppUITests: XCTestCase {
    func testStandaloneShellContainsOnlyPennyAccountsAndMe() {
        let app = launch(state: "penny")

        for label in ["Penny", "Accounts", "Me"] {
            XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 3), "Missing tab: \(label)")
        }
        XCTAssertTrue(app.staticTexts["What are you working towards?"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["S-Etukortti"].exists)
        XCTAssertFalse(app.buttons["Bank"].exists)
    }

    func testMeExplainsPennyDataPrivacyAndIdentity() {
        let app = launch(state: "me")

        for label in ["Connected data", "Privacy and permissions", "About Penny"] {
            XCTAssertTrue(app.staticTexts[label].waitForExistence(timeout: 3), "Missing section: \(label)")
        }
    }

    func testTransactionPreviewSurvivesOfficialDataReplacement() {
        let app = launch(state: "transaction")
        XCTAssertTrue(app.buttons["Discuss with Penny"].waitForExistence(timeout: 5))
    }

    private func launch(state: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["PENNY_DEMO_STATE"] = state
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_FI"]
        app.launch()
        return app
    }
}
