//
//  GenerateModel.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/13/25.
//

struct GetChatTitleRequest: Encodable {
    let screenshotBase64: String
}

struct GetChatTitleReponse: Codable {
    let title: String
}


struct AnalyzeScreenshotRequest: Encodable {
    let screenshotBase64: String
    let tone: ToneTypes
    let context: String?
    let language: String?
}

struct AnalyzeScreenshotResponse: Codable {
    let tone: ToneTypes
    let content: [String]
    let nikname: String
    let dialogTitle: String
}
