//
//  AATSlideImageView.swift
//  AAT
//
//  Created by wenjingjie on 17/1/12.
// 
//

import UIKit

@objc protocol AATSlideViewDelegate: NSObjectProtocol {
    @objc optional func pageViewDidSelectedAt(index: Int, pageView: AATSlideImageView)
    @objc optional func pageViewDidScrollAt(index: Int, pageView: AATSlideImageView)
}

class AATSlideImageView: UIView {
    
    let pageControllHeight: CGFloat = 25
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var pageLabel = UILabel()
    
    var isAutoScroll = Bool() {
        didSet {
            // 设置自动滚动计时器
            switch isAutoScroll {
            case true:
                startTimer()
            default:
                return
            }
            
        }
    }
    
    // 自动滚动计时器
    var timer: Timer!
    
    var urlStringArray = [String]() {
        didSet {
            
            let scrollViewWidth = scrollView.frame.size.width
            let scrollViewHeight = scrollView.frame.size.height
            
            for i in 0 ..< urlStringArray.count {
                
                let button = AATNoButton()
                button.tag = i
                button.frame = CGRect(x: CGFloat(i) * scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
                // button.setImage(UIImage(named: statusArray[i]), forState: .Normal)
                button.aat_setImageWithURLWithPlaceHoder(urlStringArray[i], forState: .normal, placeHolderImageName: "background_image_big")
                button.addTarget(self, action: #selector(btnClick), for: .touchDown)
                button.imageView?.contentMode = .scaleAspectFill
                button.imageView?.clipsToBounds = true
                self.scrollView.addSubview(button)
                
            }
            
            self.scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(urlStringArray.count), height: 0)
            self.pageControl.numberOfPages = urlStringArray.count
            self.pageLabel.text = "1/\(urlStringArray.count)"
        }
    }
    
    weak var delegate: AATSlideViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupPageControl()
        setupPageLabel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupScrollView() {
//        scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: self.frame.size))
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        self.addSubview(scrollView)
    }
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: scrollView.frame.size.height - pageControllHeight, width: scrollView.frame.size.width, height: pageControllHeight))
        pageControl.currentPage = 0
        pageControl.center = CGPoint(x: self.center.x, y: pageControl.center.y)
        guard let currentImage = UIImage(named: "shop_commodity_circulation_selected") else { return }
        guard let image = UIImage(named: "shop_commodity_circulation_unselected") else { return }
//        pageControl.pageIndicatorTintColor = UIColor(patternImage: image)
//        pageControl.currentPageIndicatorTintColor = UIColor(patternImage: currentImage)
        pageControl.setValue(currentImage, forKeyPath: "_currentPageImage")
        pageControl.setValue(image, forKeyPath: "_pageImage")
        self.addSubview(pageControl)
    }
    
    func setupPageLabel() {
        
        self.pageLabel.textColor = AATWhiteBgColor
        self.pageLabel.font = AATCellTitleFont
        self.pageLabel.frame = CGRect(x: 0, y: scrollView.frame.size.height - pageControllHeight, width: scrollView.frame.size.width - 10, height: 20)
        self.pageLabel.textAlignment = .right
        self.addSubview(pageLabel)
        pageLabel.isHidden = true
    }
    
}

extension AATSlideImageView {
    
    @objc fileprivate func btnClick(_ button: UIButton) {
        self.delegate?.pageViewDidSelectedAt?(index: button.tag, pageView: self)
    }
}

extension AATSlideImageView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = Int(scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5)
        self.pageLabel.text = "\(self.pageControl.currentPage + 1)/\(urlStringArray.count)"
        self.delegate?.pageViewDidScrollAt?(index: self.pageControl.currentPage, pageView: self)
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 设置自动滚动计时器
        switch isAutoScroll {
        case true:
            startTimer()
        default:
            return
        }
        
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func nextPage() {
        
        var index = self.pageControl.currentPage + 1
        if index == self.urlStringArray.count {
            index = 0
        }
        
        let offSet: CGPoint = CGPoint(x: self.scrollView.frame.size.width * CGFloat(index), y: 0)
        self.scrollView.setContentOffset(offSet, animated: true)
    }
    
}
