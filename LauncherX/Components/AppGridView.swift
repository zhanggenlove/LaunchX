//
//  AppGridView.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/27.
//

import SwiftUI

struct AppGridView: View {
    let apps: [AppItem]
    @State private var isFolderOpen: UUID? = nil
    @State private var folderOffset: CGFloat = 0
    
    private let columns = 7
    private let rows = 5
    private let spacing: CGFloat = 20
    private let iconSize: CGFloat = 64
    
    var body: some View {
        VStack(spacing: spacing) {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(iconSize), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(apps) { app in
                    AppGridItemView(app: app, isFolderOpen: $isFolderOpen, folderOffset: $folderOffset)
                        .frame(width: iconSize, height: iconSize + 24) // Icon + text height
                }
                // Fill remaining slots with empty views to maintain 7x5 grid
                if apps.count < columns * rows {
                    ForEach((apps.count)..<(columns * rows), id: \.self) { _ in
                        Color.clear
                            .frame(width: iconSize, height: iconSize + 24)
                    }
                }
            }
            .frame(maxWidth: CGFloat(columns) * (iconSize + spacing) - spacing)
        }
        .background(Color.black.opacity(0.8))
        .overlay(
            folderView,
            alignment: .center
        )
    }
    
    @ViewBuilder
    private var folderView: some View {
        if let folderId = isFolderOpen, let folder = apps.first(where: { $0.id == folderId }) {
            FolderView(apps: folder.apps, offset: folderOffset)
                .offset(y: folderOffset > 0 ? -folderOffset : 0)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            folderOffset = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation {
                                    isFolderOpen = nil
                                    folderOffset = 0
                                }
                            } else {
                                withAnimation {
                                    folderOffset = 0
                                }
                            }
                        }
                )
        }
    }
}

/// A single grid item view for an app or folder.
struct AppGridItemView: View {
    let app: AppItem
    @Binding var isFolderOpen: UUID?
    @Binding var folderOffset: CGFloat
    
    private var icon: NSImage? {
        if app.isFolder {
            return NSImage(systemSymbolName: "folder", accessibilityDescription: app.name)
        }
        if let bundle = Bundle(path: app.path), let iconPath = bundle.path(forResource: "AppIcon", ofType: "icns") {
            return NSImage(contentsOfFile: iconPath)
        } else if let image = NSImage(contentsOfFile: app.path) {
            return image
        }
        return NSImage(systemSymbolName: "app", accessibilityDescription: app.name)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let nsImage = icon {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        Text(app.name.prefix(1))
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                    .shadow(radius: 2)
            }
            Text(app.name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if app.isFolder {
                withAnimation {
                    isFolderOpen = app.id
                }
            } else {
                print("Tapped \(app.name)")
                // Example: NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
            }
        }
    }
}

/// A view for displaying a folder's contents in a popup.
struct FolderView: View {
    let apps: [AppItem]
    let offset: CGFloat
    
    private let columns = 4
    private let spacing: CGFloat = 10
    private let iconSize: CGFloat = 48
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.9))
                .frame(width: CGFloat(columns) * (iconSize + spacing) - spacing + 20, height: 200)
                .shadow(radius: 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(iconSize), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(apps) { app in
                    VStack(spacing: 4) {
                        if let nsImage = NSImage(contentsOfFile: app.path) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: iconSize, height: iconSize)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    Text(app.name.prefix(1))
                                        .font(.title2)
                                        .foregroundColor(.white)
                                )
                        }
                        Text(app.name)
                            .font(.caption2)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .frame(width: iconSize)
                    .onTapGesture {
                        print("Opened folder app: \(app.name)")
                        // Example: NSWorkspace.shared.open(URL(fileURLWithPath: app.path))
                    }
                }
            }
            .padding(10)
        }
        .offset(y: -offset) // Move up with drag
    }
}
