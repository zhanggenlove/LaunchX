//
//  CenteredSearchField.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/28.
//
import SwiftUI

struct CenteredSearchField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false

    var body: some View {
        ZStack {
            // 居中显示的 placeholder + icon（仅当为空时显示）
            if text.isEmpty && !isFocused {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Text("搜索")
                        .foregroundColor(.secondary)
                }
                .font(.system(size: 14))
            }

            // 实际的输入框
            HStack(spacing: 6) {
                if !(text.isEmpty && !isFocused) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                }
                TextField("", text: $text, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = editing
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .frame(height: 32)
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            DispatchQueue.main.async {
                NSApplication.shared.keyWindow?.makeFirstResponder(nil)
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 10)
    }
}
