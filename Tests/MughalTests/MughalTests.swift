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
        let targetDimensions1 = sizeThatFits(for: (640, 960), within: 600)
        let url2 = Bundle.module.url(forResource: "Picture2", withExtension: "jpg")!
        let targetDimensions2 = sizeThatFits(for: (2048, 1430), within: 600)
        
        let expectation = XCTestExpectation()
        
        let images = WebP.generateImages(
            with: .low,
            for: [
                ImageConfiguration(url: url1, targetExtension: .webp, targetDimensions: targetDimensions1),
                ImageConfiguration(url: url2, targetExtension: .webp, targetDimensions: targetDimensions2)
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
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDirectory.appendingPathComponent("Picture1.webp").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDirectory.appendingPathComponent("Picture2.webp").path))
        
        // Images have correct dimensions
        let image1 = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture1.webp"))!
        let image2 = CIImage(contentsOf: testDirectory.appendingPathComponent("Picture2.webp"))!
        XCTAssertTrue(image1.extent.width <= 600 && image1.extent.height <= 600)
        XCTAssertTrue(image2.extent.width <= 600 && image2.extent.height <= 600)
    }
}
