import AppKit
import Foundation

struct ArchiveRecord: Codable, Sendable {
    let capturedAt: Date
    let category: String
    let title: String
    let fileName: String
    let source: String
}

struct CapturedDocument: Sendable {
    let data: Data
    let fileExtension: String
}

enum ArchiveError: LocalizedError {
    case unsupportedPasteboard
    case cannotEncodeImage

    var errorDescription: String? {
        switch self {
        case .unsupportedPasteboard:
            return "The system did not return a supported PDF or image."
        case .cannotEncodeImage:
            return "The photo could not be converted to JPEG."
        }
    }
}

enum FileNameRules {
    static func safeComponent(_ value: String, fallback: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/:\\?%*|\"<>\n\r\t")
        let pieces = value.components(separatedBy: forbidden)
        var joined = pieces.joined(separator: "-")
        while joined.contains("--") {
            joined = joined.replacingOccurrences(of: "--", with: "-")
        }
        let collapsed = joined
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .trimmingCharacters(in: CharacterSet(charactersIn: ". -"))
        return collapsed.isEmpty ? fallback : String(collapsed.prefix(80))
    }
}

@MainActor
final class ArchiveManager {
    static let rootDefaultsKey = "archiveRoot"

    private let fileManager = FileManager.default
    private let defaults = UserDefaults.standard

    var rootURL: URL {
        get {
            if let stored = defaults.string(forKey: Self.rootDefaultsKey) {
                return URL(fileURLWithPath: stored, isDirectory: true)
            }
            return fileManager.homeDirectoryForCurrentUser
                .appending(path: "Documents", directoryHint: .isDirectory)
                .appending(path: "Receipt Archive", directoryHint: .isDirectory)
        }
        set { defaults.set(newValue.path, forKey: Self.rootDefaultsKey) }
    }

    func archive(pasteboard: NSPasteboard, category: String, title: String, date: Date) throws -> URL {
        let document = try capturedDocument(from: pasteboard)
        return try archive(document: document, category: category, title: title, date: date)
    }

    func archive(document: CapturedDocument, category: String, title: String, date: Date) throws -> URL {
        let safeCategory = FileNameRules.safeComponent(category, fallback: "Other")
        let safeTitle = FileNameRules.safeComponent(title, fallback: "Untitled")
        let calendar = Calendar(identifier: .gregorian)
        let year = String(calendar.component(.year, from: date))
        let day = Self.dayFormatter.string(from: date)
        let destination = rootURL
            .appending(path: year, directoryHint: .isDirectory)
            .appending(path: day, directoryHint: .isDirectory)
            .appending(path: safeCategory, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)

        let baseName = "\(day)-\(safeCategory)-\(safeTitle)"
        let savedURL = try writeUnique(
            document.data,
            baseName: baseName,
            extension: document.fileExtension,
            to: destination
        )

        let record = ArchiveRecord(
            capturedAt: Date(),
            category: safeCategory,
            title: safeTitle,
            fileName: savedURL.lastPathComponent,
            source: "Apple Continuity Camera"
        )
        try writeMetadata(record, beside: savedURL)
        return savedURL
    }

    private func capturedDocument(from pasteboard: NSPasteboard) throws -> CapturedDocument {
        if let pdfData = pasteboard.data(forType: .pdf) {
            return CapturedDocument(data: pdfData, fileExtension: "pdf")
        }
        if let image = NSImage(pasteboard: pasteboard) {
            guard let tiff = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiff),
                  let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
                throw ArchiveError.cannotEncodeImage
            }
            return CapturedDocument(data: jpeg, fileExtension: "jpg")
        }
        throw ArchiveError.unsupportedPasteboard
    }

    private func writeUnique(_ data: Data, baseName: String, extension fileExtension: String, to directory: URL) throws -> URL {
        var candidate = directory.appending(path: "\(baseName).\(fileExtension)")
        var sequence = 2
        while fileManager.fileExists(atPath: candidate.path) {
            candidate = directory.appending(path: "\(baseName)-\(sequence).\(fileExtension)")
            sequence += 1
        }
        try data.write(to: candidate, options: .atomic)
        return candidate
    }

    private func writeMetadata(_ record: ArchiveRecord, beside fileURL: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(record)
        let metadataURL = fileURL.deletingPathExtension().appendingPathExtension("json")
        try data.write(to: metadataURL, options: .atomic)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
