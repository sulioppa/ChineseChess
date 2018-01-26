//
//  MultipeerManager.swift
//  ChineseChess
//
//  Created by 李夙璃 on 2018/1/23.
//  Copyright © 2018年 StarLab. All rights reserved.
//

import UIKit
import MultipeerConnectivity

public enum MultipeerManagerConnectionState: Int {
	case disconnected = -1
	case connecting = 0
	case connected = 1
}

public protocol MultipeerManagerDelegate: NSObjectProtocol {
	
	func multipeerManager(_ manager: MultipeerManager, didReceive dictionary: [String: Any])
	
	func multipeerManager(_ manager: MultipeerManager, state: MultipeerManagerConnectionState, name: String)
	
}

// MARK: - MultipeerManager
public class MultipeerManager: NSObject {
	
	public static let shared: MultipeerManager = MultipeerManager()
	
	public weak var delegate: MultipeerManagerDelegate? = nil
	
	// MARK: - Private
	private var session: MCSession?
	private var advertiser: MCAdvertiserAssistant?
	
	private override init() {
		super.init()
	}
	
	// MARK: - Public
	public final func start(isBroswerMode: Bool, viewcontroller: UIViewController?, displayName: String) {
		self.disconnect()
		
		let session = MCSession(peer: MCPeerID(displayName: displayName))
		self.session = session
		
		if isBroswerMode {
			let broswer = MCBrowserViewController(serviceType: Macro.Project.name, session: session)
			broswer.delegate = self
			viewcontroller?.present(broswer, animated: true, completion: nil)
		} else {
			self.advertiser = MCAdvertiserAssistant(serviceType: Macro.Project.name, discoveryInfo: nil, session: session)
			self.advertiser?.start()
		}
	}
	
	public final func stop() {
		self.advertiser?.stop()
		self.advertiser = nil
	}
	
	public final func write(dictionary: [String: Any]) {
		guard let data = dictionary.data, let peer = self.session?.connectedPeers.first else { return }
		
		try? self.session?.send(data, toPeers: [peer], with: .unreliable)
	}
	
	public final func disconnect() {
		self.session?.disconnect()
		self.session = nil
		self.advertiser?.stop()
		self.advertiser = nil
	}
	
}

// MARK: - MCSessionDelegate
extension MultipeerManager: MCSessionDelegate {
	
	public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		var connectionState: MultipeerManagerConnectionState = .disconnected
		
		switch state {
		case .connecting:
			connectionState = .connecting
		case .connected:
			connectionState = .connected
			self.stop()
		default:
			break
		}
		
		self.delegate?.multipeerManager(self, state: connectionState, name: peerID.displayName)
	}

	public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		guard let dictionary = Dictionary<String, Any>.dictionary(from: data) else { return }
		
		self.delegate?.multipeerManager(self, didReceive: dictionary)
	}
	
}

// MARK: - MCBrowserViewControllerDelegate
extension MultipeerManager: MCBrowserViewControllerDelegate {
	
	public func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		browserViewController.dismiss(animated: true, completion: nil)
	}
	
	public func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		self.disconnect()
		browserViewController.dismiss(animated: true, completion: nil)
	}
	
	public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		
	}
	
	public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		
	}
	
	public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		
	}
	
}
