//
//  Coordinator.swift
//  GalleryCarousel
//

import UIKit

// MARK: - App Coordinator

final class Coordinator {

    var navigationController: UINavigationController

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    var imagesArrayData = [UIImage]()

    func start() {
        setUpImagesArray()

        showGalleryPageView(imagesArrayData)
    }

    func setUpImagesArray(){
        guard let imageOne = UIImage(named: "one"),
              let imageTwo = UIImage(named: "two"),
              let imageThree = UIImage(named: "three"),
              let imageFour = UIImage(named: "four") else { return }

        imagesArrayData = [imageOne, imageTwo, imageThree, imageFour, ]
    }
}
// MARK: - GalleryCarouselViewModuleOutput

extension Coordinator: GalleryCarouselViewModuleOutput {

    func showGalleryPageView(_ imagesArrayData: [UIImage]) {
        let (view, viewModel) = GalleryCarouselViewConfigure.configure(router: self)
        viewModel.setup(imageDataArray: imagesArrayData)
        navigationController.pushViewController(view, animated: true)
    }
}
