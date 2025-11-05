//
//  AppItem.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//
import Foundation
import AppKit

struct PageItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var apps: [AppItem]
}

struct AppItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String
    var path: String
    var bundleIdentifier: String?
    var category: String?
    var isFolder: Bool = false
    var apps: [AppItem]
}


class IconCache {
    static let shared = IconCache()
    let cacheDir: URL
    init() {
        let fm = FileManager.default
        let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("LaunchpadSwiftUI/icons", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        cacheDir = dir
    }
    func iconURL(for app: AppItem) -> URL? {
        let name = (app.bundleIdentifier ?? app.path).replacingOccurrences(of: "/", with: "_")
        return cacheDir.appendingPathComponent(name).appendingPathExtension("png")
    }
    func iconImage(for app: AppItem, size: CGSize = CGSize(width: 128, height: 128)) -> NSImage {
        if let url = iconURL(for: app), FileManager.default.fileExists(atPath: url.path), let img = NSImage(contentsOf: url) {
            return img
        }
        let workspace = NSWorkspace.shared
        let icon = workspace.icon(forFile: app.path)
        let resized = icon.resized(to: NSSize(width: size.width, height: size.height))
        if let url = iconURL(for: app), let tiff = resized.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: url)
        }
        return resized
    }
}
