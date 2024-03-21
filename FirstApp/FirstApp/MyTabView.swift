import SwiftUI

struct MyTabView: View {
    @State private var sliderValue1: Double = 1
    @State private var sliderValue2: Double = 60
    @State private var isEditing1 = false
    @State private var isEditing2 = false
    @State private var isToggled = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            
            VStack {
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 20) {
                            HStack {
                                Spacer()
                                Text(NSLocalizedString("ALERT", comment: "")).font(.title).foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    self.showingAlert = true
                                }) {
                                    Image(systemName: "info.circle.fill").font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text(NSLocalizedString("Alert Frequency", comment: "")).font(.title).foregroundColor(.white)
                            HStack {
                                Text("1s").foregroundColor(.white)
                                Slider(
                                    value: $sliderValue1,
                                    in: 1...10,
                                    onEditingChanged: { editing in
                                        isEditing1 = editing
                                    }
                                )
                                .accentColor(isEditing1 ? .blue : .white)
                                Text("10s").foregroundColor(.white)
                            }
                            Text("\(Int(sliderValue1))s").foregroundColor(.white)
                            
                            Text("Noise Threshold", comment: "").font(.title).foregroundColor(.white)
                            HStack {
                                Image(systemName: "speaker.wave.1.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                                Slider(
                                    value: $sliderValue2,
                                    in: 60...120,
                                    onEditingChanged: { editing in
                                        isEditing2 = editing
                                    }
                                )
                                .accentColor(isEditing2 ? .blue : .white)
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                            Text("\(Int(sliderValue2)) db").foregroundColor(.white)
                                .padding(.horizontal, 2)
                            
                            Button(action: {
                                print("")
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 150, height: 200)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                }
                            }
                            Text("Start Noise Threshold")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            ZStack {
                                Toggle(isOn: $isToggled) {
                                    Text("Mark alerts as critical").font(.title).foregroundColor(.white)
                                }
                                
                                NavigationLink(destination: BlankPage()) {
                                    Text("                                      ")
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.blue)
                                        .font(.title)
                                }
                                
                                
                            }
                        }
                    )
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Welcome to Salman's project"), message: nil, dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Alert")
    }
}

struct BlankPage: View {
    var body: some View {
        Text("This is a blank page")
    }
}

#if DEBUG
struct MyTabView_Previews: PreviewProvider {
    static var previews: some View {
        MyTabView()
    }
}
#endif
