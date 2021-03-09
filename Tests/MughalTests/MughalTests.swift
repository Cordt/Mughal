import XCTest
@testable import Mughal

final class MughalTests: XCTestCase {
    
    func testImageIsEncoded() {
        let url = Bundle.module.url(forResource: "Picture1", withExtension: "jpg")!
        let dlFolder = try! FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let expectation = XCTestExpectation()
        print(url)
        let images = WebP.generateWebP(from: url, with: .low)
        images.run { images in
            images.forEach { image in
                image.save(at: dlFolder)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
