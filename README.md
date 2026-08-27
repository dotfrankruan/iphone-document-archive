# Receipt Archive

Receipt Archive is a small native macOS application for filing invoices, receipts, bank slips, and other paper documents with an iPhone.

It uses Apple's built-in Continuity Camera rather than implementing its own scanner. The iPhone performs edge detection, perspective correction, and multi-page capture; the Mac application names and stores the returned PDF or photo.

## Features

- Native **Scan Documents** and **Take Photo** actions from a nearby iPhone or iPad
- Multi-page document scans saved as a single PDF
- Photos saved as JPEG
- Filing by document date and category
- Collision-safe filenames
- JSON sidecars containing capture metadata
- Configurable archive location
- No cloud service, network upload, analytics, or third-party dependency

## Requirements

- macOS 14 or later
- Xcode Command Line Tools
- An iPhone or iPad that supports Continuity Camera
- The Mac and mobile device signed in to the same Apple Account
- Wi-Fi and Bluetooth enabled on both devices

The devices should be nearby. VPN, internet sharing, or network filtering can interfere with Continuity Camera discovery.

## Build and run

The repository contains source code, not a prebuilt application. Build it locally before opening it:

```sh
git clone git@github.com:dotfrankruan/iphone-document-archive.git
cd iphone-document-archive
make run
```

`make run` builds an ad-hoc-signed application at:

```text
dist/Receipt Archive.app
```

The build is intended for local use and is not notarized for redistribution through Apple.

## Use

1. Choose a category, enter a title, and set the document date.
2. Optionally use **Change…** to select a different archive location.
3. Select **Scan or Take Photo with iPhone**.
4. Under the detected device, choose **Scan Documents** or **Take Photo**.
5. Complete the capture on the iPhone and select **Save**.
6. Use **Show in Finder** to reveal the archived file.

The default archive location is:

```text
~/Documents/Receipt Archive/
```

Files are organized as follows:

```text
Receipt Archive/
└── 2026/
    └── 2026-08-27/
        └── Invoice/
            ├── 2026-08-27-Invoice-Office-supplies.pdf
            └── 2026-08-27-Invoice-Office-supplies.json
```

If a filename already exists, the application appends `-2`, `-3`, and so on instead of overwriting it.

## Development commands

```sh
make help       # List available commands
make test       # Run all tests
make build      # Build and ad-hoc sign the application
make run        # Build and open the application
make check      # Test, build, and validate the app bundle
make package    # Create dist/Receipt-Archive-macOS.zip
make clean      # Remove generated files
```

Generated `.build/`, `work/`, and `dist/` content is intentionally excluded from Git.

## Privacy

Captured files are written directly to the selected local folder. Receipt Archive does not upload documents, contact a server, or store a copy on the iPhone. Documents and their JSON sidecars should never be committed to this repository.

## Troubleshooting

If the iPhone does not appear:

1. Confirm that both devices use the same Apple Account.
2. Enable Wi-Fi and Bluetooth on both devices.
3. Move the devices closer together.
4. Disable Personal Hotspot or Internet Sharing.
5. Check whether a VPN or firewall blocks local networking or Apple Continuity features.

If a scan completes but no file appears, confirm that the selected archive folder is writable and check the status message at the bottom of the application window.

## Version

Current application version: **0.2.0**

## License

Copyright 2026 Frank Ruan.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.
