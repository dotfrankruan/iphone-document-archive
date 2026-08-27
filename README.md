# Receipt Archive

A small native macOS utility that uses Apple's built-in Continuity Camera. Your iPhone handles edge detection, perspective correction, and multi-page scanning; the utility names and files the result on your Mac.

Current version: **0.2.0**

## Use

1. Open `dist/Receipt Archive.app`.
2. Enter the category, title, and document date.
3. Select **Scan or Take Photo with iPhone**.
4. In the system menu, choose **Scan Documents** or **Take Photo** under your iPhone.
5. Complete the capture on your iPhone and select **Save**.

The default destination is `~/Documents/Receipt Archive/<year>/<date>/<category>/`. A document scan is stored as PDF and a photo as JPEG. A matching JSON sidecar records the capture time, category, and source.

## Continuity Camera requirements

- Your Mac and iPhone use the same Apple Account with two-factor authentication.
- Wi-Fi and Bluetooth are enabled on both devices, and the devices are nearby.
- Your iPhone is not sharing its cellular connection, and your Mac is not sharing its internet connection.
- If you use a VPN, it must allow local networking and Apple Continuity features.

## Build from source

Xcode Command Line Tools are required:

```sh
swift test --disable-sandbox
./scripts/build-app.sh
```

The app does not upload documents, use the network, or include third-party dependencies.
