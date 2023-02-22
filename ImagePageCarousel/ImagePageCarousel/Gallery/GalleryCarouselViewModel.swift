//
//  GalleryPageViewModel.swift
//  posca
//

import UIKit

protocol GalleryCarouselViewModuleInput: AnyObject {
    func setup(imageDataArray: [UIImage])
}

protocol GalleryCarouselViewModuleOutput { }

// MARK: - GalleryPageViewProtocol

protocol GalleryCarouselViewProtocol {

    var imageDataArray: [UIImage] { get }
    var index: Int { get set }
}

final class GalleryCarouselViewModel: GalleryCarouselViewProtocol, GalleryCarouselViewModuleInput {

    var imageDataArray: [UIImage] = []
    var index: Int = 0

    // MARK: - Dependencies

    var router: GalleryCarouselViewModuleOutput?

    // MARK: - GalleryPageViewProtocol

    func setup(imageDataArray: [UIImage]) {
        self.imageDataArray = imageDataArray
    }
}
