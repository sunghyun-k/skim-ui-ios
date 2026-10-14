import SkimUI
import SwiftUI

@main
struct HeaderMakerApp: App {
    var body: some Scene {
        WindowGroup {
            ScrollView([.horizontal, .vertical]) { HeaderView() }
                .task { HeaderExport.run() }
        }
    }
}
