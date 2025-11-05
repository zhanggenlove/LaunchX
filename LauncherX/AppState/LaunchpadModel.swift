//
//  LaunchpadModel.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//
import AppKit
import Combine
import SwiftUI

class LaunchpadModel: ObservableObject {
    static let shared = LaunchpadModel() // ✅ 单例实例

    @Published var pages: [PageItem] = []
    @Published var folders: [String: [AppItem]] = [:]
    @Published var allApps: [AppItem] = []
    @Published var query: String = ""
    @Published var iconsPerRow: Int = 7
    @Published var rowsPerPage: Int = 5
    @Published var isPresented: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private init() {
        $query
            .debounce(for: .milliseconds(120), scheduler: DispatchQueue.main)
            .sink { _ in }
            .store(in: &cancellables)
    }

    func reloadApps() {
        DispatchQueue.global(qos: .userInitiated).async {
            let apps = self.scanApplications()
            let systemApps = apps.filter { $0.path.hasPrefix("/System/") }
            let normalApps = apps.filter { !$0.path.hasPrefix("/System/") }

            // ✅ 系统工具文件夹
            let systemFolder = AppItem(
                name: "系统工具",
                path: "",
                bundleIdentifier: "system.tools.folder",
                category: "系统",
                isFolder: true,
                apps: systemApps
            )
            let finalApps = [systemFolder] + normalApps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            DispatchQueue.main.async {
                self.allApps = finalApps
                self.buildPages()
            }
        }
    }

    private func scanApplications() -> [AppItem] {
        var results: [AppItem] = []
        // 📂 扫描路径增加系统目录
        let paths = [
            "/Applications",
            NSHomeDirectory() + "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            "/System/Library/CoreServices/Applications",
        ]
        for base in paths {
            guard let enumerator = FileManager.default.enumerator(atPath: base) else { continue }
            for case let file as String in enumerator {
                if file.hasSuffix(".app") {
                    let full = (base as NSString).appendingPathComponent(file)
                    // ensure top-level .app only (avoid nested)
                    if full.components(separatedBy: "/").contains(".app") == false { }
                    let bundle = Bundle(path: full)
                    let name = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                        ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
                        ?? ((file as NSString).lastPathComponent.replacingOccurrences(of: ".app", with: ""))
                    let bundleId = bundle?.bundleIdentifier
                    let category = inferCategory(bundle: bundle)
                    let item = AppItem(name: name, path: full, bundleIdentifier: bundleId, category: category, apps: [])
                    results.append(item)
                    // skip deeper enumerations into .app
                    enumerator.skipDescendants()
                }
            }
        }
        return results
    }

    private func inferCategory(bundle: Bundle?) -> String? {
        // crude inference: use LSApplicationCategoryType if available
        if let cat = bundle?.object(forInfoDictionaryKey: "LSApplicationCategoryType") as? String {
            return cat
        }
        // fallback by bundle identifier keywords
        if let id = bundle?.bundleIdentifier {
            switch id {
            case _ where id.contains("com.apple.Safari") || id.contains("browser"):
                return "浏览器"
            case _ where id.contains("music") || id.contains("apple.Music"):
                return "音乐"
            case _ where id.contains("weibo") || id.contains("wechat") || id.contains("chat"):
                return "社交"
            default:
                return nil
            }
        }
        return nil
    }

    func buildPages() {
        let items: [AppItem]
        if query.isEmpty {
            items = allApps
        } else {
            items = allApps.filter { $0.name.localizedCaseInsensitiveContains(query) || ($0.bundleIdentifier?.localizedCaseInsensitiveContains(query) ?? false) }
        }
        let perPage = iconsPerRow * rowsPerPage
        var pages: [PageItem] = []
        var current: [AppItem] = []
        for item in items {
            current.append(item)
            if current.count == perPage {
                let page = PageItem(apps: current)
                pages.append(page)
                current = []
            }
        }
        if !current.isEmpty { pages.append(PageItem(apps: current)) }
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.18)) {
                self.pages = pages
            }
        }
    }

    // folder mgmt
    func createFolder(name: String, with apps: [AppItem]) {
        folders[name] = apps
        saveState()
    }

    func saveState() {
        // persist folders only for starter
        if let data = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(data, forKey: "LaunchpadFolders")
        }
    }

    func loadState() {
        if let data = UserDefaults.standard.data(forKey: "LaunchpadFolders"), let dict = try? JSONDecoder().decode([String: [AppItem]].self, from: data) {
            folders = dict
        }
    }
}
