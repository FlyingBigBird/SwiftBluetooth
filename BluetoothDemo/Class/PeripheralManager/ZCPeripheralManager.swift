//
//  ZCPeripheralManager.swift
//  BluetoothDemo
//
//  Created by BaoBaoDaRen on 2019/8/29.
//  Copyright © 2019 Boris. All rights reserved.
//

import UIKit
import CoreBluetooth

class ZCPeripheralManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {

    // 中心设备...
    var centralManager : CBCentralManager?
    // 已发现设备
    var discoveredPeripherals:NSMutableArray?
    // 已连接的设备
    var connectedPeripherals:NSMutableArray?
    // 可自动重连的设备...
    var reconnectedPeripherals:NSMutableArray?
    
    
    override init() {
        
        super.init()
        
        self.discoveredPeripherals = NSMutableArray.init()
        self.connectedPeripherals = NSMutableArray.init()
        self.reconnectedPeripherals = NSMutableArray.init()
        
        doManagerConfiguration()
    }
    func doManagerConfiguration() {
        
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
    
    
}
