//
//  PageControl.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/24.
//

import SwiftUI

struct CustomPageControl: View {
    // MARK: - Properties
     var currentPage: Int
//    var test: Int
    let numberOfPages: Int
    var onPageChange: ((Int) -> ())?
    
    // Appearance properties
    private let dotSize: CGFloat = 6.0
    private let dotSpacing: CGFloat = 8.0
    private let selectedDotScale: CGFloat = 1.2
    private let normalDotColor: Color = .gray
    private let selectedDotColor: Color = .white
    private let animationDuration: Double = 0.2
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? selectedDotColor : normalDotColor)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(index == currentPage ? selectedDotScale : 1.0)
                    .animation(.easeInOut(duration: animationDuration), value: currentPage)
                    .onTapGesture {
                        print("wqwqwq: ", index)
                        onPageChange?(index)
                    }
            }
        }
        .padding(.horizontal, dotSpacing)
        .accessibilityLabel("Page Control, page \(currentPage + 1) of \(numberOfPages)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
struct CustomPageControl_Previews: PreviewProvider {
    static var previews: some View {
        CustomPageControl(currentPage: 1, numberOfPages: 5)
            .padding()
            .background(Color.black.opacity(0.2))
            .previewLayout(.sizeThatFits)
    }
}
