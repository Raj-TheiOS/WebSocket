//
//  ViewController.swift
//  WebSocket
//
//  Created by Raj Rathod on 31/01/22.
//

import UIKit

class ViewController: UIViewController {

    private var webSocket: URLSessionWebSocketTask?
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Close", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        self.view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
    }

    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping Error: ",error)
            }
        })
    }
   @objc func close() {
       print("close")
        webSocket?.cancel(with: .goingAway, reason: "Demo Ended".data(using: .utf8))
    }
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            self.webSocket?.send(.string("Send Message: \(Int.random(in: 0...1000))"), completionHandler: { error in
                if let error = error {
                    print("Send Error: ",error)
                }
            })
            self.send()
        }
    }
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let response):
                switch response {
                case .data(let data):
                    print("Data received", data)
                case.string(let message):
                    print("String received", message)
                @unknown default:
                    break
                }
            case .failure(let error):
                print(error)
            }
            self?.receive()
        })
    }
}

extension ViewController: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        ping()
        receive()
        send()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close with reason")
    }
}
