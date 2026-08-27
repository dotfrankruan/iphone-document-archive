import AppKit
import Foundation
import Testing
@testable import ReceiptArchive

@MainActor
@Test func archivesPDFAndMetadataIntoDateHierarchy() throws {
    let manager = ArchiveManager()
    let originalRoot = manager.rootURL
    let temporaryRoot = FileManager.default.temporaryDirectory
        .appending(path: "ReceiptArchiveTests-\(UUID().uuidString)", directoryHint: .isDirectory)
    manager.rootURL = temporaryRoot
    defer {
        manager.rootURL = originalRoot
        try? FileManager.default.removeItem(at: temporaryRoot)
    }

    let minimalPDF = Data("%PDF-1.4\n%%EOF\n".utf8)

    var components = DateComponents()
    components.calendar = Calendar(identifier: .gregorian)
    components.timeZone = TimeZone(secondsFromGMT: 0)
    components.year = 2026
    components.month = 8
    components.day = 27
    let date = try #require(components.date)

    let saved = try manager.archive(
        document: CapturedDocument(data: minimalPDF, fileExtension: "pdf"),
        category: "Bank/Slip",
        title: "Transfer:001",
        date: date
    )

    #expect(saved.lastPathComponent == "2026-08-27-Bank-Slip-Transfer-001.pdf")
    #expect(saved.path.contains("/2026/2026-08-27/Bank-Slip/"))
    #expect(FileManager.default.fileExists(atPath: saved.path))
    #expect(FileManager.default.fileExists(atPath: saved.deletingPathExtension().appendingPathExtension("json").path))
    #expect(try Data(contentsOf: saved) == minimalPDF)
}
