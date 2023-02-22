//
//  GalleryPageConfigure.swift
//  posca
//

import UIKit

final class GalleryCarouselViewConfigure {
    static func configure(router: GalleryCarouselViewModuleOutput) -> (view: UIViewController, viewModel: GalleryCarouselViewModuleInput) {
        let view = GalleryCarouselView()
        let viewModel = GalleryCarouselViewModel()
        view.viewModel = viewModel
        viewModel.router = router

        return (view, viewModel)
    }
}
