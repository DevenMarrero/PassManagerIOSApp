import Foundation
import Network

var gHost: String = ""
var gPort: UInt16 = 8050

class Conn {
    static let shared = Conn(host: gHost, port: gPort)
    
    var client: Client
    
    private init(host: String, port: UInt16) {
        client = Client(host: host, port: port)
    }
    
    func reset() {
        client = Client(host: gHost, port: gPort)
    }
}

@available(iOS 12.0, macOS 10.14, *)
class Client {
    let connection: ClientConnection
    let host: NWEndpoint.Host
    let port: NWEndpoint.Port

    init(host: String, port: UInt16) {
        self.host = NWEndpoint.Host(host)
        self.port = NWEndpoint.Port(rawValue: port)!
        let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
        connection = ClientConnection(nwConnection: nwConnection)
    }

    func start(){
        print("Client started \(host) \(port)")
        connection.didStopCallback = didStopCallback(error:)
        connection.start()
    }

    func stop() {
        connection.stop()
    }

    func send(msg: String){
        connection.send(data: (msg.data(using: .utf8))!)
    }
    
    func getReceive() -> String{
        return connection.getReceive()
    }
    
    func isReady() -> Bool {
        return connection.isReady()
    }

    func didStopCallback(error: Error?) {
        if error == nil {
            print("Disconnected")
        } else {
            print("Error disconnecting: \(error!)")
        }
    }
}

