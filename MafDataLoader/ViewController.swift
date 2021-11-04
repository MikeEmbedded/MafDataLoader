//
//  ViewController.swift
//  MafDataLoader
//
//  Created by Mihail Trosinenco on 21.10.2021.
//

import UIKit
import CoreBluetooth
import OSLog
import Charts

class ViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var mafDataConnectButton: UIButton!
    @IBOutlet weak var mafDataReadButton: UIButton!
    @IBOutlet weak var mafDataWriteButton: UIButton!
//    @IBOutlet weak var mafDataText: UITextView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    private var observer: NSObjectProtocol!
    
    let yValues: [ChartDataEntry] = [
                    ChartDataEntry(x: 0, y: 1),
                    ChartDataEntry(x: 1, y: 2),
                    ChartDataEntry(x: 2, y: 3),
                    ChartDataEntry(x: 3, y: 4)]
    
    var lineChartDataSet: LineChartDataSet!
    var lineChartData: LineChartData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //lineChartView.backgroundColor = .systemBlue
        lineChartDataSet = LineChartDataSet(entries: yValues, label: "mafData")
        
        lineChartDataSet.lineWidth = 2
        lineChartDataSet.setColor(.black)
        lineChartDataSet.highlightColor = .systemRed
        
        lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        lineChartView.rightAxis.enabled = false
        
        lineChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.leftAxis.labelPosition = .outsideChart
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        
        lineChartView.animate(xAxisDuration: 1.5)
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
    
    //MARK: Actions
    @IBAction func mafDataConnect(_ sender: UIButton) {
        if mafDataConnectButton.titleLabel?.text == "Connect" {
            if BleManager.Ble.isPeripheralSelected {
                BleManager.Ble.connectSelectedPeripheral()
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
    
    //MARK: Line Chart Delegates
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    //MARK: Private Methods
    private func peripheralDataNotifications(notification: Notification) {
        if let data = notification.object as? String {
            switch data {
            case "NewBleData":
                return
             /*   if let string = String(bytes: BleManager.Ble.peripheralData, encoding: .windowsCP1251) {
                    mafDataText.text = string
                }*/
             /*   var dataString: String = ""
                
                for dataByte in BleManager.Ble.peripheralData {
                    dataString.append(String(format: "0x%02X ", dataByte))
                }
                
                mafDataText.text = dataString */
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

