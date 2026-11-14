import SwiftUI
import Charts

/// Native evidence content for both compact chat bubbles and Penny dashboard cards.
struct PennyEvidenceVisualization: View {
    let visualization: PennyVisualization
    var onOpenSource: ((String) -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var accent: Color { colorScheme == .dark ? .mint : SMobiiliPalette.darkGreen }

    var body: some View {
        if visualization.isValid {
            VStack(alignment: .leading, spacing: 12) {
                Text(visualization.title)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                Text(visualization.caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                presentation

                VStack(alignment: .leading, spacing: 4) {
                    Text(visualization.period.label)
                    Text(visualization.institutions.joined(separator: " · "))
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Period: \(visualization.period.label). Institutions: \(visualization.institutions.joined(separator: ", ")).")

                if let onOpenSource {
                    ForEach(Array(visualization.sourceIDs.enumerated()), id: \.offset) { index, reference in
                        Button {
                            onOpenSource(reference)
                        } label: {
                            Label(visualization.sourceIDs.count == 1 ? "View evidence" : "View evidence \(index + 1)", systemImage: "doc.text.magnifyingglass")
                                .font(.caption.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(accent)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .pennyGlassSurface(cornerRadius: 20)
            .accessibilityElement(children: .contain)
        }
    }

    @ViewBuilder
    private var presentation: some View {
        switch visualization.presentation {
        case .bar(let points):
            if !dynamicTypeSize.isAccessibilitySize {
                ScrollView(.vertical) {
                    Chart(points) { point in
                        BarMark(x: .value("Amount", point.value), y: .value("Category", point.label))
                            .foregroundStyle(accent)
                            .cornerRadius(3)
                            .accessibilityLabel(point.label)
                            .accessibilityValue(visualization.unit.formatted(point.value))
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .chartXAxisLabel(unitLabel)
                    .frame(height: max(150, CGFloat(points.count) * 36))
                    .padding(.trailing, 8)
                }
                .frame(height: min(300, max(180, CGFloat(points.count) * 36 + 30)))
                .accessibilityLabel(visualization.accessibilitySummary)
            }
            values(points)

        case .line(let points):
            if !dynamicTypeSize.isAccessibilitySize {
                Chart(Array(points.enumerated()), id: \.element.id) { index, point in
                    LineMark(x: .value("Period", index), y: .value("Amount", point.value))
                        .foregroundStyle(accent)
                        .interpolationMethod(.linear)
                    PointMark(x: .value("Period", index), y: .value("Amount", point.value))
                        .foregroundStyle(accent)
                        .symbol(.circle)
                        .accessibilityLabel(point.label)
                        .accessibilityValue(visualization.unit.formatted(point.value))
                }
                .chartXAxis {
                    AxisMarks(values: axisIndices(points.count)) { axis in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let index = axis.as(Int.self), points.indices.contains(index) {
                                Text(points[index].label)
                            }
                        }
                    }
                }
                .chartYAxisLabel(unitLabel)
                .frame(height: 190)
                .accessibilityLabel(visualization.accessibilitySummary)
            }
            values(points)

        case .progress(let progress):
            VStack(alignment: .leading, spacing: 8) {
                Text(progress.label).font(.subheadline.weight(.semibold))
                Text("\(visualization.unit.formatted(progress.value)) of \(visualization.unit.formatted(progress.target))")
                    .font(.subheadline)
                    .monospacedDigit()
                ProgressView(value: min(progress.value / progress.target, 1))
                    .tint(accent)
                    .accessibilityLabel(progress.label)
                    .accessibilityValue("\(visualization.unit.formatted(progress.value)) of \(visualization.unit.formatted(progress.target))")
            }

        case .table(let columns, let rows):
            evidenceTable(columns: columns, rows: rows)
        }
    }

    private var unitLabel: String {
        switch visualization.unit {
        case .eur: "EUR"
        case .count: "Count"
        case .percent: "%"
        }
    }

    private func axisIndices(_ count: Int) -> [Int] {
        guard count > 1 else { return [0] }
        return count <= 4 ? Array(0..<count) : [0, (count - 1) / 2, count - 1]
    }

    @ViewBuilder
    private func values(_ points: [PennyVisualizationPoint]) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            evidenceTable(columns: pointColumns, rows: pointRows(points))
        } else {
            DisclosureGroup("Values") {
                evidenceTable(columns: pointColumns, rows: pointRows(points))
                    .padding(.top, 8)
            }
            .font(.caption.weight(.semibold))
            .tint(accent)
            .frame(minHeight: 44)
        }
    }

    private var pointColumns: [PennyVisualizationColumn] {
        [.init(id: "label", title: "Item"), .init(id: "value", title: "Amount (\(unitLabel))")]
    }

    private func pointRows(_ points: [PennyVisualizationPoint]) -> [PennyVisualizationRow] {
        points.map { .init(id: $0.id, cells: [$0.label, visualization.unit.formatted($0.value)], referenceIDs: $0.referenceIDs) }
    }

    private func evidenceTable(columns: [PennyVisualizationColumn], rows: [PennyVisualizationRow]) -> some View {
        ScrollView(.horizontal) {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    ForEach(columns) { column in
                        Text(column.title)
                            .font(.caption.weight(.semibold))
                            .frame(minWidth: 100, maxWidth: 200, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                    }
                }
                ForEach(rows) { row in
                    GridRow {
                        ForEach(Array(row.cells.enumerated()), id: \.offset) { _, cell in
                            Text(cell)
                                .font(.caption)
                                .monospacedDigit()
                                .frame(minWidth: 100, maxWidth: 200, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(zip(columns, row.cells).map { "\($0.0.title): \($0.1)" }.joined(separator: ". "))
                }
            }
            .padding(.vertical, 4)
        }
        .accessibilityElement(children: .contain)
    }
}
