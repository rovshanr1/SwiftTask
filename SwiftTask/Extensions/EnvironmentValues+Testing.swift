import SwiftUI

private struct TestingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isTestingEnvironment: Bool {
        get { self[TestingEnvironmentKey.self] }
        set { self[TestingEnvironmentKey.self] = newValue }
    }
}

extension View {
    func testingEnvironment(_ value: Bool) -> some View {
        environment(\.isTestingEnvironment, value)
    }
} 