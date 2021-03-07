import XCTest
@testable import Mughal

final class MughalTests: XCTestCase {
    
    func testImageIsEncoded() {
        let url = Bundle.module.url(forResource: "Picture1", withExtension: "jpg")!
        let dlFolder = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let expectation = XCTestExpectation()
        
        generateWebP(from: url, with: 20) { webData in
            expectation.fulfill()
//            let attachment = XCTAttachment(data: data!, uniformTypeIdentifier: "Picture1.webp")
//            attachment.lifetime = .keepAlways
//            attachment.name = "WebP"
//            self.add(attachment)
            
            webData.forEach { image in
                image.save(at: dlFolder)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }
}
