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
    @IBOutlet weak var mafDataConnectButton: UIButton!
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
        observer = NotificationCenter.default.addObserver(forName: .peripheralNotifications, object: nil, queue: nil, using: peripheralDataNotifications)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if BleManager.Ble.isPeripheralConnected {
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
    
    @IBAction func mafDataConnect(_ sender: UIButton) {
        if mafDataConnectButton.titleLabel?.text == "Connect" {
            if BleManager.Ble.isPeripheralSelected {
                BleManager.Ble.connectSelectedPeripheral()
                mafDataConnectButton.setTitle("Disconnect", for: .normal)
            }
            else {
                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is not selected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            BleManager.Ble.disconnectSelectedPeripheral()
            mafDataReadButton.isEnabled = false
            mafDataWriteButton.isEnabled = false
            mafDataConnectButton.setTitle("Connect", for: .normal)
        }
    }
    
    @IBAction func mafDataRead(_ sender: UIButton) {
    }
    
    @IBAction func mafDataWrite(_ sender: UIButton) {
        BleManager.Ble.peripheralWrite(string: "Katea jopa")
    }
    
    //MARK: Private Methods
    private func peripheralDataNotifications(notification: Notification) {
        if let data = notification.object as? String {
            switch data {
            case "NewBleData":
                if let string = String(bytes: BleManager.Ble.peripheralData, encoding: .windowsCP1251) {
                    mafDataText.text = string
                }
            case "SelectedBleConnected":
                mafDataConnectButton.setTitle("Disconnect", for: .normal)
                mafDataReadButton.isEnabled = true
                mafDataWriteButton.isEnabled = true
            case "SelectedBleDisconnected":
                mafDataReadButton.isEnabled = false
                mafDataWriteButton.isEnabled = false
                mafDataConnectButton.setTitle("Connect", for: .normal)

                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is disconnected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            default:
                let alert = UIAlertController(title: "MafDataLoader", message: "Ble device is not selected.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

