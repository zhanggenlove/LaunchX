//
//  Extension+NSImage.swift
//  LauncherX
//
//  Created by zhanggen on 2025/10/20.
//

import AppKit

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage {
        let img = NSImage(size: newSize)
        img.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: newSize), from: .zero, operation: .copy, fraction: 1.0)
        img.unlockFocus()
        return img
    }
}
