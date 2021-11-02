//
//  ViewController.swift
//  MafDataLoader
//
//  Created by Mihail Trosinenco on 21.10.2021.
//

import UIKit
import CoreBluetooth
import OSLog

class ViewController: UIViewController {
    @IBOutlet weak var mafDataReadButton: UIButton!
    @IBOutlet weak var mafDataWriteButton: UIButton!
    @IBOutlet weak var mafDataText: UITextView!
    
    private var observer: NSObjectProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("NewBlePeripheralData"), object: nil, queue: nil, using: newBlePripheralData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if BleManager.Ble.isPeripheralSelected {
            mafDataReadButton.isEnabled = true
            mafDataWriteButton.isEnabled = true
        }
        else {
            mafDataReadButton.isEnabled = false
            mafDataWriteButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observer!)
    }
    
    @IBAction func mafDataRead(_ sender: UIButton) {
        if BleManager.Ble.isPeripheralSelected {
            BleManager.Ble.connectSelectedPeripheral()
            
        }
    }
    
    //MARK: Private Methods
    private func newBlePripheralData(notification: Notification) {
        if let string = String(bytes: BleManager.Ble.peripheralData, encoding: .windowsCP1251) {
            mafDataText.text = string
        }
    }
}

