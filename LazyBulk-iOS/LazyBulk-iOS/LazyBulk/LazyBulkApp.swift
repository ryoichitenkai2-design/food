import SwiftUI

@main
struct LazyBulkApp: App {
    @StateObject private var store = Store()
    var body: some Scene {
        WindowGroup {
            TabView {
                FoodView().tabItem { Label("Food", systemImage: "fork.knife") }
                GearView().tabItem { Label("Containers", systemImage: "shippingbox") }
                MyListView().tabItem { Label("My list", systemImage: "checklist") }
            }
            .tint(.green)
            .environmentObject(store)
        }
    }
}
