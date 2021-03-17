import XCTest
@testable import Mughal

extension Image {
    /// Saves one image for each size class at the given path
    fileprivate func save(at path: URL, as fileName: String) {
        let url = path.appendingPathComponent(fileName)
        do {
            try imageData.write(to: url)
            
        } catch {
            print("Failed to write images to disk")
        }
    }
}

final class MughalTests: XCTestCase {
    
    // MARK: - Properties
    
    private var testDirectory: URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Output")
    }
    
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default
            .createDirectory(at: testDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default
            .removeItem(at: testDirectory)
    }
        
        
    // MARK: - Tests
    
    func testImageIsEncoded() {
        let url1 = Bundle.module.url(forResource: "Picture1", withExtension: "jpg")!
        let url2 = Bundle.module.url(forResource: "Picture2", withExtension: "jpg")!
        let sizes1 = [
            ImageConfiguration.Size(fileName: "Picture1-small", dimensionsUpperBound: 600),
            ImageConfiguration.Size(fileName: "Picture1-large", dimensionsUpperBound: 1200)
        ]
        let sizes2 = [
            ImageConfiguration.Size(fileName: "Picture2-small", dimensionsUpperBound: 600),
            ImageConfiguration.Size(fileName: "Picture2-large", dimensionsUpperBound: 1200)
        ]
        
        let expectation = XCTestExpectation()
        
        let images = WebP.generateImages(
            with: .low,
            for: [
                ImageConfiguration(url: url1, extension: .jpg, targetExtension: .webp, targetSizes: sizes1),
                ImageConfiguration(url: url2, extension: .jpg, targetExtension: .webp, targetSizes: sizes2)
            ]
        )
        images.run { images in
            images.forEach { image in
                image.save(at: self.testDirectory, as: "\(image.name).\(image.extension.rawValue)")
            }
            expectation.fulfill()
        }
        
        // Images have been created
        wait(for: [expectation], timeout: 2.0)
        
        // Images have been stored to the designated location
        guard let image1Small = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture1-small.webp")),
              let image1Large = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture1-large.webp")),
              let image2Small = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture2-small.webp")),
              let image2Large = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture2-large.webp")) else {
            XCTFail("Expected images have not been created")
            return
        }
        
        // Images have correct dimensions
        XCTAssertTrue(image1Small.extent.width <= 600 && image1Small.extent.height <= 600)
        XCTAssertTrue(image1Large.extent.width <= 1200 && image1Large.extent.height <= 1200)
        XCTAssertTrue(image2Small.extent.width <= 600 && image2Small.extent.height <= 600)
        XCTAssertTrue(image2Large.extent.width <= 1200 && image2Large.extent.height <= 1200)
    }
}
