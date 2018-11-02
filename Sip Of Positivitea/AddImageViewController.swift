//
//  AddImageViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 10/30/18.
//  Copyright © 2018 Bria Sullivan. All rights reserved.
//

import UIKit

class AddImageViewController: UIViewController {

    @IBOutlet var imageInput:UIImageView!
    
    var doneHandler:((UIImageView?) -> Void)?
    var newMassMessage: MassMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (newMassMessage?.messageImage != nil) {
            imageInput.image = newMassMessage?.messageImage
        } else {
            imageInput.backgroundColor = UIColor.lightGray
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func choosePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary

        present(picker, animated: true, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        doneHandler?(imageInput)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: Image Picker Delegate
extension AddImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if (false){
            /*            // Handle picking a Photo from the Photo Library
             // 2
             let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as! URL
             let assetURL = URL(fileURLWithPath: photoReferenceUrl.absoluteString)
             
             let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
             let asset = assets.firstObject
             
             // 3
             if let key = sendPhotoMessage() {
             
             
             // 5
             let path = "\(Auth.auth().currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
             do {
             let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
             
             let fileURL = try documentsURL.appendingPathComponent(path)
             
             let image = info[UIImagePickerControllerOriginalImage]
             try UIImageJPEGRepresentation(image as! UIImage,1.0)?.write(to: fileURL, options: [])
             
             
             // 6
             self.storageRef.child(path).putFile(from:fileURL, metadata: nil) { (metadata, error) in
             if let error = error {
             print("Error uploading photo: \(error.localizedDescription)")
             return
             }
             // 7
             self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
             }
             } catch {
             
             
             }
             // 4
             asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
             
             })
             } */
        } else {
            
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageInput.image = image
            // 2
            /*
             if let key = sendPhotoMessage() {
             // 3
             let imageData = UIImageJPEGRepresentation(image, 1.0)
             // 4
             let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
             // 5
             let metadata = StorageMetadata()
             metadata.contentType = "image/jpeg"
             // 6
             storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
             if let error = error {
             print("Error uploading photo: \(error)")
             return
             }
             // 7
             self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
             }
             }*/
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
}

