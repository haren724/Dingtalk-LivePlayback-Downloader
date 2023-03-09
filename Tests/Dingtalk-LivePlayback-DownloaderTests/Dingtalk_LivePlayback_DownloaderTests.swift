import XCTest
@testable import Dingtalk_LivePlayback_Downloader

final class Dingtalk_LivePlayback_DownloaderTests: XCTestCase {
    
    var url: URL = Bundle.module.url(forResource: "test-model", withExtension: "har")!
    var archive: DLHTTPArchive?
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        print((try? String(contentsOf: url) + "f") ?? "⚠️⚠️")
//        print("dsjlkfs")
//        XCTAssertEqual(Dingtalk_LivePlayback_Downloader().text, "Hello, World!")
    }
    
    func testJSONEncoder() throws {
        print(String(data: try JSONEncoder().encode(DLHTTPArchive(log: .init(version: "1.2", creator: .init(name: "Charles Proxy", version: "4.2"), entries: [.init(startedDateTime: "", time: 0, request: .init(method: "", url: "", httpVersion: "", cookies: [.init(name: "", value: "")], headers: [.init(name: "", value: "")], queryString: [.init(name: "", value: "")], headersSize: 0, bodySize: 0), response: .init(_charlesStatus: "", status: 0, statusText: "", httpVersion: "", cookies: [.init(name: "", value: "")], headers: [.init(name: "", value: "")], content: .init(size: 0, mimeType: "", text: "", encoding: ""), redirectURL: "", headersSize: 0, bodySize: 0), serverIPAddress: "", cache: .init(), timings: .init(dns: 0, connect: 0, ssl: 0, send: 0, wait: 0, receive: 0))]))), encoding: .utf8) ?? "???")
    }
    
    func testDataWillPassedCorrectly() throws {
        try self.archive = JSONDecoder().decode(DLHTTPArchive.self, from: try Data(contentsOf: self.url))
    }
    
    func testM3U8ContentWillParsed() throws {
        try testDataWillPassedCorrectly()
        guard let archive = self.archive else { throw CancellationError() }
        guard let data = archive.log.entries[0].response.content.text.data(using: .utf8) else { throw CancellationError() }
        print(String(data: Data(base64Encoded: data)!, encoding: .utf8) ?? "???")
    }
    
    func testM3U8FilesAreReplacedProperly() throws {
        try testDataWillPassedCorrectly()
        let downloader = DLDownloader(archive: self.archive!)
        try downloader.download()
    }
}
