//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by BaoBaoDaRen on 2019/8/27.
//  Copyright © 2019 Boris. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate {

    let cellRes:String = "bleCellId"
    var isSearching:Bool?
    var timer:Timer?
    var central:CBCentralManager?
    var peripheral:CBPeripheralManager?

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "未连接"
        self.view.backgroundColor = UIColor.white
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.isSearching = false;
        showNavUI()
        
    }
    
    // TODO: 配置蓝牙
    func doBluetoothConfiguration() {
        
        /**
         CBCentralManagerOptionShowPowerAlertKey:没打开蓝牙时提示框
         CBCentralManagerOptionRestoreIdentifierKey:蓝牙恢复的标识...
         */
        
        let backmodes:NSArray = Bundle.main.infoDictionary?["UIBackgroundModes"] as! NSArray
        if backmodes .contains("bluetooth-central") {
            
            self.central = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true, CBCentralManagerOptionRestoreIdentifierKey:"BluetoothDemoRestore"])
            
        } else {
            self.central = CBCentralManager.init(delegate: self, queue: nil)
        }
        
    }
    func showNavUI() {
        
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            NSLog("viewSafeAreaInsetsDidChange-%@",NSCoder.string(for: self.view.safeAreaInsets))
        } else {
            // Fallback on earlier versions
        }
        
        let rightItemButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        rightItemButton.backgroundColor = UIColor.clear
        rightItemButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        rightItemButton.setTitle("搜索蓝牙" as String, for: .normal)
        rightItemButton.setTitleColor(UIColor.black, for: .normal)
        rightItemButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(17.0))
        rightItemButton .addTarget(self, action: #selector(rightButtonCLicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightItemButton)
        
        tabView.tableFooterView = UIView()
        tabView.tableHeaderView = UIView()
        tabView.dataSource = self
        tabView.delegate = self
        self.view .addSubview(tabView)
        
//        let dic:NSDictionary = CurrentVersionInfo()
        
    }
    
    @objc func rightButtonCLicked () {
        
        if self.isSearching == true {
            return
        }
        self.title = "搜索中..."
        searchBegin()
        // 蓝牙搜索开始...
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onSearching), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
        
        self.isSearching = true
    }
    @objc func onSearching () {
        
        if (self.title == "搜索中...") {
            
            self.title = "..."
        } else {
            
            self.title = "搜索中..."
        }
    }
    // TODO: 开始搜索蓝牙设备...
    func searchBegin() {
        
        doBluetoothConfiguration()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deviceArr.count > 0 ? deviceArr.count : 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:DiscoverCell! = tableView.dequeueReusableCell(withIdentifier: cellRes) as? DiscoverCell
        if cell == nil {
            cell = DiscoverCell.init(style: .default, reuseIdentifier: cellRes)
        }
        if deviceArr.count > 0 {
            
            let getDic:NSDictionary = deviceArr[indexPath.row] as! NSDictionary
            let peripheral: CBPeripheral = getDic.object(forKey: "CBPeripheral") as! CBPeripheral
            if peripheral.name == nil {
                cell.nameLab?.text = "null"
            } else {
                cell.nameLab?.text = peripheral.name
            }
            cell.uuidLab?.text = String("\(peripheral.identifier)")
            
            cell.rssiLab?.text = String("RSSI:\(getDic.object(forKey: "RSSI") ?? "0")")
        }
        cell.doShowInfo { (name, uuid) in
            
            print("peripheralName:\(name), peripheralUUID:\(uuid)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < self.deviceArr.count {
            
            let getDic:NSDictionary = deviceArr[indexPath.row] as! NSDictionary
            let peripheral: CBPeripheral = getDic.object(forKey: "CBPeripheral") as! CBPeripheral
            
            /*
             CBConnectPeripheralOptionNotifyOnConnectionKey:
             当应用挂起时，如果有一个连接成功时,
             如果我们想要系统为指定的peripheral显示一个提示时,就使用这个key值。
             CBConnectPeripheralOptionNotifyOnDisconnectionKey:
             当应用挂起时，如果连接断开时，
             如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
            CBConnectPeripheralOptionNotifyOnNotificationKey:
            当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
            */
            let connectOptions:NSDictionary = [CBConnectPeripheralOptionNotifyOnConnectionKey:true, CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,CBConnectPeripheralOptionNotifyOnNotificationKey:true]
            self.central?.connect(peripheral, options: connectOptions as? [String : Any])
            
        }
    }
    
    // TODO: CBCentralManagerDelegate
    // 蓝牙状态改变...
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        self.central = central
        switch central.state {
        case .unknown:
            
            print("BluetoothState unknown")
        case .resetting:
            
            print("BluetoothState resetting")
        case .unsupported:
            
            print("BluetoothState unsupported")
        case .unauthorized:
            
            print("BluetoothState unauthorized")
        case .poweredOff:
            
            print("BluetoothState poweredOff")
        case .poweredOn:
            
            print("BluetoothState poweredOn")
            
        default:
            print("Bluetooth nonsupport")
        }
        
        if central.state == .poweredOn {
            
            /**
             开始扫描外设...
             services:nil -> 扫描所有设备
             options -> CBCentralManagerScanOptionAllowDuplicatesKey
             默认值为false表示不会重复扫描已经发现的设备
             如需要不断获取最新的信号强度RSSI所以一般设为true了
             */
            //  TODO: <开始扫描>：central->当前设备/管理设备  peripheral->外设,其他设备...
            self.central?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            
            //            centralManager?.scanForPeripherals(withServices: [CBUUID.init(string:SERVICE_UUID)], options: nil)// 根据自己公司设备UUID查找,不知道的可以找硬件工程师...

        } else {
            
            let alertVC:UIAlertController = UIAlertController.init(title: "开启蓝牙?", message: nil, preferredStyle: .alert)
            let cancelA:UIAlertAction = UIAlertAction.init(title: "不开启", style: .cancel) { (UIAlertAction) in

                // 取消...
            }
        
            let okAction:UIAlertAction = UIAlertAction.init(title: "去开启", style: .default) { (UIAlertAction) in
                
                // 打开蓝牙...
                let _:Bool = OPEN_SETTING_PATH
                
            }
            alertVC.addAction(cancelA)
            alertVC.addAction(okAction)
            self.navigationController?.present(alertVC, animated: true, completion: {
                
            })
        }
           
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {

        print("willRestoreState")

    }
    
    // TODO: 区分扫描到的蓝牙设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // 已扫描到设备...
//        print("扫描到外设:\(peripheral), Data:\(Data()), RSSI:\(RSSI)")
        let dataDic:NSDictionary = ["CBPeripheral":peripheral, "Data":Data(), "RSSI":RSSI,]
        /**
         添加设备的规则：当前规则为-> 未添加过的且名称不为空的设备
         此目标设备为手机/手表等设备，若其他终端/打印机/机顶盒等设备可根据需要自行修改
         可修改扫描选项根据自己产品设备的UDID更改service(当前搜索规则为nil->搜索所有设备)
        */
        if !idty.contains(peripheral.identifier) && peripheral.name != nil {
            
            deviceArr.add(dataDic)
            idty.add(peripheral.identifier)
            self.tabView .reloadData()
            
//            let currentName:String = String("\(UserDefaults.standard.object(forKey: "deviceName") ?? "deviceName")")
//            if peripheral.name == currentName {
//
//                let connectOptions:NSDictionary = [CBConnectPeripheralOptionNotifyOnConnectionKey:true, CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,CBConnectPeripheralOptionNotifyOnNotificationKey:true]
//                self.central?.connect(peripheral, options: connectOptions as? [String : Any])
//
//            }
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // 已连接到设备...
        UserDefaults.standard.set(peripheral.name, forKey: "deviceName")
        print("已连接到设备")
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        // 连接失败...
        print("连接失败")
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        // 已断开连接...
        print("didDisconnectPeripheral")
    }
    
    // TODO: CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        self.peripheral = peripheral
        print("peripheralManager Did UpdateState")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
    
        // 应用重新启动时调用,包含设备信息...
        print("willRestoreState")
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        // 开始广播...
        print("DidStartAdvertising")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        // 发布服务...
        print("didAdd service")

    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        /**
         通常，centrals可以订阅一个或多个特征值，这在Subscribing to a Characteristic’s Value. 中也有描述。这种情况下如果他们订阅的特征值的值有变化，你应该要能够给他们发消息。        当一个central订阅某个特征值，peripheral manager将通知代理peripheralManager:central:didSubscribeToCharacteristic: 方法
         */
        print("发现设备")
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        // 移除通知时调用...
        print("didUnsubscribeFrom characteristic")

    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        // 外设收到读取数据请求时调用...
        print("读取数据请求")

    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        // 外设收到写入数据请求时调用...
        print("收到写入数据请求")

    }
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        //
        print("ManagerIsReady")

    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        
        //
        print("didPublishL2CAPChannel")

    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        
        //
        print("didUnpublishL2CAPChannel")

    }
    @available(iOS 11.0, *)
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        
        //
        print("didOpen channel")
    }
    
    
    
    // TODO: 懒加载...
    private lazy var tabView:UITableView = {
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT), style: .plain)
        tableView .register(DiscoverCell.classForCoder(), forCellReuseIdentifier: cellRes)
        return tableView
    }()
    
    private lazy var deviceArr:NSMutableArray = {
     
        let mulArr = NSMutableArray.init()
        return mulArr
    }()
    private lazy var idty:NSMutableArray = {
        
        let mulArr = NSMutableArray.init()
        return mulArr
    }()
}



