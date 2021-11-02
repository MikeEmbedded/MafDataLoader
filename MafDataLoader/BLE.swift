//
//  BLE.swift
//  MafDataLoader
//
//  Created by Mihail Trosinenco on 25.10.2021.
//

import Foundation
import CoreBluetooth

struct CBUUIDs {
    static let kBLE_Service_UUID = "FFE0"
    static let kBLE_Characteristic_UUID = "FFE1"
    
    static let BLE_Service_UUID = CBUUID(string: kBLE_Service_UUID)
    static let BLE_Characteristic_UUID = CBUUID(string: kBLE_Characteristic_UUID)
}

class BleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let Ble = BleManager()
    
    private var centralManager: CBCentralManager?
    public  var centralManagerState: CBManagerState = .poweredOff
    private var peripherals: [CBPeripheral] = []
    private var selectedPeripheral: CBPeripheral?
    public var  isPeripheralSelected: Bool = false
    private var isPeripheralConnected: Bool = false
    
    public var peripheralData: [UInt8] = []

    private override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        
    }

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerState = central.state
    }
    
    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            NotificationCenter.default.post(name: Notification.Name("NewBlePeripheralDiscovered"), object: nil)
        }
    }
    
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isPeripheralConnected = false
    }
    
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        selectedPeripheral?.delegate = self
        selectedPeripheral?.discoverServices([CBUUIDs.BLE_Service_UUID])
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil {
            guard let services = peripheral.services else {
                return
            }
            
            for service in services {
                if (service.uuid == CBUUIDs.BLE_Service_UUID) {
                    selectedPeripheral?.discoverCharacteristics([CBUUIDs.BLE_Characteristic_UUID], for: service)
                }
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid == CBUUIDs.BLE_Characteristic_UUID {
                        isPeripheralConnected = true
                        peripheralData.removeAll()
                        // Subscribe to a characteristic value
                        selectedPeripheral?.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            if (peripheral == selectedPeripheral) && (characteristic.uuid == CBUUIDs.BLE_Characteristic_UUID) {
                if let data = characteristic.value {
                    for Byte in data {
                        peripheralData.append(Byte)
                        NotificationCenter.default.post(name: Notification.Name("NewBlePeripheralData"), object: nil)
                    }
                }
            }
        }
    }
    
    func startBleScan() {
        if centralManagerState == .poweredOn {
            centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLE_Service_UUID], options: nil)
        }
    }
    
    func stopBleScan() {
        if let isScanning = centralManager?.isScanning, isScanning {
            centralManager?.stopScan()
        }
    }

    func removeAllPeripherals() {
        peripherals.removeAll()
    }
    
    func getPeripheralsCount() -> Int {
        return peripherals.count
    }
    
    func getPeripheral(index: Int) -> CBPeripheral? {
        if peripherals.isEmpty {
            return nil
        }

        return peripherals[index]
    }
    
    func setSelectedPeripheral(index: Int) -> Bool {
        if index < peripherals.count {
            stopBleScan()
            selectedPeripheral = peripherals[index]
            isPeripheralSelected = true
            return true
        }
        
        return false
    }
    
    func connectSelectedPeripheral() {
        if isPeripheralSelected {
            centralManager?.connect(selectedPeripheral!, options: nil)
        }
    }
}
