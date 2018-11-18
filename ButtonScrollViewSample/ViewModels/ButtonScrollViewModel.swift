//
//  ButtonScrollViewModel.swift
//  ButtonScrollViewSample
//
//  Created by park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//

import RxSwift
import UIKit

struct ButtonScrollModel {
    let title: String
    let imageName: String
    let imageColorHex: String
}

class ButtonScrollViewModel {

    var titles: [String] = ["triangle","airplane","arrow","refresh","charge","light","bug","call","camera","cars","menu","connect","clowd","rain","replace"]
    var buttonColors: [String] = ["#33f7d0", "#32bcf7", "#3273f7", "#5632f7", "#a432f7", "#f7328d", "#f73232", "#f76332", "#f7a832", "#f7f732", "#bff732", "#4ff732", "#32f794", "#32f7f0", "#1b86c4"]
    var buttons: [ButtonScrollModel] = []
    var channelIcons: [String] = []
    var channelButtonsData: [String] = []
    var transitionChannelPoints: [CGFloat] = []
    let buttonHeight: CGFloat = 72
    let buttonWidth: CGFloat = 90
    let buttonLeftMargin: CGFloat = 53
    var direction: ScrollDirection = .None
    // ページ番号.
    var pageCount = 0
    let frontAndLastAddPageSize = 3
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    var currentPage: Int = 0
    var startChannelId: Int = 0

    init() {
        createDatas()
    }
    
    private func createSampleButtonDatas() -> [ButtonScrollModel] {
        
        var buttonModels: [ButtonScrollModel] = []
        for i in 0..<15 {
            let buttonModel = ButtonScrollModel.init(title: titles[i], imageName: "\(i)", imageColorHex: buttonColors[i])
            buttonModels.append(buttonModel)
        }
        
        return buttonModels
    }

    private func createDatas() {

        let buttonsModels = createSampleButtonDatas()
        
        for i in 0..<3 {
            let lastIndex = (buttonsModels.count - frontAndLastAddPageSize) + i
            self.buttons.append(buttonsModels[lastIndex])
        }
        
        //ループさせるため余分に追加する
        for _ in 0..<4 {
            self.buttons += buttonsModels
        }
        
        for i in 0..<3 {
            self.buttons.append(buttonsModels[i])
        }

        self.pageCount = buttons.count

        buttons.enumerated().forEach {
            self.transitionChannelPoints.append(CGFloat($0.offset) * screenWidth)
        }

      //  guard let indexData = channelButtonsData[3] as? MasterOriginPiaIndex else { return }
      //  self.startChannelId = indexData.channelId
    }
}

