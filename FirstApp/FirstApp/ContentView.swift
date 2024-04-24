import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            MyTabView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.badge.waveform.fill")
                        
                }
            AIView()
                .tabItem {
                    Label("AI", systemImage: "mic.fill")
                        .foregroundColor(.white)
                }
            MyTabView()
                .tabItem {
                    Label("Text", systemImage: "keyboard.fill")
                        .foregroundColor(.white)
                }
            MyTabView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }
        }
        .onAppear() {
           // UITabBar.appearance().unselectedItemTintColor = .white
        }  
    }
}

// Rest of your code...

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
