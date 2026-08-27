import AppKit
import UniformTypeIdentifiers

@MainActor
final class ArchiveViewController: NSViewController, NSTextFieldDelegate {
    private let archiveManager = ArchiveManager()

    private let categoryPopup = NSPopUpButton()
    private let titleField = NSTextField()
    private let datePicker = NSDatePicker()
    private let rootLabel = NSTextField(labelWithString: "")
    private let scanButton = NSButton()
    private let statusLabel = NSTextField(wrappingLabelWithString: "Enter the archive details, then use your iPhone. A multi-page scan is saved as one PDF.")
    private let revealButton = NSButton(title: "Show in Finder", target: nil, action: nil)
    private var lastSavedURL: URL?

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 620, height: 490))
        preferredContentSize = view.frame.size
        buildInterface()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(self)
    }

    private func buildInterface() {
        let title = NSTextField(labelWithString: "Receipt Archive")
        title.font = .systemFont(ofSize: 25, weight: .bold)

        let subtitle = NSTextField(wrappingLabelWithString: "Use Apple's Continuity Camera for automatic edge detection, perspective correction, and multi-page scanning on your iPhone.")
        subtitle.textColor = .secondaryLabelColor
        subtitle.font = .systemFont(ofSize: 13)

        categoryPopup.addItems(withTitles: ["Invoice", "Receipt", "Bank Slip", "Contract / Certificate", "Other"])
        categoryPopup.controlSize = .large

        titleField.placeholderString = "For example: August bank transfer slip"
        titleField.controlSize = .large
        titleField.delegate = self

        datePicker.datePickerElements = [.yearMonthDay]
        datePicker.datePickerStyle = .textFieldAndStepper
        datePicker.controlSize = .large
        datePicker.dateValue = Date()

        rootLabel.stringValue = archiveManager.rootURL.path
        rootLabel.lineBreakMode = .byTruncatingMiddle
        rootLabel.textColor = .secondaryLabelColor
        rootLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)

        let chooseRoot = NSButton(title: "Change…", target: self, action: #selector(chooseArchiveRoot))
        chooseRoot.bezelStyle = .rounded

        let rootRow = NSStackView(views: [rootLabel, chooseRoot])
        rootRow.orientation = .horizontal
        rootRow.spacing = 10
        rootLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let form = NSGridView(views: [
            [formLabel("Category"), categoryPopup],
            [formLabel("Title"), titleField],
            [formLabel("Document date"), datePicker],
            [formLabel("Archive location"), rootRow]
        ])
        form.rowSpacing = 14
        form.columnSpacing = 16
        form.column(at: 0).xPlacement = .trailing
        form.column(at: 1).xPlacement = .fill

        scanButton.title = "Scan or Take Photo with iPhone"
        scanButton.target = self
        scanButton.action = #selector(showContinuityCameraMenu(_:))
        scanButton.bezelStyle = .rounded
        scanButton.controlSize = .large
        scanButton.font = .systemFont(ofSize: 15, weight: .semibold)
        scanButton.keyEquivalent = "\r"

        revealButton.target = self
        revealButton.action = #selector(revealLastFile)
        revealButton.isHidden = true

        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .center
        statusLabel.font = .systemFont(ofSize: 12)

        let actions = NSStackView(views: [scanButton, revealButton])
        actions.orientation = .horizontal
        actions.alignment = .centerY
        actions.spacing = 10

        let stack = NSStackView(views: [title, subtitle, form, actions, statusLabel])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        subtitle.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        form.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        actions.alignment = .centerX
        actions.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        statusLabel.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 34),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -28),
            categoryPopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            titleField.widthAnchor.constraint(greaterThanOrEqualToConstant: 360),
            rootRow.widthAnchor.constraint(greaterThanOrEqualToConstant: 360)
        ])
    }

    private func formLabel(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        return label
    }

    @objc private func showContinuityCameraMenu(_ sender: NSButton) {
        view.window?.makeFirstResponder(self)
        guard let fileMenu = NSApp.mainMenu?.items.first(where: { $0.submenu?.title == "File" })?.submenu,
              let cameraItem = fileMenu.items.first(where: { $0.identifier == NSMenuItem.importFromDeviceIdentifier }) else {
            statusLabel.stringValue = "Continuity Camera is not available. Try the File menu."
            statusLabel.textColor = .systemOrange
            return
        }
        let origin = NSPoint(x: 0, y: sender.bounds.height + 4)
        fileMenu.popUp(positioning: cameraItem, at: origin, in: sender)
    }

    @objc private func chooseArchiveRoot() {
        let panel = NSOpenPanel()
        panel.title = "Choose an Archive Folder"
        panel.prompt = "Choose"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.directoryURL = archiveManager.rootURL
        guard panel.runModal() == .OK, let url = panel.url else { return }
        archiveManager.rootURL = url
        rootLabel.stringValue = url.path
    }

    @objc private func revealLastFile() {
        if let lastSavedURL {
            NSWorkspace.shared.activateFileViewerSelecting([lastSavedURL])
        }
    }

    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
        guard let returnType else {
            return super.validRequestor(forSendType: sendType, returnType: returnType)
        }
        if returnType == .pdf || NSImage.imageTypes.contains(returnType.rawValue) {
            return self
        }
        return super.validRequestor(forSendType: sendType, returnType: returnType)
    }

    @objc(readSelectionFromPasteboard:)
    func readSelection(from pasteboard: NSPasteboard) -> Bool {
        do {
            let url = try archiveManager.archive(
                pasteboard: pasteboard,
                category: categoryPopup.titleOfSelectedItem ?? "Other",
                title: titleField.stringValue,
                date: datePicker.dateValue
            )
            lastSavedURL = url
            statusLabel.stringValue = "Archived: \(url.lastPathComponent)"
            statusLabel.textColor = .systemGreen
            revealButton.isHidden = false
            titleField.stringValue = ""
            NSSound(named: "Glass")?.play()
            return true
        } catch {
            statusLabel.stringValue = error.localizedDescription
            statusLabel.textColor = .systemRed
            NSSound.beep()
            return false
        }
    }
}
