//
//  QueueUtil.swift
//  Z2Y
//
//  Created by Oyjie on 2023/11/26.
//

import Foundation

public class QueueUtil {
    // 本类所有修改都在这个线程里面处理
    public static let queue = DispatchQueue(label: "Z2Y@QueueUtilQueue")
    
    // 类对应的队列映射表
    public static var classOfQueueMap: [String: DispatchQueue] = [:]
    // 通过类识别并创建队列
    public static func getQueueByClass(_ classType: AnyClass) -> DispatchQueue {
        return queue.sync {
            let className = String(describing: classType)
            if let queue = QueueUtil.classOfQueueMap[className] {
                return queue;
            }
            let queue = DispatchQueue(label: "Z2Y@\(className)Queue")
            QueueUtil.classOfQueueMap[className] = queue
            return queue
        }
    }
    // 通过类识别并创建队列
    public static func getQueueByObj<Obj>(_ obj: Obj) -> DispatchQueue {
        return getQueueByClass(type(of: obj) as! AnyClass)
    }
    
    // 同步执行队列
    public static func syncInClass(_ classType: AnyClass, action: @escaping () -> Void) {
        QueueUtil.getQueueByClass(classType).sync {
            action()
        }
    }
    // 同步执行队列
    public static func syncInClass<T>(_ classType: AnyClass, action: @escaping () -> T) -> T {
        QueueUtil.getQueueByClass(classType).sync {
            return action()
        }
    }
    
    
    // 所有的编辑器的 OperationQueue
    public static var editorQueueSet: Set<OperationQueue> = []
    // 添加编辑器的 OperationQueue
    public static func addEditorQueue(editQueue: OperationQueue) {
        queue.sync {
            _ = QueueUtil.editorQueueSet.insert(editQueue)
        }
    }
    // 移除编辑器的 OperationQueue
    public static func removeEditorQueue(editQueue: OperationQueue) {
        queue.sync {
            _ = QueueUtil.editorQueueSet.remove(editQueue)
        }
    }
    // 停止所有的 OperationQueue
    public static func stopAllEditorQueue() {
        queue.sync {
            for editQueue in editorQueueSet {
                // 在其他事件开始时，暂停编辑事件
                editQueue.isSuspended = true
            }
        }
    }
    // 恢复所有的 OperationQueue
    public static func recoverAllEditorQueue() {
        queue.sync {
            for editQueue in editorQueueSet {
                // 在其他事件开始时，暂停编辑事件
                editQueue.isSuspended = false
            }
        }
    }
    
    // 编辑事件异步执行（可阻断）
    public static var defaultPriorityThanEditor = false
    public static func asyncForEdit(action: @escaping () -> Void) -> BlockOperation {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = BlockOperation {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            // 执行任务
            action()
            QueueUtil.removeEditorQueue(editQueue: queue)
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
        QueueUtil.addEditorQueue(editQueue: queue)
        queue.addOperation(operation)
        return operation;
    }
    // 主进程的编辑事件异步执行（可阻断）
    public static func mainAsyncForEdit(action: @escaping () -> Void) -> BlockOperation {
        let queue = OperationQueue.main
        let operation = BlockOperation {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            // 执行任务
            action()
            QueueUtil.removeEditorQueue(editQueue: queue)
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
        QueueUtil.addEditorQueue(editQueue: queue)
        queue.addOperation(operation)
        return operation;
    }
    // 主进程的函数异步执行
    public static func mainAsync(priorityThanEditor: Bool = QueueUtil.defaultPriorityThanEditor,
                          action: @escaping () -> Void) {
        DispatchQueue.main.async {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            if priorityThanEditor {
                QueueUtil.stopAllEditorQueue()
            }
            action()
            if priorityThanEditor {
                QueueUtil.recoverAllEditorQueue()
            }
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
    }
    
    // 同步或异步执行
    public static func mainAsyncOrNot(async: Bool, priorityThanEditor: Bool = QueueUtil.defaultPriorityThanEditor,
                       action: @escaping () -> Void) {
        if async {
            QueueUtil.mainAsync(priorityThanEditor: priorityThanEditor, action: action)
        } else {
            if priorityThanEditor {
                QueueUtil.stopAllEditorQueue()
            }
            action()
            if priorityThanEditor {
                QueueUtil.recoverAllEditorQueue()
            }
        }
    }
    
    // 主函数延迟异步执行
    public static func mainAsyncAfter(priorityThanEditor: Bool = QueueUtil.defaultPriorityThanEditor,
                               deadline: DispatchTime,
                               action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            if priorityThanEditor {
                QueueUtil.stopAllEditorQueue()
            }
            action()
            if priorityThanEditor {
                QueueUtil.recoverAllEditorQueue()
            }
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
    }
    // 后台异步运行
    public static func backendAsync(priorityThanEditor: Bool = QueueUtil.defaultPriorityThanEditor,
                             action: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            if priorityThanEditor {
                QueueUtil.stopAllEditorQueue()
            }
            action()
            if priorityThanEditor {
                QueueUtil.recoverAllEditorQueue()
            }
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
    }
    // 后台异步运行（延迟）
    public static func backendAsyncAfter(priorityThanEditor: Bool = false,
                                  deadline: DispatchTime,
                                  action: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
            let flag = UUID().uuidString
            QueueCntObj.addQueueUniqueFlag(flag)
            if priorityThanEditor {
                QueueUtil.stopAllEditorQueue()
            }
            action()
            if priorityThanEditor {
                QueueUtil.recoverAllEditorQueue()
            }
            QueueCntObj.removeQueueUniqueFlag(flag)
        }
    }
}

// 队列计数
public class QueueCntObj: ObservableObject {
    // Queue count
    @Published public var queueCnt: Int = 0
    // Memory
    @Published public var memoryMBSize: Double? = nil
    
    // 单例模式
    public static var shared: QueueCntObj = QueueCntObj()
    private init() {
        // Private initializer to restrict object creation
    }
    
    // 所有的进程
    public static var allQueueIdUniqueFlags: Set<String> = []
    public static func getAllQueueCount() -> Int {
        return QueueUtil.syncInClass(QueueCntObj.self) {
            return QueueCntObj.allQueueIdUniqueFlags.count
        }
    }
    public static func addQueueUniqueFlag(_ flag: String) {
        QueueUtil.syncInClass(QueueCntObj.self) {
            QueueCntObj.allQueueIdUniqueFlags.insert(flag)
            DispatchQueue.main.async {
                QueueCntObj.shared.queueCnt = QueueCntObj.getAllQueueCount()
                QueueCntObj.shared.memoryMBSize = SystemUtil.reportMemory()
            }
        }
    }
    public static func removeQueueUniqueFlag(_ flag: String) {
        QueueUtil.syncInClass(QueueCntObj.self) {
            QueueCntObj.allQueueIdUniqueFlags.remove(flag)
            DispatchQueue.main.async {
                QueueCntObj.shared.queueCnt = QueueCntObj.getAllQueueCount()
                QueueCntObj.shared.memoryMBSize = SystemUtil.reportMemory()
            }
        }
    }
}
