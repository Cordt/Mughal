import XCTest
@testable import Mughal

final class MughalTests: XCTestCase {
    
    func testImageIsEncoded() {
        let url = Bundle.module.url(forResource: "Picture1", withExtension: "jpg")!
        let dlFolder = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let expectation = XCTestExpectation()
        
        generateWebP(image: url) { webData in
            expectation.fulfill()
//            let attachment = XCTAttachment(data: data!, uniformTypeIdentifier: "Picture1.webp")
//            attachment.lifetime = .keepAlways
//            attachment.name = "WebP"
//            self.add(attachment)
            
            let url = dlFolder.appendingPathComponent("Picture1.webp")
            try! webData?.write(to: url)
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }
}
