//
//  crush_aiApp.swift
//  crush-ai
//
//  Created by Ibragim Ibragimov on 10/1/25.
//

import SwiftUI
import SwiftData
import RevenueCat

// MARK: - AppActions environment (для системных действий приложения, напр. Reset Store)
struct AppActions {
    var resetStore: () async -> Void = { }
}

private struct AppActionsKey: EnvironmentKey {
    static let defaultValue = AppActions()
}

extension EnvironmentValues {
    var appActions: AppActions {
        get { self[AppActionsKey.self] }
        set { self[AppActionsKey.self] = newValue }
    }
}

@main
struct crush_aiApp: App {
    // Делаем контейнер заменяемым, чтобы можно было пересоздать после wipe
    @State private var container: ModelContainer = crush_aiApp.makeContainer()
    
    // Единый Schema
    private static let schema = Schema([ImageEntity.self, ReplyEntity.self, DialogEntity.self, DialogGroupEntity.self])
    
    // Фабрика основного контейнера на диске
    static func makeContainer() -> ModelContainer {
        // Можно добавить свою конфигурацию с кастомным URL при желании
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }
    
    // Фабрика временного in-memory контейнера (чтобы “закрыть” файлы перед удалением)
    static func makeInMemoryContainer() -> ModelContainer {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [cfg])
        return container
    }
    
    
    
    init () {
        // инициализация revenuecat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_LwbkcAhtxVUApPlwfEPnGaftWRc")
        
    }
    
    @StateObject var paywallViewModel = PaywallViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .environment(\.appActions, AppActions(resetStore: { [weak _container = containerRef] in
            await resetStore()
        }))
        .environmentObject(paywallViewModel)
        // Хак: захват ссылки на self.container в замыкании environment
        .onChange(of: container) { _, _ in
            // no-op, просто держим State живым
        }
    }
    
    // MARK: - Reset Store
    // Полностью удаляет файлы SwiftData стора и пересоздаёт контейнер.
    private func resetStore() async {
        // 1) Сохраняем URLs текущего стора
        let urls = container.configurations.flatMap { cfg -> [URL] in
            let base = cfg.url
            return [base,
                    URL(fileURLWithPath: base.path + "-wal"),
                    URL(fileURLWithPath: base.path + "-shm")]
        }
        
        // 2) Переключаемся на временный in-memory контейнер, чтобы “освободить” файлы
        await MainActor.run {
            container = crush_aiApp.makeInMemoryContainer()
        }
        
        // 3) Удаляем файлы стора
        let fm = FileManager.default
        for url in urls {
            if fm.fileExists(atPath: url.path) {
                try? fm.removeItem(at: url)
            }
        }
        
        // 4) Пересоздаём чистый контейнер на диске
        await MainActor.run {
            container = crush_aiApp.makeContainer()
        }
    }
    
    // Хелпер, чтобы корректно захватить ссылку на State в environment
    private var containerRef: ModelContainer {
        container
    }
}

