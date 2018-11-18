//
//  ButtonView.swift
//  ButtonScrollViewSample
//
//  Created by park on 2018/11/15.
//  Copyright © 2018年 park. All rights reserved.
//

import UIKit

class ButtonView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    private func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
    
    func configure(with buttonData: ButtonScrollModel) {

        let image = UIImage(imageLiteralResourceName: buttonData.imageName)
        iconImageView.image = image
        titleLabel.text = buttonData.title
    }
}
