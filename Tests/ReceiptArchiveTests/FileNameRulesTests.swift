import Testing
@testable import ReceiptArchive

@Test func sanitizesUnsafeCharacters() {
    #expect(FileNameRules.safeComponent("Bank/Slip:  001", fallback: "Other") == "Bank-Slip- 001")
}

@Test func usesFallbackForEmptyNames() {
    #expect(FileNameRules.safeComponent(" / : ", fallback: "Untitled") == "Untitled")
}

@Test func limitsLongNames() {
    let value = String(repeating: "A", count: 100)
    #expect(FileNameRules.safeComponent(value, fallback: "Untitled").count == 80)
}
