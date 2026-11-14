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

    func testCreateGoalClearsTheBottomNavigationBar() {
        let app = launch(state: "penny")
        let createGoal = app.buttons["Create new goal"]
        let pennyTab = app.buttons["Penny"]

        XCTAssertTrue(createGoal.waitForExistence(timeout: 3))
        XCTAssertTrue(pennyTab.waitForExistence(timeout: 3))
        app.swipeUp()

        XCTAssertLessThanOrEqual(
            createGoal.frame.maxY,
            pennyTab.frame.minY,
            "The primary goal action must remain fully above the bottom navigation bar."
        )
    }

    func testGoalConversationHidesBottomNavigation() {
        let app = launch(state: "penny")
        let createGoal = app.buttons["Create new goal"]

        XCTAssertTrue(createGoal.waitForExistence(timeout: 3))
        app.swipeUp()
        createGoal.tap()

        XCTAssertTrue(app.navigationBars["New goal"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["Accounts"].exists)
        XCTAssertFalse(app.buttons["Me"].exists)
    }

    private func launch(state: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["PENNY_DEMO_STATE"] = state
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_FI"]
        app.launch()
        return app
    }
}
