import Foundation

public class DLDownloader {
    private(set) var archive: DLHTTPArchive
    var m3u8Data: [Data] = .init()
    
    public init(archive: DLHTTPArchive) {
        self.archive = archive
    }
    
    public func download() throws {
        try handleM3U8Data()
    }
    
    public func exportAllM3U8DFiles() throws {
        try handleM3U8Data()
        let documentsDirectory = Bundle.main.bundleURL
        for m3u8_index in 0 ... (m3u8Data.count - 1) {
            let fileURL = documentsDirectory.appendingPathComponent("normal_\(m3u8_index + 1).m3u8")
            try String(data: m3u8Data[m3u8_index], encoding: .utf8)?.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    func handleM3U8Data() throws {
        for entry in self.archive.log.entries {
            guard let data = entry.response.content.text.data(using: .utf8),
                  var urlComponents = URLComponents(string: entry.request.url) else { throw CancellationError() }
            urlComponents.path = "/live_hp/"
            urlComponents.query = nil
            guard let decodedData = Data(base64Encoded: data),
                  let urlString = urlComponents.string else { throw CancellationError() }
            guard var decodedString = String(data: decodedData, encoding: .utf8) else { throw CancellationError() }
            decodedString.replace(",\n", with: ",\n\(urlString)")
            guard let decodedAndReplacedData = decodedString.data(using: .utf8) else { throw CancellationError() }
            self.m3u8Data.append(decodedAndReplacedData)
        }
    }
}

public struct DLHTTPArchive: Codable {
    struct DLSectionJsonTemplate: Codable {
        var name: String
        var value: String
    }
    
    struct DLLogJsonModel: Codable {
        var version: String
        var creator: DLCreatorJsonModel
        var entries: [DLEntryJsonModel]
    }
    
    struct DLCreatorJsonModel: Codable {
        var name: String
        var version: String
    }
    
    struct DLRequestJsonModel: Codable {
        var method: String
        var url: String
        var httpVersion: String
        var cookies: [DLCookieJsonModel]
        var headers: [DLHeaderJsonModel]
        var queryString: [DLQueryStringJsonModel]
        var headersSize: Int
        var bodySize: Int
    }
    
    typealias DLCookieJsonModel = DLSectionJsonTemplate
    
    typealias DLHeaderJsonModel = DLSectionJsonTemplate
    
    typealias DLQueryStringJsonModel = DLSectionJsonTemplate
    
    struct DLResponseJsonModel: Codable {
        var _charlesStatus: String
        var status: Int
        var statusText: String?
        var httpVersion: String
        var cookies: [DLCookieJsonModel]
        var headers: [DLHeaderJsonModel]
        var content: DLContentJsonModel
        var redirectURL: String?
        var headersSize: Int
        var bodySize: Int
    }
    
    struct DLContentJsonModel: Codable {
        var size: Int
        var mimeType: String
        var text: String
        var encoding: String
    }
    
    struct DLCacheJsonModel: Codable {
        // Temporarily unkown it's structue, so leave it blank
    }
    
    struct DLTimingJsonModel: Codable {
        var dns: Int
        var connect: Int
        var ssl: Int
        var send: Int
        var wait: Int
        var receive: Int
    }
    
    struct DLEntryJsonModel: Codable {
        var startedDateTime: String
        var time: Int
        var request: DLRequestJsonModel
        var response: DLResponseJsonModel
        var serverIPAddress: String
        var cache: DLCacheJsonModel
        var timings: DLTimingJsonModel
    }
    
    var log: DLLogJsonModel
}
