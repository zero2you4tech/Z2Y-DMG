//
//  ContentView.swift
//  Z2Y-DMG
//
//  Created by Oyjie on 2/22/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var obj = DmgInfoObj()

    @State var hoveringAppTab: Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    SystemUtil.appIcon(size: 50)
                    Spacer()
                }
                .padding(10)
                HStack {
                    Spacer()
                    if obj.appPath.isEmpty {
                        Text(SystemUtil.localizedString("AddAppFileByDropOrClick"))
                    } else {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: obj.appPath))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                        Text("App Path: \(obj.appPath)")
                    }
                    Spacer()
                }
                .frame(height: 80).padding(10)
                .background(
                    OverlayStrokeBorder(
                        cornerRadius: 5, bgColor: self.hoveringAppTab ? .orange.opacity(0.3) : obj.statusColor.opacity(0.3)
                    )
                )
                .onHover { hovering in
                    self.hoveringAppTab = hovering
                }
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                    obj.handleAppDrop(providers: providers)
                }
                .onTapGesture {
                    obj.handleAppTap()
                }.disabled(obj.status == .Running)
                
                VStack {
                    HStack {
                        Spacer()
                        Text(SystemUtil.localizedString("PleaseChooseOtherFile"))
                        Spacer()
                    }.padding(5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(obj.otherPaths), id: \.self) { otherPath in
                                VStack {
                                    Image(nsImage: NSWorkspace.shared.icon(forFile: otherPath))
                                        .resizable().scaledToFit().frame(width: 60, height: 60)
                                    Text(URL(fileURLWithPath: otherPath).lastPathComponent).font(.system(size: 8)).lineLimit(1)
                                }
                                .frame(width: 80, height: 80).overlay {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            FlatButton(action: {
                                                obj.removeOtherPath(otherPath)
                                            }) {
                                                Image(systemName: "xmark")
                                            }
                                            .color(bgColor: .clear, fgColor: .gray)
                                            .hoverColor(bgColor: .clear, fgColor: .red)
                                            .borderColor(.clear).hoverBorderColor(.clear)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            FlatButton {
                                obj.handleOtherTap()
                            } label: {
                                Image(systemName: "doc.badge.plus").resizable().scaledToFit().frame(width: 50, height: 50)
                            }
                            .paddingWidth(10)
                            Spacer()
                        }
                    }
                    .frame(width: geometry.size.width - 40, height: 90).padding(5)
                }
                .background(OverlayStrokeBorder(cornerRadius: 5, bgColor: obj.statusColor.opacity(0.3)))
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                    obj.handleOtherDrops(providers: providers)
                }.disabled(obj.status == .Running)
                
                
                VStack(alignment: .leading) {
                    ScrollView(.vertical) {
                        if obj.status == .Running {
                            ContentRepeatAnimation()
                        }
                        ForEach(Array(obj.tips.enumerated()), id: \.element) { index, tip in
                            HStack(alignment: .top) {
                                let fontColor: Color = tip.starts(with: "Success") ? .green : tip.starts(with: "Fail") ? .red : .gray
                                // 检查是否是最后一个元素
                                if index == obj.tips.count - 1 {
                                    if fontColor == .green {
                                        Image(systemName: "checkmark.circle").foregroundColor(.green)
                                    } else {
                                        RotationAnimation {
                                            Image(systemName: "circle.dashed").foregroundColor(.orange)
                                        }
                                    }
                                } else {
                                    if fontColor == .red {
                                        Image(systemName: "xmark.circle").foregroundColor(.red)
                                    } else {
                                        Image(systemName: "checkmark.circle").foregroundColor(.green)
                                    }
                                }
                                Text(tip).foregroundColor(fontColor)
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geometry.size.width - 20, height: 90).padding(5)
                    .background(OverlayStrokeBorder(cornerRadius: 5, bgColor: .yellow.opacity(0.1)))
                }
                HStack {
                    Spacer()
                    if obj.status == .Running {
                        RotationAnimation {
                            Image(systemName: "circle.dashed").foregroundColor(.orange)
                        }
                    } else if obj.status == .Success {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    } else if obj.status == .Fail {
                        Image(systemName: "xmark.circle").foregroundColor(.red)
                    }
                    
                    Button("\(SystemUtil.localizedString("Create")) \(obj.appName).dmg") {
                        obj.handleCreateDMG()
                    }.disabled(obj.status == .Running)
                }
                Spacer()
            }
            .padding(5)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    
}
