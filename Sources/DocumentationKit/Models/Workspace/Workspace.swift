//
//  Workspace.swift
//  DocumentationKit
//
//  Copyright © 2024 Noah Kamara.
//

////
////  File.swift
////  DocumentationKit
////
////  Created by Noah Kamara on 20.11.24.
////
//
// import Foundation
//
// public extension Workspace {
//    struct Configuration {
//        public var inMemory: Bool
//
//        public init(inMemory: Bool = false) {
//            self.inMemory = inMemory
//        }
//    }
// }
//
// public class Workspace {
//    public let bundleRepository: BundleRepository = .init()
//    public let metadata: WorkspaceMetadata = .init()
//    public let navigator: Navigator = .init()
//
//    let config: Configuration
//    private let fileManager: FileManager
//
//    private var project: Project
//    private(set) var search: SearchIndex
//
//    var projectIdentifier: String { project.identifier }
//    var displayName: String { project.displayName }
//
//    init(
//        project: Project,
//        config: Configuration = .init(),
//        fileManager: FileManager = .default
//    ) throws {
//        self.fileManager = fileManager
//        self.config = config
//        self.project = project
//
//        let search = try loadSearchIndex(
//            config: config,
//            projectId: project.identifier,
//            fileManager: fileManager
//        )
//        self.search = search
//    }
//
//    func save() async throws {
//        try await navigator.willSave(project)
//        guard project.isPersistent else { return }
//        try await project.persist()
//    }
//
//    func load(_ newProject: Project) async throws {
//        try await save()
//
//        await bundleRepository.unregisterAll()
//
//        for (bundleIdentifier, projectBundle) in project.references {
//            let dataProvider = ProjectSourceDataProvider(projectBundle.source)
//            let baseURL = URL(string: "http://localhost:8080/docsee/slothcreator")!
//
//            let bundle = DocumentationBundle(
//                info: .init(
//                    displayName: projectBundle.displayName,
//                    identifier: bundleIdentifier
//                ),
//                baseURL: baseURL,
//                indexURL: baseURL.appending(component: "index"),
//                themeSettingsUrl: nil
//            )
//
//            await bundleRepository.registerProvider(for: bundle, dataProvider: dataProvider)
//        }
//
//        let search = try loadSearchIndex(
//            config: config,
//            projectId: newProject.identifier,
//            fileManager: fileManager
//        )
//        self.search = search
//
//        withMutation(keyPath: \.project) {
//            self.project = newProject
//        }
//
//        try await self.navigator.load(project: project)
//    }
// }
