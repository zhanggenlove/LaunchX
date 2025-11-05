//
//  CustomPagingSlider.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/24.
//

import SwiftUI

struct CustomPagingSlider<Content: View, PageItem: RandomAccessCollection>: View where PageItem: MutableCollection, PageItem.Element: Identifiable {
    var titleScrollSpeed: CGFloat = 0.6
    var showsIndicator: ScrollIndicatorVisibility = .hidden
    var showPagingControl: Bool = true
    var pagingControlSpacing: CGFloat = 20
    var spacing: CGFloat = 10

    @State private var activeId: UUID?

    @Binding var data: PageItem
    @ViewBuilder var content: (Binding<PageItem.Element>) -> Content
    var body: some View {
        VStack(spacing: pagingControlSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach($data) { item in
                        VStack(spacing: 0) {
                            content(item)
                        }
                        .containerRelativeFrame(.horizontal)
                    }
                }.scrollTargetLayout()
                    .background(.clear)
            }.background(.clear)
            .scrollIndicators(showsIndicator)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $activeId)

            CustomPageControl(currentPage: activePage, numberOfPages: data.count) { index in
                if let index = index as? PageItem.Index, data.indices.contains(index) {
                    if let id = data[index].id as? UUID {
                        withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                            activeId = id
                        }
                    }
                }
            }
        }.background(.clear)
    }

    var activePage: Int {
        if let index = data.firstIndex(where: { $0.id as? UUID == activeId }) as? Int {
            print(index)
            return index
        }
        return 0
    }

    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        return minX * min(titleScrollSpeed, 1.0)
    }
}

// struct DemoView: View {
//    @State private var items: [PageItem] = [
//        .init(color: .red, title: "world clock", subTitle: "view the time in multiple cities around the world."),
//        .init(color: .blue, title: "world clock1", subTitle: "view the time in multiple cities around the world1."),
//        .init(color: .green, title: "world clock2", subTitle: "view the time in multiple cities around the world2."),
//        .init(color: .yellow, title: "world clock3", subTitle: "view the time in multiple cities around the world3.")
//    ]
//
//    var body: some View {
//        Text("1")
//        CustomPagingSlider(data: $items) { $item in
//            RoundedRectangle(cornerRadius: 15)
//                .fill(item.color.gradient)
//                .frame(width: 150, height: 120)
//        } titleContent: { $item in
//            VStack(spacing: 5) {
//                Text(item.title)
//                    .font(.largeTitle.bold())
//
//                Text(item.subTitle)
//                    .multilineTextAlignment(.center)
//                    .frame(height: 45)
//            }
//            .padding(.bottom, 35)
//        }
////        .safeAreaPadding([.horizontal, .top], 35)
//
//    }
//
// }
//
//
// #Preview {
//    DemoView()
// }
