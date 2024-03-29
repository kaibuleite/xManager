//
//  xDeviceManager.swift
//  xSDK
//
//  Created by Mac on 2020/10/26.
//

import UIKit
import AdSupport
import AVKit

public class xDeviceManager: NSObject {
    
    // MARK: - 设备信息
    /// 系统版本
    public static var systemVersion : String {
        let ret = UIDevice.current.systemVersion
        return ret
    }
    /// 机型名称
    public static var machineModelName : String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let key = withUnsafePointer(to: &systemInfo.machine.0) {
            (ptr) in
            return String(cString: ptr)
        }
        let unknown = "unknown"
        let bundle = Bundle.init(for: self.classForCoder())
        guard let path = bundle.path(forResource: "xDeviceMachine.plist", ofType: nil) else { return unknown }
        guard let dict = NSDictionary.init(contentsOfFile: path) else { return unknown }
        if let value = dict.value(forKey: key) as? String {
            return value
        }
        return unknown
    }
    /// UDID
    public static var UDID : String {
        print("========== 读取钥匙串中的UDID...")
        let key = (xAppManager.appBundleID + ".UDID")
        var udid = ""
        if let data = xKeychainManager.shared.query(valueForKey: key) {
            if let obj = String.init(data: data, encoding: .utf8) {
                udid = obj
                print("========== 获取成功 UDID = \(obj)")
            }
        }
        if udid.count == 0 {
            let obj = xDeviceManager.UUID
            print("========== 获取失败，新UDID = \(obj)")
            if let data = obj.data(using: .utf8) {
                xKeychainManager.shared.save(value: data, forKey: key)
            }
            udid = obj
        }
        return udid
    }
    /// UUID
    public static var UUID : String {
        let ret = NSUUID.init().uuidString
        return ret
    }
    /// IDFA
    public static var IDFA : String {
        let ret = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return ret
    }
    
    // MARK: - 设备类型
    /// 是否是iPAd
    public static var isPad : Bool
    {
//        let ret = UI_USER_INTERFACE_IDIOM() == .pad
        let ret = UIDevice.current.userInterfaceIdiom == .pad
        return ret
    }
    
    /// 是否是模拟器
    public static var isSimulator : Bool
    {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - 越狱检测
    /// 是否越狱
    public static var isRoot : Bool
    {
        if self.isSimulator {
            print("模拟器环境下不用检测")
            return false
        }
        
        if getgid() <= 10 { return true } // process ID shouldn't be root
        if let dict = Bundle.main.infoDictionary as NSDictionary? {
            if let _ = dict.object(forKey: "SignerIdentity") {
                return true
            }
        }
        let pathArr = ["/Applications/Cydia.app",
                       "/private/var/lib/apt/",
                       "/private/var/lib/cydia",
                       "/private/var/stash"]
        let mgr = FileManager.default
        for path in pathArr {
            if mgr.fileExists(atPath: path) {
                print("⚠️ 存在越狱文件夹:\(path)")
                return true
            }
        }
        
        let bash = fopen("/bin/bash", "r");
        if (bash != nil) {
            fclose(bash)
            print("⚠️ 检测到越狱权限，进程编号太靠前")
            return true
        }
        
        do {
            let path = String.init(format: "/private/%@", self.UUID)
            try "xx".write(toFile: path, atomically: true, encoding: .utf8)
            try mgr.removeItem(atPath: path)
            print("⚠️ 存在越狱文件夹:\(path)")
            return true
        } catch {
            print(error.localizedDescription)
        }
        /*
        let bundlePath = Bundle.main.bundlePath
        let path1 = "\(bundlePath)/_CodeSignature"
        if mgr.fileExists(atPath: path1) {
            print("⚠️ 存在越狱文件夹:\(path1)")
            return true
        }
        let path2 = "\(bundlePath)/SC_Info"
        if mgr.fileExists(atPath: path2) {
            print("⚠️ 存在越狱文件夹:\(path2)")
            return true
        }
         */
        print("当前设备未越狱")
        return false
    }
    
    // MARK: - 拨打电话
    /// 拨打电话
    /// - Parameter phone: 电话
    public static func call(phone : String)
    {
        let str = "tel://" + phone
        guard let url = str.xToURL() else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
//        UIApplication.shared.openURL(url)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - 开关手电筒状态
    /// 设置手电筒状态
    /// - Parameter isOn: 是否打开
    public static func setFlashLight(_ torchMode: AVCaptureDevice.TorchMode)
    {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("⚠️ 设备初始化失败")
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchMode
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
}
