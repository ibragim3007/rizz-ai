//
//  crush_ai_widgetLiveActivity.swift
//  crush-ai-widget
//
//  Created by Ibragim Ibragimov on 10/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct crush_ai_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct crush_ai_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: crush_ai_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension crush_ai_widgetAttributes {
    fileprivate static var preview: crush_ai_widgetAttributes {
        crush_ai_widgetAttributes(name: "World")
    }
}

extension crush_ai_widgetAttributes.ContentState {
    fileprivate static var smiley: crush_ai_widgetAttributes.ContentState {
        crush_ai_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: crush_ai_widgetAttributes.ContentState {
         crush_ai_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: crush_ai_widgetAttributes.preview) {
   crush_ai_widgetLiveActivity()
} contentStates: {
    crush_ai_widgetAttributes.ContentState.smiley
    crush_ai_widgetAttributes.ContentState.starEyes
}
