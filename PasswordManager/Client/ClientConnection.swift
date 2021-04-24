import Foundation
import Network

@available(iOS 12.0, macOS 10.14, *)
class ClientConnection {

    let  nwConnection: NWConnection
    let queue = DispatchQueue(label: "Client connection Q")
    var last_recieve = ""
    var open = true
    
    enum connectionError: Error {
        case connectionDidFail
    }
    
    init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start(){
        nwConnection.stateUpdateHandler = stateDidChange(to:)
        setupReceive()
        nwConnection.start(queue: queue)
    }
    
    func isReady() -> Bool{
        var state = nwConnection.state
        let start = Date()
        let timeToLive: TimeInterval = 10 // 10 Seconds
        while true {
            state = nwConnection.state
            if Date().timeIntervalSince(start) >= timeToLive {
                print("Connection Timed out")
                return false
            }
            
            switch state {
            case .ready:
                return true
                
            case .preparing:
                continue
            
            case .setup:
                continue
                
            case .waiting:
                continue
            
            default: //.failed .waiting .cancelled
                print("STATE: \(state)")
                return false
            }
        }
        
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            print("WAITING")
            //connectionDidFail(error: error)
        case .ready:
            print("Client connection ready")
        case .failed(let error):
            print("Failed")
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        if open {
            nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
                if let data = data, !data.isEmpty {
                    let message = String(data: data, encoding: .utf8)
                    print("connection did receive, data: \(data as NSData)")
                    self.last_recieve = message ?? ""
                }
                if isComplete {
                    self.connectionDidEnd()
                } else if let error = error {
                    self.connectionDidFail(error: error)
                } else {
                    self.setupReceive()
                }
            }
        }
    }
    func getReceive() -> String{
        while self.last_recieve == ""{
        }
        let received = self.last_recieve
        self.last_recieve = ""
        return received
    }
    
    func send(data: Data){
        print("Sending...")
        nwConnection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
                print("connection did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection will stop")
        stop(error: nil)
    }

    private func connectionDidFail(error: Error) {
        print("connection did fail, error: \(error)")
        self.stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection did end")
        self.stop(error: nil)
    }

    private func stop(error: Error?) {
        self.open = false
        self.nwConnection.stateUpdateHandler = nil
        self.nwConnection.cancel()
        if let didStopCallback = self.didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}
