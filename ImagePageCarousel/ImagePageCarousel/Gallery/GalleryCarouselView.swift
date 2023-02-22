//
//  GalleryCarouselView.swift
//  ImagePageCarousel
//

import UIKit

class GalleryCarouselView: UIViewController {

    // MARK: - Dependencies

    var viewModel: GalleryCarouselViewProtocol?

    // MARK: - UI

    private var pages = [UIViewController]()
    private var imagePageViewController: UIPageViewController!

    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var imageShevronLeftView: UIButton = {
        let button = UIButton()
        let icon = UIImage(named: "chevronLeft")
        button.setImage(icon, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var imageShevronRightView: UIButton = {
        let button = UIButton()
        let icon = UIImage(named: "chevronRight")
        button.setImage(icon, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black

        let closeIcon = UIImage(named: "close")
        button.setImage(closeIcon, for: .normal)

        return button
    }()

    private var imageProgressCount: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()

    private lazy var doubleTap: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()

    private lazy var singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(recognizer:)))

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configurePageViewController()

        NSLayoutConstraint.activate(layoutConstraints)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Setup

    private func setupUI() {
        [imageShevronRightView, imageShevronLeftView].compactMap { $0 }.forEach {
            $0.tintColor = .gray
        }
        if let images = viewModel?.imageDataArray.count {
            [imageShevronRightView, imageShevronLeftView, imageProgressCount].compactMap { $0 }.forEach {
                $0.isHidden = (images <= 1)
            }
        }

        view.addSubview(imageContainerView)
        view.addSubview(imageShevronLeftView)
        view.addSubview(imageShevronRightView)
        imageContainerView.addSubview(imageProgressCount)
        imageContainerView.addSubview(closeButton)
        view.backgroundColor = .white

        closeButton.addTarget(self, action: #selector(tappedCloseButton), for: .touchUpInside)
        imageShevronLeftView.addTarget(self, action: #selector(tappedLeftButton), for: .touchUpInside)
        imageShevronRightView.addTarget(self, action: #selector(tappedRightButton), for: .touchUpInside)

        imageContainerView.addGestureRecognizer(doubleTap)
        imageContainerView.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
    }

    private lazy var layoutConstraints: [NSLayoutConstraint] = {
        [
            imageContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            imageShevronLeftView.leadingAnchor.constraint(equalTo: imageContainerView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            imageShevronLeftView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageShevronLeftView.widthAnchor.constraint(equalToConstant: 20),
            imageShevronLeftView.heightAnchor.constraint(equalToConstant: 40),

            imageShevronRightView.trailingAnchor.constraint(equalTo: imageContainerView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            imageShevronRightView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            imageShevronRightView.widthAnchor.constraint(equalToConstant: 20),
            imageShevronRightView.heightAnchor.constraint(equalToConstant: 40),

            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -40),

            imageProgressCount.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            imageProgressCount.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: 40),

            imagePageViewController.view.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 80),
            imagePageViewController.view.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            imagePageViewController.view.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imagePageViewController.view.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
        ]
    }()

    private func configurePageViewController() {
        imagePageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        imagePageViewController.dataSource = self
        imagePageViewController.delegate = self

        imagePageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        guard let count = viewModel?.imageDataArray.count else { return }

        for index in 0 ... count { 
            guard let viewController = createImageViewController(index) else { return }
            pages.append(viewController)
        }

        imagePageViewController.setViewControllers([pages[viewModel?.index ?? 0]], direction: .forward, animated: true, completion: nil)
        if let currentIndex = viewModel?.index {
            imageProgressCount.text = "\(currentIndex + 1) / \(count)"
        }

        imageContainerView.addSubview(imagePageViewController.view)
        imagePageViewController.didMove(toParent: self)
    }

    private func updateCurrentVisibleImage(_ imageView: GalleryImageView) {
        let index = imageView.imageIndex
        if let imageData = viewModel?.imageDataArray {
            imageProgressCount.text = "\(index + 1) / \(imageData.count)"
        }
    }

    // MARK: - Actions

    @objc private func singleTapAction(recognizer _: UITapGestureRecognizer) {
        guard let currentViewController = imagePageViewController.viewControllers?.first as? GalleryImageView else { return }

        if currentViewController.isZoomed {
            currentViewController.toggleZoom()
        }
    }

    @objc private func doubleTapAction(recognizer _: UITapGestureRecognizer) {
        guard let currentViewController = imagePageViewController.viewControllers?.first as? GalleryImageView else { return }

        currentViewController.toggleZoom()
    }

    @objc func tappedCloseButton(sender _: UIButton!) {
        dismiss(animated: true, completion: nil)
    }

    @objc func tappedLeftButton(sender _: UIButton!) {
        imagePageViewController.goToPreviousPage()

        guard let currentViewController = imagePageViewController.viewControllers?.first as? GalleryImageView else { return }

        updateCurrentVisibleImage(currentViewController)
    }

    @objc func tappedRightButton(sender _: UIButton!) {
        imagePageViewController.goToNextPage()

        guard let currentViewController = imagePageViewController.viewControllers?.first as? GalleryImageView else { return }

        updateCurrentVisibleImage(currentViewController)
    }
}

extension GalleryCarouselView: UIPageViewControllerDataSource {
    private func createImageViewController(_ index: Int) -> GalleryImageView? {
        let imageViewer = GalleryImageView()
        imageViewer.imageData = viewModel?.imageDataArray[safe: index]

        imageViewer.configure(imageIndex: index)

        return imageViewer
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? GalleryImageView, viewController.imageIndex > 0 else { return nil }

        return createImageViewController(viewController.imageIndex - 1)
    }

    // Load the viewcontroller after this one.
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? GalleryImageView,
              let count = viewModel?.imageDataArray.count,
              viewController.imageIndex + 1 < count else { return nil }

        return createImageViewController(viewController.imageIndex + 1)
    }
}

extension GalleryCarouselView: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first as? GalleryImageView, completed else { return }

        updateCurrentVisibleImage(currentViewController)
    }
}

extension UIPageViewController {
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }

    func goToPreviousPage(animated _: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let previousPage = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) {
                setViewControllers([previousPage], direction: .reverse, animated: true, completion: completion)
            }
        }
    }
}


