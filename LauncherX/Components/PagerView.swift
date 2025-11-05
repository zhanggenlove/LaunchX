//
//  PagerView.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//

import SwiftUI
import AppKit

struct PagerView: View {
    var pages: [PageItem]
    var iconsPerRow: Int
    var rowsPerPage: Int
    @Binding var pageIndex: Int
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(pages.indices, id: \ .self) { idx in
                    PageGridView(items: pages[idx].apps, iconsPerRow: iconsPerRow, rows: rowsPerPage)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .offset(x: -CGFloat(pageIndex) * geo.size.width)
            .offset(x: dragOffset)
            .gesture(
                DragGesture().updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let threshold = geo.size.width / 4
                    if value.translation.width < -threshold && pageIndex < max(0, pages.count-1) { pageIndex += 1 }
                    if value.translation.width > threshold && pageIndex > 0 { pageIndex -= 1 }
                }
            )
            .animation(.easeInOut(duration: 0.22), value: pageIndex)
        }
    }
}
