//
//  xImageManager.swift
//  xSDK
//
//  Created by Mac on 2020/10/26.
//

import UIKit
import Photos
import xAlert

public class xImageManager: NSObject {
    
    // MARK: - Public Property
    /// 单例
    public static let shared = xImageManager()
    private override init() { }
    
    // MARK: - Public Property
    /// 是否授权了相册读写
    public var isGetAlbumAuthorization : Bool
    {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            return true // 未决定
        case .authorized:
            return true // 获得授权
        default:
            return false
        }
    }
    
    
    // MARK: - 保存图片到相册
    /// 保存图片到相册
    /// - Parameters:
    ///   - img: 图片
    ///   - handler: 完成回调
    public static func savePNGImageToAlbum(_ img: UIImage,
                                           completed handler: ((Bool) -> Void)?)
    {
        let data = UIImagePNGRepresentation(img)
        self.saveImageToAlbum(data, completed: handler)
    }
    
    /// 保存图片到相册
    /// - Parameters:
    ///   - img: 图片
    ///   - quality: 质量
    ///   - handler: 完成回调
    public static func saveJPGImageToAlbum(_ img: UIImage,
                                           quality : CGFloat = 1,
                                           completed handler: ((Bool) -> Void)?)
    {
        let data = UIImageJPEGRepresentation(img, quality)
        self.saveImageToAlbum(data, completed: handler)
    }
    
    /// 保存图片到相册
    /// - Parameters:
    ///   - img: 图片数据
    ///   - handler: 完成回调
    public static func saveImageToAlbum(_ imgData: Data?,
                                        completed handler: ((Bool) -> Void)?)
    {
        print(">>>>>>>>>> 开始保存图片")
        guard shared.isGetAlbumAuthorization else {
            print(">>>>>>>>>> ❌未取得相册权限")
            return
        }
        guard let data = imgData else {
            print(">>>>>>>>>> ❌图片数据为nil")
            return
        }
        PHPhotoLibrary.shared().performChanges {
            print(">>>>>>>>>> 开始保存图片")
            // let req = PHAssetChangeRequest.creationRequestForAsset(from: ret) // 无法保存gif，用子类来
            let req = PHAssetCreationRequest.forAsset()
            req.addResource(with: .photo, data: data, options: nil)
            if let ident = req.placeholderForCreatedAsset?.localIdentifier {
                print(">>>>>>>>>> 图片保存成功，唯一标识 = " + ident)
            }
            
        } completionHandler: {
            (isSuccess, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            xMessageAlert.display(message: isSuccess ? "保存成功" : "保存失败")
            handler?(isSuccess)
        }
    }
    
    /*
     方法过时，用上面的替换，需要导入 AssetsLibrary
    /// 保存GIF图片到相册
    /// - Parameter data: GIF图片数据
    public static func saveGifDataToPhotosAlbum(_ data : NSData,
                                                completed handler: @escaping (Bool) -> Void)
    {
        guard self.isAuthorized() else { return }
        let metadata = ["UTI": kCMMetadataBaseDataType_GIF]
        // 开始写数据
        let library = ALAssetsLibrary.init()
        library.writeImageData(toSavedPhotosAlbum: data as Data, metadata: metadata) {
            (assetURL, error) in
            if let err = error {
                xMessageAlert.display(message: "保存失败")
                print(err.localizedDescription)
            }
            else {
                xMessageAlert.display(message: "保存成功")
            }
        }
    }
     */
    
    /*
     旧方法，不推荐
    /// 保存图片到相册
    /// - Parameter img: 图片
    public static func saveImageToPhotosAlbum(_ img: UIImage,
                                              completed handler: @escaping (Bool) -> Void)
    {
        guard self.isAuthorized() else { return }
        UIImageWriteToSavedPhotosAlbum(img, shared, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: - Private Func
    /// 保存图片到相册回调
    /// - Parameters:
    ///   - image: 图片
    ///   - error: 错误
    ///   - contextInfo: 上下文信息
    @objc private func saveImage(image: UIImage,
                                 didFinishSavingWithError error: NSError?,
                                 contextInfo: AnyObject)
    {
        if let err = error {
            xMessageAlert.display(message: "保存失败")
            print(err.localizedDescription)
        }
        else {
            xMessageAlert.display(message: "保存成功")
        }
    }
     
     */
    
}
