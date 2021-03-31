//
//  ChatViewController.swift
//  MultipeerChat
//
//  Created by Tihomir RAdeff on 13.01.21.
//

import UIKit
import MultipeerConnectivity

class ChatViewController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var historyText: UITextView!
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
    var history = ""
    var nickname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        historyText.isEditable = false
        
        //get the nickname
        nickname = UserDefaults.standard.string(forKey: "nickname")!
        
        peerID = MCPeerID(displayName: nickname)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        sendButton.isEnabled = false
        
        history = history + "No room!\n"
        historyText.text = history
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func hostButtonAction(_ sender: Any) {
        startHosting()
        
        history = history + "Started hosting!\n"
        historyText.text = history
        
        hostButton.isEnabled = false
        guestButton.isEnabled = false
    }
    
    @IBAction func guestButtonAction(_ sender: Any) {
        joinRoom()
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        let message = messageText.text
        if message != "" {
            sendData(data: nickname + ": " + message!)
            
            history = history + nickname + ": " + message! + "\n"
            historyText.text = history
            
            messageText.text = ""
        }
    }
    
    // MARK: - My functions
    
    func sendData(data: String) {
        if mcSession.connectedPeers.count > 0 {
            if let textData = data.data(using: .utf8) {
                do {
                    //send data
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    //error sending
                    print(error.localizedDescription)
                    history = history + "Error sending message!\n"
                    historyText.text = history
                }
            }
        }
    }
    
    func startHosting() {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "mp-chat")
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()
    }
    
    func joinRoom() {
        let mcBrowser = MCBrowserViewController(serviceType: "mp-chat", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // MARK: - Multipeer Skeleton
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            history = history + "Connected: \(peerID.displayName)\n"
            DispatchQueue.main.async {
                self.historyText.text = self.history
                self.sendButton.isEnabled = true
            }
            
        case MCSessionState.connecting:
            history = history + "Connecting: \(peerID.displayName)\n"
            DispatchQueue.main.async {
                self.historyText.text = self.history
                self.sendButton.isEnabled = true
            }
            
        case MCSessionState.notConnected:
            history = history + "Not connected: \(peerID.displayName)\n"
            DispatchQueue.main.async {
                self.historyText.text = self.history
                self.sendButton.isEnabled = false
            }
            
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.history = self.history + "\(text)\n"
                self.historyText.text = self.history
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //empty
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //empty
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //empty
    }
    
    // MARK: - Browser Methods
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Advertiser Methods
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //accept the invitation
        invitationHandler(true, mcSession)
    }
}
