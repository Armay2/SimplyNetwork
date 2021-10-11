import XCTest
@testable import SimplyNetwork

class SimplyNetworkTests: XCTestCase {
    
    let timeout: TimeInterval = 10
    
    func testExample() {
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
}

extension SimplyNetworkTests {
    // MARK: - Welcome
    struct Welcome: Codable {
        let slideshow: Slideshow
    }
    
    // MARK: - Slideshow
    struct Slideshow: Codable {
        let author, date: String
        let slides: [Slide]
        let title: String
    }
    
    // MARK: - Slide
    struct Slide: Codable {
        let title, type: String
        let items: [String]?
    }
    
    // MARK: - Activity
    struct Activity: Codable {
        var activity: String
        var type: String
        var participants: Int
        var price: Double
        var link: String
        var key: String
        var accessibility: Double
    }
}

extension SimplyNetworkTests {
    
    // MARK: - Tester
    struct Tester: Codable {
        let args: Args
        let data: String
        let files, form: Files
        let headers: Headers
        let testerJSON: JSONNull?
        let method, origin: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case args, data, files, form, headers
            case testerJSON = "json"
            case method, origin, url
        }
    }
    
    // MARK: - Args
    struct Args: Codable {
        let value1, value2: String
    }
    
    // MARK: - Files
    struct Files: Codable {
    }
    
    // MARK: - Headers
    struct Headers: Codable {
        let accept, acceptEncoding, acceptLanguage, host: String
        let secFetchDest, secFetchMode, secFetchSite, secFetchUser: String
        let secGpc, upgradeInsecureRequests, userAgent, xAmznTraceID: String
        
        enum CodingKeys: String, CodingKey {
            case accept = "Accept"
            case acceptEncoding = "Accept-Encoding"
            case acceptLanguage = "Accept-Language"
            case host = "Host"
            case secFetchDest = "Sec-Fetch-Dest"
            case secFetchMode = "Sec-Fetch-Mode"
            case secFetchSite = "Sec-Fetch-Site"
            case secFetchUser = "Sec-Fetch-User"
            case secGpc = "Sec-Gpc"
            case upgradeInsecureRequests = "Upgrade-Insecure-Requests"
            case userAgent = "User-Agent"
            case xAmznTraceID = "X-Amzn-Trace-Id"
        }
    }
    
    // MARK: - Encode/decode helpers
    
    class JSONNull: Codable, Hashable {
        
        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }
        
        public var hashValue: Int {
            return 0
        }
        
        public init() {}
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
}
