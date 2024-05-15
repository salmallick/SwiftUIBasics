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
        
        func performAIMagic() {
            let fileURL = getFileURLFormPathStr(dir: "models", filename: filename)
            print(fileURL.path)
            isBusy = true
            chat = AI(_modelPath: fileURL.path, _chatName: "chat")
            var params: ModelAndContextParams = .default
            var sampleParams = ModelSampleParams.default

            params.promptFormat = .Custom
            
            params.custom_prompt_format = """
            SYSTEM: You are a Math Professor.
            USER: {prompt}
            ASSISTANT:
            """
            params.context = 2048
//            params.template_name = "TinyLLaMa 1B"
            sampleParams.temp = 0.89999997615814209
//            sampleParams.model_inference = "llama"
            sampleParams.top_p = 0.94999998807907104
            sampleParams.n_batch = 512
            sampleParams.top_k = 40
//            "use_metal" : true,
            params.add_bos_token = false
            params.parse_special_tokens = true

//            params.context = 1024
            params.n_threads = 1
            params.use_metal = true // Exists on iPhone 13 as well, much faster when true
//            params.promptFormat = .None
            let modelInference: ModelInference = .LLama_gguf

            do {
                var didLoad = try chat?.loadModel(ModelInference.LLama_gguf, contextParams: params)

                if let chat = chat {
                    chat.model.sampleParams = sampleParams
                }
            } catch {
                print("Error loading the model")
            }

            // Trial 1: Improve the prompt
            let initialPrompt = "If 2+2=4 and 5+5=10, What is the result of 1+1? Only provide the solution briefly without any explanation" //
            chat?.conversation(initialPrompt, { str, time in
                // Predicting
            }, { final_str in
                print(final_str)
                generatedString = final_str
                isBusy = false
            })

            print(initialPrompt)
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
