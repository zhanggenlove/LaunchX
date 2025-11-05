//
//  PageGridView.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//
import AppKit
import SwiftUI

struct PageGridView: View {
    var items: [AppItem]
    var iconsPerRow: Int
    var rows: Int

    var body: some View {
        let perPage = iconsPerRow * rows
        let display = items.prefix(perPage)
        GeometryReader { geo in
            let width = geo.size.width / CGFloat(iconsPerRow)
            let height = geo.size.height / CGFloat(rows)
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \ .self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<iconsPerRow, id: \ .self) { c in
                            let index = r * iconsPerRow + c
                            if index < display.count {
                                AppIconView(item: Array(display)[index])
                                    .frame(width: width, height: height)
                            } else {
                                Color.clear.frame(width: width, height: height)
                            }
                        }
                    }.background(.clear)
                }
            }.background(.clear)
        }
    }
}
