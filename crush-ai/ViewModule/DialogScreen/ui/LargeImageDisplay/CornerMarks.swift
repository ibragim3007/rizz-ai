//
//  CornerMarks.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/25/25.
//

import SwiftUI


struct CornerMarks: Shape {
    var cornerRadius: CGFloat
    var inset: CGFloat = 6
    var length: CGFloat = 24
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = cornerRadius
        _ = r // зарезервировано на случай будущей логики, сейчас не влияет на форму
        
        // Top-left
        p.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset + length))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.minX + inset + length, y: rect.minY + inset))
        
        // Top-right
        p.move(to: CGPoint(x: rect.maxX - inset - length, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset + length))
        
        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset - length))
        p.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.maxX - inset - length, y: rect.maxY - inset))
        
        // Bottom-left
        p.move(to: CGPoint(x: rect.minX + inset + length, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
        p.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset - length))
        
        return p
    }
}
