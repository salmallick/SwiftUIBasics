//
//  AIView.swift
//  FirstApp
//
//  Created by Salman on 4/20/24.
//


import Foundation
import SwiftUI
import llmfarm_core


public struct AIView: View {
    @State private var availableStorage: Int64?
    @State private var isDownloading = false
    @State var isBusy = false
    @State var generatedString = ""
    @State var chat: AI?

    init() {
        availableStorage = getAvailableStorage()
    }
    @State private var modelName = "TinyLlama 1B"
    @State private var modelUrl = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q8_0.gguf?download=true"
    @State private var filename = "tinyllama-1.1b-chat-v1.0.Q8_0.gguf"
    @State private var status = "download"

    
    
   public var body: some View {
        VStack {
//            if isBusy {
//                ProgressView()
//            }
            if let availableStorage = availableStorage, availableStorage < 4_000_000_000 {
                Text("You have \(ByteCountFormatter.string(fromByteCount: availableStorage, countStyle: .file)) of space available. 4 GB is needed")
            }
            DownloadButton(modelName: $modelName, modelUrl:  $modelUrl, filename:  $filename, status: $status)
            if status == "downloaded"{
                Button("Generate"){
                    performAIMagic()
                }
            }
            if generatedString != ""{
                Text("Generated Text: " + generatedString)
            }
        }
    }
    
    func performAIMagic(){
        let fileURL = getFileURLFormPathStr(dir:"models",filename: filename)
        print(fileURL.path)
        isBusy = true
        chat = AI(_modelPath: fileURL.path, _chatName: "chat")
        var params:ModelAndContextParams = .default
        params.context = 4095
        params.n_threads = 14
        params.use_metal = true
        var modelInference:ModelInference = ModelInference.LLama_gguf // ModelInference.GPT2
        do{
            var didLoad = try chat?.loadModel(modelInference, contextParams: params)//.loadModel_sync(modelInference,contextParams: params)
            print("didLoad")
            print(didLoad)
        }catch {
            print("Error getting available storage")
        }

        chat?.conversation("What's the sum of 1+2?",{ str, time in //Predicting
                print(str)
                print(time)
            },                          { final_str in // Finish predicting
                print(final_str)
                generatedString = final_str
                isBusy = false
            })
    }
    
    func getAvailableStorage() -> Int64? {
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        do {
            let values = try documentDirectoryURL?.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let availableCapacity = values?.volumeAvailableCapacityForImportantUsage {
                return availableCapacity
            }
        } catch {
            print("Error getting available storage")
        }
        return nil
    }
}
