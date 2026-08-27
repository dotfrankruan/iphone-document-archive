import AppKit
import Testing
@testable import ReceiptArchive

@MainActor
@Test func exposesTheSelectorAppKitCallsAfterCapture() {
    let controller = ArchiveViewController()
    _ = controller.view

    #expect(controller.responds(to: NSSelectorFromString("readSelectionFromPasteboard:")))
}
