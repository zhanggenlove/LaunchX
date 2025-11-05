//
//  LaunchpadRootView.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//
import AppKit
import SwiftUI

struct LaunchpadRootView: View {
    @EnvironmentObject var model: LaunchpadModel
    @State private var pageIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    @FocusState private var isFocused: Bool
    @State private var isClosing: Bool = false // 👈 控制关闭动画
    
    let duration = 0.5

    // 动态获取安全区顶部间距 TODO 有时候获取不到 这个padding
    /// 获取当前显示 Launchpad 的窗口的安全区顶部间距
    func safeTopPadding() -> CGFloat {
        guard let window = NSApp.keyWindow,
              let screen = window.screen else {
            // 如果窗口还没出现，用 NSScreen.main 兜底
            let topInset = NSScreen.main?.safeAreaInsets.top ?? 0
            print("动态获取安全区顶部间距1: \(topInset)")
            if topInset == 0 {
                // 提前返回一个大致的默认值，MacBook 刘海屏通常为 32
                return 32
            }
            return topInset
        }
        let topInset = screen.safeAreaInsets.top
        print("动态获取安全区顶部间距2: \(topInset)")
        if topInset == 0 {
            // 兜底逻辑：刘海屏一般为 44
            return 32
        }
        return topInset
    }
    
    func hideLaunchpad(animated: Bool = true) {
        if animated {
            withAnimation(.easeInOut(duration: duration)) {
                isClosing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                LaunchpadWindowManager.shared.hide()
                isClosing = false
            }
        } else {
            LaunchpadWindowManager.shared.hide()
        }
    }

    var body: some View {
        ZStack {
            // 背景模糊层
            VisualEffectView(material: .hudWindow)
                .opacity(isClosing ? 0 : 1)
                .blur(radius: isClosing ? 8 : 0)
                .animation(.easeInOut(duration: duration), value: isClosing)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                Color.clear
                    .frame(height: safeTopPadding() + 20)

                // 搜索框
                HStack {
                    CenteredSearchField(text: $model.query)
                }
                .frame(width: 240)
                .background(.ultraThinMaterial)
                .cornerRadius(6)
                .opacity(isClosing ? 0 : 1)
                .scaleEffect(isClosing ? 0.95 : 1)
                .animation(.easeInOut(duration: duration), value: isClosing)
                Spacer()
                // 分页视图
                CustomPagingSlider(data: $model.pages) { $item in
                    PageGridView(items: item.apps, iconsPerRow: 7, rows: 5)
                        .background(.clear)
                        .scaleEffect(isClosing ? 0.9 : 1)
                        .opacity(isClosing ? 0 : 1)
                        .animation(.easeInOut(duration: duration), value: isClosing)
                }
                .background(.clear)
            }
            .onTapGesture {
                hideLaunchpad(animated: true)
            }
            .background(.clear)
            .padding(.bottom, 20)
            .onChange(of: model.query) { _, _ in model.buildPages() }
            .onAppear { model.buildPages() }
            .onReceive(model.$pages) { _ in
                if pageIndex >= model.pages.count {
                    pageIndex = max(0, model.pages.count - 1)
                }
            }
        }
        .scaleEffect(isClosing ? 0.9 : 1)
        .opacity(isClosing ? 0 : 1)
        .animation(.easeInOut(duration: duration), value: isClosing)
        .ignoresSafeArea()
    }
}
