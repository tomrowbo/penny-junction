import Foundation

/// A closed, data-only wire format. Values come from analytical tools, never model-authored UI.
struct PennyVisualization: Codable, Hashable, Identifiable, Sendable {
    enum Unit: String, Codable, Sendable {
        case eur, count, percent

        func formatted(_ value: Double) -> String {
            switch self {
            case .eur: return value.formatted(.currency(code: "EUR"))
            case .count: return value.formatted(.number.precision(.fractionLength(0...2)))
            case .percent: return "\(value.formatted(.number.precision(.fractionLength(0...1))))%"
            }
        }
    }

    let id: String
    let title: String
    let caption: String
    let period: PennyVisualizationPeriod
    let institutions: [String]
    let unit: Unit
    let accessibilitySummary: String
    /// Backend tool call IDs, or locally calculated evidence IDs; these are not assumed to be transaction IDs.
    let sourceIDs: [String]
    let presentation: PennyVisualizationPresentation

    private enum CodingKeys: String, CodingKey {
        case id, title, caption, period, institutions, unit, accessibilitySummary, sourceIDs, presentation
    }

    init(id: String, title: String, caption: String, period: PennyVisualizationPeriod,
         institutions: [String], unit: Unit, accessibilitySummary: String,
         sourceIDs: [String], presentation: PennyVisualizationPresentation) {
        self.id = id
        self.title = title
        self.caption = caption
        self.period = period
        self.institutions = institutions
        self.unit = unit
        self.accessibilitySummary = accessibilitySummary
        self.sourceIDs = sourceIDs
        self.presentation = presentation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(id: try container.decode(String.self, forKey: .id),
                  title: try container.decode(String.self, forKey: .title),
                  caption: try container.decode(String.self, forKey: .caption),
                  period: try container.decode(PennyVisualizationPeriod.self, forKey: .period),
                  institutions: try container.decode([String].self, forKey: .institutions),
                  unit: try container.decode(Unit.self, forKey: .unit),
                  accessibilitySummary: try container.decode(String.self, forKey: .accessibilitySummary),
                  sourceIDs: try container.decode([String].self, forKey: .sourceIDs),
                  presentation: try container.decode(PennyVisualizationPresentation.self, forKey: .presentation))
        guard isValid else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid or unreferenced evidence visualization."))
        }
    }

    var isValid: Bool {
        func nonempty(_ value: String) -> Bool { !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        func referencesValid(_ values: [String]) -> Bool { !values.isEmpty && values.allSatisfy { nonempty($0) && sourceIDs.contains($0) } }
        func unique(_ values: [String]) -> Bool { Set(values).count == values.count }
        guard [id, title, caption, accessibilitySummary].allSatisfy(nonempty),
              !institutions.isEmpty, institutions.allSatisfy(nonempty),
              !sourceIDs.isEmpty, sourceIDs.allSatisfy(nonempty), period.isValid else { return false }
        switch presentation {
        case .bar(let points), .line(let points):
            return !points.isEmpty && unique(points.map(\.id)) && points.allSatisfy {
                nonempty($0.id) && nonempty($0.label) && $0.value.isFinite && referencesValid($0.referenceIDs)
            }
        case .progress(let progress):
            return nonempty(progress.label) && progress.value.isFinite && progress.value >= 0 &&
                progress.target.isFinite && progress.target > 0 && referencesValid(progress.referenceIDs)
        case .table(let columns, let rows):
            return !columns.isEmpty && !rows.isEmpty && unique(columns.map(\.id)) && unique(rows.map(\.id)) &&
                columns.allSatisfy { nonempty($0.id) && nonempty($0.title) } &&
                rows.allSatisfy { nonempty($0.id) && $0.cells.count == columns.count && referencesValid($0.referenceIDs) }
        }
    }
}

struct PennyVisualizationPeriod: Codable, Hashable, Sendable {
    let from: String
    let to: String

    var label: String { "\(from)–\(to)" }

    var isValid: Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        func valid(_ value: String) -> Bool {
            guard value.count == 10, value.range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil,
                  let parsed = formatter.date(from: value) else { return false }
            return formatter.string(from: parsed) == value
        }
        return valid(from) && valid(to) && from <= to
    }
}

struct PennyVisualizationPoint: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let label: String
    let value: Double
    let referenceIDs: [String]
}

struct PennyVisualizationProgress: Codable, Hashable, Sendable {
    let label: String
    let value: Double
    let target: Double
    let referenceIDs: [String]
}

struct PennyVisualizationColumn: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
}

struct PennyVisualizationRow: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let cells: [String]
    let referenceIDs: [String]
}

enum PennyVisualizationPresentation: Codable, Hashable, Sendable {
    case bar([PennyVisualizationPoint])
    case line([PennyVisualizationPoint])
    case progress(PennyVisualizationProgress)
    case table(columns: [PennyVisualizationColumn], rows: [PennyVisualizationRow])

    private enum Kind: String, Codable { case bar, line, progress, table }
    private enum CodingKeys: String, CodingKey { case type, points, label, value, target, referenceIDs, columns, rows }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .type) {
        case .bar: self = .bar(try container.decode([PennyVisualizationPoint].self, forKey: .points))
        case .line: self = .line(try container.decode([PennyVisualizationPoint].self, forKey: .points))
        case .progress:
            self = .progress(PennyVisualizationProgress(label: try container.decode(String.self, forKey: .label),
                                                       value: try container.decode(Double.self, forKey: .value),
                                                       target: try container.decode(Double.self, forKey: .target),
                                                       referenceIDs: try container.decode([String].self, forKey: .referenceIDs)))
        case .table:
            self = .table(columns: try container.decode([PennyVisualizationColumn].self, forKey: .columns),
                          rows: try container.decode([PennyVisualizationRow].self, forKey: .rows))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bar(let points):
            try container.encode(Kind.bar, forKey: .type)
            try container.encode(points, forKey: .points)
        case .line(let points):
            try container.encode(Kind.line, forKey: .type)
            try container.encode(points, forKey: .points)
        case .progress(let progress):
            try container.encode(Kind.progress, forKey: .type)
            try container.encode(progress.label, forKey: .label)
            try container.encode(progress.value, forKey: .value)
            try container.encode(progress.target, forKey: .target)
            try container.encode(progress.referenceIDs, forKey: .referenceIDs)
        case .table(let columns, let rows):
            try container.encode(Kind.table, forKey: .type)
            try container.encode(columns, forKey: .columns)
            try container.encode(rows, forKey: .rows)
        }
    }
}
