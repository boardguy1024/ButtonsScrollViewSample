//
//  ButtonScrollViewController.swift
//  ButtonScrollViewSample
//
//  Created by Park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ButtonScrollViewController: UIViewController, InstantiableFromStoryboard {
    
    @IBOutlet weak var iconBackGroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    private var scrollViewHeader: UIScrollView!
    private var scrollViewMain: UIScrollView!
    private let bag: DisposeBag = DisposeBag()
    private var isStartDragging: Bool = true
    private var startPointX: CGFloat = 0
    private var isReplacingContentOffset: Bool = false
    private var isReplaceContentOffsetByTap: Bool = false
    private let viewModel = ButtonScrollViewModel()
    var buttons: [ButtonView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        createButtons()
        bind()
    }
    
    private func commonInit() {
        iconBackGroundView.clipsToBounds = true
        iconBackGroundView.layer.cornerRadius = iconBackGroundView.frame.height / 2
    }
    
    private func bind() {
        scrollViewHeader.rx_HorizontalScrollDirection.asObservable()
            .subscribe(onNext: { [weak self] direction in
                guard let `self` = self else { return }
                self.viewModel.direction = direction
            })
            .disposed(by: bag)
    }
    
    private func createButtons() {
        // 画面サイズの取得.
        let width = self.view.frame.maxX, height = self.view.frame.maxY
        
        //ボタンがあるScrollView
        // ScrollViewHeaderの設定.
        scrollViewHeader = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        scrollViewHeader.clipsToBounds = false
        scrollViewHeader.showsHorizontalScrollIndicator = false
        scrollViewHeader.showsVerticalScrollIndicator = false
        scrollViewHeader.delegate = self
        //前後3個ずつ追加するため frontAndLastAddPageSize * 2
        scrollViewHeader.contentSize = CGSize(width: CGFloat(viewModel.pageCount) * viewModel.buttonWidth, height: 0)
        scrollViewHeader.isScrollEnabled = false
        scrollViewHeader.backgroundColor = .clear
        self.view.addSubview(scrollViewHeader)
        
        // ScrollViewMainの設定.
        scrollViewMain = UIScrollView(frame: self.view.frame)
        scrollViewMain.showsHorizontalScrollIndicator = false
        scrollViewMain.showsVerticalScrollIndicator = false
        scrollViewMain.isPagingEnabled = true
        scrollViewMain.delegate = self
        scrollViewMain.contentSize = CGSize(width: CGFloat(viewModel.pageCount) * width, height: 0)
        self.view.addSubview(scrollViewMain)
        scrollViewMain.isUserInteractionEnabled = true
        scrollViewMain.isScrollEnabled = true
        
        
        //Loopさせるために前後にラベルを３個ずつをつける-----------------------------------------------
        for i in 0..<viewModel.frontAndLastAddPageSize {
            
            //前に３個ラベルAddする
            //ページごとに異なるラベルを表示.
            let prevMenuButton = ButtonView(frame: CGRect(x: CGFloat(i) * viewModel.buttonWidth, y: 0, width: viewModel.buttonWidth, height: viewModel.buttonHeight))
            prevMenuButton.configure(with: viewModel.buttons[i])
          
            scrollViewHeader.addSubview(prevMenuButton)
        }
        
        // ScrollView2に貼付ける OrpScrollMenuButtonView
        for i in 3 ..< viewModel.pageCount - viewModel.frontAndLastAddPageSize {
            
            //ページごとに異なるラベルを表示.
            let menuButton = ButtonView(frame: CGRect(x: CGFloat(i) * viewModel.buttonWidth, y: 0, width: viewModel.buttonWidth, height: viewModel.buttonHeight))
            menuButton.configure(with: viewModel.buttons[i])
           
            buttons.append(menuButton)
            scrollViewHeader.addSubview(menuButton)
        }
        
        for i in 0..<viewModel.frontAndLastAddPageSize {
            //後ろに３個ラベルAddする
            //ページごとに異なるラベルを表示.
            let lastIndex: Int = (viewModel.pageCount - viewModel.frontAndLastAddPageSize) + i
            
            let lastMenuButton = ButtonView(frame: CGRect(x: viewModel.buttonWidth * CGFloat(lastIndex), y: 0, width: viewModel.buttonWidth, height: viewModel.buttonHeight))
            lastMenuButton.configure(with: viewModel.buttons[lastIndex])
           
            buttons.append(lastMenuButton)
            scrollViewHeader.addSubview(lastMenuButton)
        }
        
        let startPage = viewModel.frontAndLastAddPageSize + viewModel.titles.count * 2
        scrollViewMain.setContentOffset(CGPoint(x: width * CGFloat(startPage), y: 0), animated: false)
        scrollViewDidEndDecelerating(scrollViewMain)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        self.view.addGestureRecognizer(tapgesture)
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        
        let buttonWidth = viewModel.buttonWidth
        let tappedLocationX = sender.location(in: sender.view).x
        
        let halfWidth: CGFloat = (self.view.frame.width / 2)
        let leftEndAreaOriginX: CGFloat = (halfWidth - (buttonWidth / 2)) - buttonWidth * 2
        let leftAreaOriginX: CGFloat = (halfWidth - buttonWidth / 2) - buttonWidth
        let rightAreaOriginX: CGFloat = halfWidth + (buttonWidth / 2)
        let rightEndAreaOriginX: CGFloat = halfWidth + (buttonWidth / 2) + buttonWidth
        var targetIndex: Int = 0
        
        switch tappedLocationX {
        case leftEndAreaOriginX...leftEndAreaOriginX + buttonWidth:
            targetIndex = viewModel.currentPage - 2
        case leftAreaOriginX...leftAreaOriginX + buttonWidth:
            targetIndex = viewModel.currentPage - 1
        case rightAreaOriginX...rightAreaOriginX + buttonWidth:
            targetIndex = viewModel.currentPage + 1
        case rightEndAreaOriginX...rightEndAreaOriginX + buttonWidth:
            targetIndex = viewModel.currentPage + 2
        default:
            return
        }
        
        isReplacingContentOffset = true
        if targetIndex == viewModel.channelButtonsData.count - viewModel.frontAndLastAddPageSize ||
            targetIndex == viewModel.frontAndLastAddPageSize {
            isReplaceContentOffsetByTap = true
        }
        else {
            isReplaceContentOffsetByTap = false
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            //差し替えタイミングで差し替えせず、次のindexをアニメーションさせてから一瞬で差し替える
            self.scrollViewMain.setContentOffset(CGPoint(x: self.viewModel.transitionChannelPoints[targetIndex], y: 0), animated: false)
        }, completion: { _ in
            if self.isReplaceContentOffsetByTap {
                let firstIndex: Int = self.viewModel.frontAndLastAddPageSize + self.viewModel.buttons.count * 2
                self.scrollViewMain.setContentOffset(CGPoint(x: self.viewModel.transitionChannelPoints[firstIndex], y: 0), animated: false)
                self.isReplaceContentOffsetByTap = false
            }
            self.scrollViewDidEndDecelerating(self.scrollViewMain)
        })
    }
    
    private func setActivateButton(by currentPage: Int) {
        
        UIView.animate(withDuration: 0.2, animations: {

            print(self.viewModel.buttons.count)
            let colorHex = self.viewModel.buttons[currentPage].imageColorHex
            self.iconBackGroundView.backgroundColor = UIColor(hex: colorHex)
        
//            if self.viewModel.direction == .Left && currentPage == 2 {
//                self.buttons[3].activeIconImageView.alpha = 0
//                self.buttons[3].iconImageView.alpha = 1
//                return
//            }
//
//            self.buttons.enumerated().forEach { index, button in
//                if (currentPage) == index {
//                    button.activeIconImageView.alpha = 0
//                    button.iconImageView.alpha = 1
//                }
//                else {
//                    button.activeIconImageView.alpha = 1
//                    button.iconImageView.alpha = 0
//                }
//            }
        })
    }
    
}

extension ButtonScrollViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isStartDragging = true
        startPointX = 0
        isReplacingContentOffset = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isStartDragging = true
        startPointX = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == scrollViewMain {
            
            let screenWidth: CGFloat = self.view.frame.width
            let offset = (scrollViewMain.contentOffset.x / screenWidth) * viewModel.buttonWidth
            scrollViewHeader.contentOffset.x = offset - screenWidth / 2 + (viewModel.buttonWidth / 2)
            
            // 任意のボタンをカレントにする際、contetOffset差し替えタイミングならアニメーションをさせない(スロッドのようなアニメーションになるため)
            if isReplaceContentOffsetByTap { return }
            
            if viewModel.direction == .Left {
                
                let triggerArea: CGFloat = CGFloat(viewModel.pageCount - viewModel.frontAndLastAddPageSize) * screenWidth
                
                if triggerArea - 50 <= scrollView.contentOffset.x && triggerArea >= scrollView.contentOffset.x && isReplacingContentOffset {
                    
                    scrollViewMain.contentOffset.x = self.view.frame.width * 3 - 50
                    setActivateButton(by: 3)
                    isReplacingContentOffset = false
                }
                
                if isStartDragging {
                    startPointX = offset
                    isStartDragging = false
                }
                
                if offset > startPointX + 45 {
                    setActivateButton(by: viewModel.currentPage + 1)
                }
                
            }
            else if viewModel.direction == .Right {
                
                let triggerArea: CGFloat = CGFloat(viewModel.frontAndLastAddPageSize - 1) * screenWidth
                
                if triggerArea + 50 >= scrollView.contentOffset.x && triggerArea <= scrollView.contentOffset.x && isReplacingContentOffset {
                    
                    scrollViewMain.contentOffset.x = (self.view.frame.width * CGFloat(viewModel.pageCount - viewModel.frontAndLastAddPageSize - 1)) + 50
                    setActivateButton(by: viewModel.pageCount - viewModel.frontAndLastAddPageSize - 1)
                    isReplacingContentOffset = false
                }
                
                if isStartDragging {
                    startPointX = offset
                    isStartDragging = false
                }
                
                if offset < startPointX - 45 {
                    setActivateButton(by: viewModel.currentPage - 1)
                }
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let screenWidth = self.view.frame.width
        
        let currentOffsetX = CGFloat(self.viewModel.currentPage) * screenWidth
        let scrollOffsetX = scrollView.contentOffset.x
        var currentVelocityX: CGFloat = abs(velocity.x)
        if currentVelocityX <= 1 { currentVelocityX = 1 }
        let threshold = currentOffsetX + (screenWidth / 2)
        
        if viewModel.direction == .Left {
            let difValue = scrollOffsetX - currentOffsetX
            let triggerTargetX = currentOffsetX + pow(difValue, currentVelocityX)
            if threshold <= triggerTargetX {
                setActivateButton(by: viewModel.currentPage + 1)
            }
        }
        else if viewModel.direction == .Right {
            let difValue = currentOffsetX - scrollOffsetX
            let triggerTargetX = currentOffsetX + pow(difValue, currentVelocityX)
            if threshold <= triggerTargetX {
                setActivateButton(by: viewModel.currentPage - 1)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentPage = Int(round(scrollView.contentOffset.x / view.frame.width))
        
        if viewModel.currentPage == currentPage { return }
        
        self.viewModel.currentPage = currentPage
        setActivateButton(by: currentPage)
        //showChannelsView(by: currentPage)
       // buttons.forEach { $0.titleLabel.alpha = 1 }
    }
}
