import SwiftUI

struct DownloadButton: View {
    
    @Binding var modelName: String
    @Binding var modelUrl: String
    @Binding var filename: String
    
    @Binding var status: String
    
    @State private var downloadTask: URLSessionDownloadTask?
    @State private var progress = 0.0
    @State private var observation: NSKeyValueObservation?
    

    
    private func checkFileExistenceAndUpdateStatus() {
    }
    
    func getFileURLFormPathStr(dir:String,filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dir).appendingPathComponent(filename)
    }
    
    private func download() {
        
        status = "downloading"
        print("Downloading model \(modelName) from \(modelUrl)")
        guard let url = URL(string: modelUrl) else { return }
        let fileURL = getFileURLFormPathStr(dir:"models",filename: filename)
        
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
            
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            status = "downloaded"
            return
        }

        downloadTask = URLSession.shared.downloadTask(with: url) { temporaryURL, response, error in
            if let error = error {
                print("Salman Checkpoint")
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            print("temporaryURL")
            print(temporaryURL)
            do {
                if let temporaryURL = temporaryURL {
                    print("fileURL")
                    print(fileURL)
                    try FileManager.default.copyItem(atPath: temporaryURL.path, toPath: fileURL.path)
                    print("Writing to \(filename) completed")
                    
                    
                    
                    //let model = Model(name: modelName, url: modelUrl, filename: filename, status: "downloaded")
                    status = "downloaded"
                }
            } catch let err {
                print("Checkpoint 2")
                print("Error: \(err.localizedDescription)")
            }
        }
        
        observation = downloadTask?.progress.observe(\.fractionCompleted) { progress, _ in
            self.progress = progress.fractionCompleted
        }
        
        downloadTask?.resume()
    }
    
    var body: some View {
        VStack {
            switch status {
            case "download":
                    Button(action: download) {
                        Image(systemName:"icloud.and.arrow.down")
                    }
                    .buttonStyle(.borderless)
            case "downloading":
                    Button(action: {
                        downloadTask?.cancel()
                        status = "download"
                    }) {
                        HStack{
                            Image(systemName:"stop.circle.fill")
                            Text("\(Int(progress * 100))%")
                                .padding(.trailing,-20)
                        }
                    }
                    .buttonStyle(.borderless)
            case "downloaded":
                    Image(systemName:"checkmark.circle.fill")
            default:
                    Text("Unknown status")
            }
        }
        .onDisappear() {
            downloadTask?.cancel()
        }.onChange(of: status) { st in
            print(st)
        }
        // .onChange(of: llamaState.cacheCleared) { newValue in
        //     if newValue {
        //         downloadTask?.cancel()
        //         let fileURL = DownloadButton.getFileURL(filename: filename)
        //         status = FileManager.default.fileExists(atPath: fileURL.path) ? "downloaded" : "download"
        //     }
        // }
    }
}

