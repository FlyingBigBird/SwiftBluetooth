//
//  DiscoverCell.swift
//  BluetoothDemo
//
//  Created by BaoBaoDaRen on 2019/8/29.
//  Copyright © 2019 Boris. All rights reserved.
//

import UIKit

// 蓝牙详情闭包
typealias showBleDetail = (_ name:String, _ uuid:String)->Void

class DiscoverCell: UITableViewCell {

    // 名称...
    public var nameLab:UILabel?
    // uuid
    public var uuidLab:UILabel?
    // 信号强度...
    public var rssiLab:UILabel?
    // 详情...
    public var detailBtn:UIButton?
    
    // 点击蓝牙详情...
    var clickBleInfo:showBleDetail?


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        doCellConfig()
    }
    func doCellConfig() {
        
        let labH:CGFloat = 30
        let labM:CGFloat = 5
        self.nameLab = UILabel.init(frame: CGRect(x: 15, y: 10, width: SCREEN_WIDTH, height: labH))
        self.contentView.addSubview(self.nameLab!)
        self.nameLab?.font = CUFont(14)
        
        self.uuidLab = UILabel.init(frame: CGRect(x: 15, y: 0 + labH + labM, width: SCREEN_WIDTH, height: labH))
        self.contentView.addSubview(self.uuidLab!)
        self.uuidLab?.font = Font(13)
        self.uuidLab?.adjustsFontSizeToFitWidth = true
        
        self.rssiLab = UILabel.init(frame: CGRect(x: SCREEN_WIDTH - 15 - 40 - 80, y: 0, width: 80, height: 70))
        self.rssiLab?.adjustsFontSizeToFitWidth = true
        self.rssiLab?.numberOfLines = 0;
        self.rssiLab?.textAlignment = .right
        self.contentView.addSubview(self.rssiLab!)
        self.rssiLab?.font = Font(12)
        
        self.detailBtn = UIButton.init(type: .custom)
        self.detailBtn?.frame = CGRect(x: SCREEN_WIDTH - 15 - 40, y: 0, width: 40, height: 70)
        self.detailBtn?.contentHorizontalAlignment = .right
        self.detailBtn?.setTitle("➡️", for: .normal)
        self.detailBtn?.setTitleColor(.black, for: .normal)
        self.detailBtn?.titleLabel?.font = CUFont(25)
        self.contentView.addSubview(self.detailBtn!)
        
        self.detailBtn?.addTarget(self, action: #selector(showSelectedDeviceInfo), for: .touchUpInside)
        
    }
    @objc func showSelectedDeviceInfo(sender:UIButton) {
        
        // 闭包响应...
        clickBleInfo!("boris","******")
    }
    /**
     non-escaping : 非逃逸型，闭包生命周期和函数相同,退出函数则结束
     escaping     : 逃逸型, 生命周期长,与函数异步,明确何时调用了该闭包再使用
     */
    public func doShowInfo(infoBlock: @escaping showBleDetail){
        
        clickBleInfo = infoBlock
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    

}
