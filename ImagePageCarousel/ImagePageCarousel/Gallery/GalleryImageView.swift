//
//  GalleryImageView.swift
//  GalleryCarousel
//

import UIKit

final class GalleryImageView: UIViewController {

    var imageIndex: Int = 0
    var isZoomed: Bool {
        imageView.image != nil && scrollView.zoomScale > scrollView.minimumZoomScale
    }

    var imageData: UIImage? {
        didSet {
            if let imageData {
                imageView.image = imageData
            }
        }
    }

    private var controlsDisplayed: Bool?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        return scrollView
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .gray

        let closeIcon = UIImage(named: "close")
        button.setImage(closeIcon, for: .normal)

        button.backgroundColor = .white

        return button
    }()

    private lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate(layoutConstraints)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if imageView.image != nil {
            setZoomScale()
            updateZoomSettings(scrollView)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.setZoomScale()
            self.updateZoomSettings(self.scrollView)
        }, completion: { [weak self] _ in
            guard let self else { return }

            self.updateZoomStatus(inZoomMode: self.scrollView.zoomScale > self.scrollView.minimumZoomScale + 0.05)
        })
    }

    func configure(imageIndex: Int) {
        self.imageIndex = imageIndex
    }

    /// Will return true if we are max zoomed out.
    func toggleZoom() {
        guard imageView.image != nil else { return }

        let scale = isZoomed ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        scrollView.setZoomScale(scale, animated: true)
    }

    private lazy var layoutConstraints: [NSLayoutConstraint] = {
        [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.8),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.8),
        ]
    }()

    func updateZoomStatus(inZoomMode: Bool) {
        controlsDisplayed = inZoomMode
    }
}

// MARK: - UIScrollViewDelegate

extension GalleryImageView: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateZoomSettings(scrollView)
    }

    func scrollViewWillBeginZooming(_: UIScrollView, with _: UIView?) {
        updateZoomStatus(inZoomMode: true)
    }

    func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale scale: CGFloat) {
        updateZoomStatus(inZoomMode: scale > scrollView.minimumZoomScale + 0.05)
    }
}

// MARK: - Helpers

private extension GalleryImageView {
    func setZoomScale() {
        guard imageView.image != nil, imageView.bounds.equalTo(.zero) == false else { return }

        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        let maxImageScale: CGFloat = 2.5

        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = scrollView.minimumZoomScale * maxImageScale
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    func updateZoomSettings(_ scrollView: UIScrollView) {
        guard imageView.image != nil,
              controlsDisplayed == false else { return }

        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        // This is for centering the image in the middle of the scrollview in case the image frame
        // is smaller then the scrollview bounds.
        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2.0)
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2.0)

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}

