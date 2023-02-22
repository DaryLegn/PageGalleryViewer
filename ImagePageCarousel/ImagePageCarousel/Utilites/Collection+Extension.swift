//
//  Collection+Extension.swift
//  GalleryCarousel
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}
