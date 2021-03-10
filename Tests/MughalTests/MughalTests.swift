import XCTest
@testable import Mughal

final class MughalTests: XCTestCase {
    
    func testImageIsEncoded() {
        let url1 = Bundle.module.url(forResource: "Picture1", withExtension: "jpg")!
        let url2 = Bundle.module.url(forResource: "Picture2", withExtension: "jpg")!
        let dlFolder = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let expectation = XCTestExpectation()
        
        let images = WebP.generateWebP(with: .low, from: [url1, url2])
        images.run { images in
            images.forEach { image in
                image.save(at: dlFolder)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
