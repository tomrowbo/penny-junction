import XCTest
@testable import PennyApp

final class PennyVisualizationTests: XCTestCase {
    private func payload(_ presentation: String, unit: String = "eur") -> Data {
        Data("""
        {"id":"call-food","title":"Spending","caption":"Actual spending","period":{"from":"2026-01-01","to":"2026-01-31"},"institutions":["S-Bank"],"unit":"\(unit)","accessibilitySummary":"Food, 182.35 euros","sourceIDs":["call-food"],"presentation":\(presentation)}
        """.utf8)
    }

    func testDecodesBackendBarAndRoundTripsWithoutLosingReferences() throws {
        let data = payload(#"{"type":"bar","points":[{"id":"category-0","label":"Food","value":182.35,"referenceIDs":["call-food"]}]}"#)
        let visual = try JSONDecoder().decode(PennyVisualization.self, from: data)
        guard case .bar(let points) = visual.presentation else { return XCTFail("Expected bar") }
        XCTAssertEqual(points.first?.value, 182.35)
        XCTAssertEqual(points.first?.referenceIDs, ["call-food"])
        XCTAssertEqual(try JSONDecoder().decode(PennyVisualization.self, from: JSONEncoder().encode(visual)), visual)
    }

    func testDecodesLineProgressAndTablePresentations() throws {
        let presentations = [
            #"{"type":"line","points":[{"id":"jan","label":"January","value":100,"referenceIDs":["call-food"]}]}"#,
            #"{"type":"progress","label":"Emergency fund","value":100,"target":400,"referenceIDs":["call-food"]}"#,
            #"{"type":"table","columns":[{"id":"label","title":"Measure"},{"id":"value","title":"Amount"}],"rows":[{"id":"r","cells":["Food","€182.35"],"referenceIDs":["call-food"]}]}"#
        ]
        for presentation in presentations {
            let visual = try JSONDecoder().decode(PennyVisualization.self, from: payload(presentation))
            XCTAssertEqual(try JSONDecoder().decode(PennyVisualization.self, from: JSONEncoder().encode(visual)), visual)
        }
    }

    func testRejectsUnknownTypesAndUnits() {
        XCTAssertThrowsError(try JSONDecoder().decode(PennyVisualization.self, from: payload(#"{"type":"html","html":"hello"}"#)))
        XCTAssertThrowsError(try JSONDecoder().decode(PennyVisualization.self, from: payload(#"{"type":"bar","points":[]}"#, unit: "usd")))
    }

    func testRejectsMalformedTablesInvalidTargetsAndMissingReferences() {
        let invalid = [
            #"{"type":"table","columns":[{"id":"a","title":"Amount"}],"rows":[{"id":"r","cells":["1","2"],"referenceIDs":["call-food"]}]}"#,
            #"{"type":"progress","label":"Goal","value":1,"target":0,"referenceIDs":["call-food"]}"#,
            #"{"type":"bar","points":[{"id":"a","label":"Food","value":1,"referenceIDs":[]}] }"#,
            #"{"type":"bar","points":[{"id":"a","label":"Food","value":1,"referenceIDs":["unknown"]}] }"#,
            #"{"type":"bar","points":[]}"#
        ]
        for presentation in invalid {
            XCTAssertThrowsError(try JSONDecoder().decode(PennyVisualization.self, from: payload(presentation)))
        }
    }

    func testRejectsImpossibleDatesAndReversedPeriods() {
        let presentation = #"{"type":"progress","label":"Goal","value":1,"target":2,"referenceIDs":["call-food"]}"#
        let original = String(decoding: payload(presentation), as: UTF8.self)
        let impossible = original.replacingOccurrences(of: "2026-01-01", with: "2026-02-30")
        let reversed = original.replacingOccurrences(of: "2026-01-01", with: "2026-02-01")
        for invalid in [impossible, reversed] {
            XCTAssertThrowsError(try JSONDecoder().decode(PennyVisualization.self, from: Data(invalid.utf8)))
        }
    }

    func testRejectsDuplicatePointIDs() {
        let point = #"{"id":"same","label":"Food","value":1,"referenceIDs":["call-food"]}"#
        XCTAssertThrowsError(try JSONDecoder().decode(PennyVisualization.self, from: payload("{\"type\":\"bar\",\"points\":[\(point),\(point)]}")))
    }
}
