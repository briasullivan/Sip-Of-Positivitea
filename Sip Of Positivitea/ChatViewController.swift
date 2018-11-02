//
//  ChatViewController.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 5/8/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import JSQMessagesViewController
import Photos
import Foundation
import SystemConfiguration
import OneSignal
import Agrume

class ChatViewController: JSQMessagesViewController {
    
    var conversationRef: DatabaseReference?
    var conversation: Conversation? {
        didSet {
            title = conversation?.first_name
        }
    }
    var isAllynn : String? = "true"
    var receiver_user_id: String?
    
    private lazy var messageRef: DatabaseReference = self.conversationRef!.child("messages")
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")

    private var newMessageRefHandle: DatabaseHandle?
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://sip-of-positivitea-e3b78.appspot.com")
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updatedMessageRefHandle: DatabaseHandle?


    private let imageURLNotSetKey = "NOTSET"
    var isViewingMessageDetail = true

    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        self.senderId = Auth.auth().currentUser?.uid
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            OneSignal.setSubscription(true)
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            
            let hasPrompted = status.permissionStatus.hasPrompted
            print("hasPrompted = \(hasPrompted)")
            let userStatus = status.permissionStatus.status
            print("userStatus = \(userStatus)")
            
            let isSubscribed = status.subscriptionStatus.subscribed
            print("isSubscribed = \(isSubscribed)")
            let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
            print("userSubscriptionSetting = \(userSubscriptionSetting)")
            let userID = status.subscriptionStatus.userId
            print("userID = \(userID)")
            self.usersRef.child(self.senderId).child("notification_user_id").setValue(userID)
            
        })
        
        
        let rightButtonItem = UIBarButtonItem.init(
            title: "Sign Out",
            style: .plain,
            target: self,
            action: #selector(ChatViewController.signOutPressed(sender:))
        )
        
        
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        if (self.conversationRef != nil) {
            observeMessages()
        }
        
        if title == nil {
            title = "Inspiration from Allynn"
        }
        print("title = " + title!)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewingMessageDetail = true

        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isViewingMessageDetail = false
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }

        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                
                    mediaItem.image = UIImage.init(data: data!)
                
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "date": [".sv": "timestamp"],
            ] as [String : Any]
        
        itemRef.setValue(messageItem) // 3
        if self.isAllynn == "false" {
            self.conversationRef?.child("allynn_read_messages").setValue(false);
        }

        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        if (self.receiver_user_id != nil) {
            self.usersRef.child(self.receiver_user_id!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if let userId = value?["notification_user_id"] {
                    if ((userId as! String) != "no_id") {
                        OneSignal.postNotification(["headings": ["en":senderDisplayName!], "contents": ["en":text!], "include_player_ids": [(userId as! String) ]])
                    }
                }
                
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }


        } else {
            
        }
        finishSendingMessage() // 5
    }
    
    func signOutPressed(sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
            present(loginViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    private func observeMessages() {
        messageRef = conversationRef!.child("messages")
        messageRef.keepSynced(true)
        // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            
            let id = messageData["senderId"] as! String
            
            if self.isAllynn == "true" {
                self.conversationRef?.child("allynn_read_messages").setValue(self.isViewingMessageDetail);
            }
            if let name = messageData["senderName"],
            let text = messageData["text"], (text as! String).characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: (name as! String), text: text as! String)
                //JSQSystemSoundPlayer.jsq_playMessageReceivedSound()

                self.conversationRef?.child("last_received_message").setValue(messageData["date"])
                
                // 5
                self.finishReceivingMessage()
            }
            else if let photoURL = messageData["photoURL"] { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    if messageData["date"] != nil {
                        self.conversationRef?.child("last_received_message").setValue(messageData["date"])

                    }
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    //JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL as! String, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, AnyObject> // 1
            
            if let photoURL = messageData["photoURL"], photoURL as! String != self.imageURLNotSetKey { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL as! String, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            "date": [".sv": "timestamp"]
            ] as [String : Any]
        
        itemRef.setValue(messageItem)
        if self.isAllynn == "false" {
            self.conversationRef?.child("allynn_read_messages").setValue(false);
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        if (self.receiver_user_id != nil) {
            self.usersRef.child(self.receiver_user_id!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if let userId = value?["notification_user_id"] {
                    if ((userId as! String) != "no_id") {
                        OneSignal.postNotification(["headings": ["en":self.senderDisplayName], "contents": ["en":"New Image Message"], "include_player_ids": [(userId as! String) ]])
                    }
                }
                
                // ...
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
        } else {
            
        }
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        
        present(picker, animated: true, completion:nil)
    }
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if (false){
            // Handle picking a Photo from the Photo Library
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
            }
        } else {
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
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
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message =  self.messages[indexPath.row]
        if message.isMediaMessage == true{
            let mediaItem =  message.media
            if mediaItem is JSQPhotoMediaItem{
                let photoItem = mediaItem as! JSQPhotoMediaItem
                if let image = photoItem.image {
                    let agrume = Agrume(image: image, backgroundBlurStyle: .light)
                    agrume.showFrom(self)
                }
          //      let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImgController") as! ImgViewController
           //     vc.image =  photoItem.image
            //    self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
}
