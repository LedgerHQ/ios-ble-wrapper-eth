import XCTest
@testable import EthWrapper

final class EthWrapperTests: XCTestCase {
    func testEthInstanceIsNotNil() {
        let eth = EthWrapper()
        XCTAssertNotNil(eth.ethInstance)
    }
}
