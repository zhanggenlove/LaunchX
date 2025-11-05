//
//  AppIconView.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//
import AppKit
import SwiftUI

struct AppIconView: View {
    var item: AppItem
    @State private var hover = false
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 6) {
            if !item.isFolder {
                Image(nsImage: IconCache.shared.iconImage(for: item, size: CGSize(width: 96, height: 96)))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.black.opacity(hover ? 0.25 : 0.15),
                            radius: hover ? 8 : 3, y: hover ? 3 : 1)
                    .scaleEffect(pressed ? 0.95 : (hover ? 1.08 : 1))
                    .opacity(pressed ? 0.9 : 1)
                    .animation(.spring(response: 0.32, dampingFraction: 0.68, blendDuration: 0.25), value: hover)
                    .animation(.easeOut(duration: 0.12), value: pressed)
            } else {
                // ✅ 文件夹图标：模仿 macOS Launchpad 文件夹样式
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 74, height: 74)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 1)

                    // 内部小图标（前9个 App）
                    let icons = Array(item.apps.prefix(9))
                    let columns: [GridItem] = [
                        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
                    ]

                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(icons, id: \.id) { app in
                            Image(nsImage: IconCache.shared.iconImage(for: app, size: CGSize(width: 32, height: 32)))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(8)
                    .clipped()
                }
                .frame(width: 74, height: 74)
                .shadow(color: Color.black.opacity(hover ? 0.25 : 0.15),
                        radius: hover ? 8 : 3, y: hover ? 3 : 1)
                .scaleEffect(pressed ? 0.95 : (hover ? 1.08 : 1))
                .opacity(pressed ? 0.9 : 1)
                .animation(.spring(response: 0.32, dampingFraction: 0.68, blendDuration: 0.25), value: hover)
                .animation(.easeOut(duration: 0.12), value: pressed)
            }

            Text(item.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: 90)
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture(count: 1) {
            pressFeedback()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                LaunchpadWindowManager.shared.hide()
                NSWorkspace.shared.open(URL(fileURLWithPath: item.path))
            }
        }
        .onHover { v in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72, blendDuration: 0.25)) {
                hover = v
            }
        }
    }

    private func pressFeedback() {
        withAnimation(.easeOut(duration: 0.08)) {
            pressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.1)) {
                pressed = false
            }
        }
    }
}
