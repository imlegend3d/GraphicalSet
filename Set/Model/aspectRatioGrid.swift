//
//  aspectRatioGrid.swift
//  Set
//
//  Created by David on 2019-09-11.
//  Copyright © 2019 David. All rights reserved.
//

import UIKit

struct aspectRatioGrid {
    
    private var bounds: CGRect { didSet { calculatedGrid()} }

    private var noOfFrames: Int { didSet { calculatedGrid()} }
    
    static var idealAspectRatio: CGFloat = 0.7
    
    private struct GridDimensions: Comparable {
        var cols: Int
        var rows: Int
        var frameSize: CGSize
        var aspectRatio: CGFloat {
            return frameSize.width / frameSize.height
        }
        
        func isCloserToIdeal(aspectRatio: CGFloat) -> Bool{
            return (aspectRatioGrid.idealAspectRatio - aspectRatio).abs < (aspectRatioGrid.idealAspectRatio - self.aspectRatio).abs
        }
        
        static func <(lhs: aspectRatioGrid.GridDimensions, rhs: aspectRatioGrid.GridDimensions) -> Bool {
            return lhs.isCloserToIdeal(aspectRatio: rhs.aspectRatio)
        }
        
        static func == (lhs: aspectRatioGrid.GridDimensions, rhs: aspectRatioGrid.GridDimensions) ->Bool {
            return lhs.cols == rhs.cols && lhs.rows == rhs.rows
        }
        
        
    }
    
    private var bestGridDimensions: GridDimensions?
    
    private mutating func calculateGridDimensions() {
        for cols in 1...noOfFrames {
            let rows = noOfFrames % cols == 0 ? noOfFrames/cols : noOfFrames/cols + 1
            let calculatedFrameDimension = GridDimensions(cols: cols, rows: rows, frameSize: CGSize(width: bounds.width/CGFloat(cols), height: bounds.height/CGFloat(rows)))
            
            if let bestFrameDimension = bestGridDimensions, bestFrameDimension > calculatedFrameDimension {
                return
            } else {
                self.bestGridDimensions = calculatedFrameDimension
            }
        }
        return
    }
    
    private var cellFrames: [CGRect] = []
    
    private mutating func calculatedGrid() {
        var grid = [CGRect]()
        calculateGridDimensions()
        guard let bestGridDimensions = bestGridDimensions else {
            grid = []
            return
        }
        
        for row in 0..<bestGridDimensions.rows {
            for col in 0..<bestGridDimensions.cols {
                let origin = CGPoint(x: CGFloat(col) * bestGridDimensions.frameSize.width, y: CGFloat(row) * bestGridDimensions.frameSize.height)
                let rect = CGRect(origin: origin, size: bestGridDimensions.frameSize)
                grid.append(rect)
            }
        }
        self.cellFrames = grid
    }
    
    init(for bounds: CGRect, withNoOfFrames: Int, forIdeal aspectRatio: CGFloat = aspectRatioGrid.idealAspectRatio) {
        self.bounds = bounds
        self.noOfFrames = withNoOfFrames
        aspectRatioGrid.idealAspectRatio = aspectRatio
        calculatedGrid()
    }
    
    subscript(index: Int) -> CGRect? {
        return index < cellFrames.count ? cellFrames[index] : nil 
    }
}


extension CGFloat {
    var abs: CGFloat {
        return self<0 ? -self : self
    }
}
