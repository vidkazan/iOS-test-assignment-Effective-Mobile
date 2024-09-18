//
//  TodoListView.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 14.09.24.
//

import Foundation
import SwiftUI
import OSLog

struct TodoListMainView : TodoListView {
    @ObservedObject var vm : TodoListMainViewModel = .init(coreDataStore: .init())
    @State var filterState : FilterState = .All
    @State var items : [TodoItemViewData] = []
    @State var itemForDetails : TodoItemDetailView.Mode?
    var body: some View {
        VStack {
            header()
            filter()
            list()
                .disabled(vm.state.status.listIsDisabled)
        }
        .alert("Error", isPresented: .init(get: {
            if case .error = vm.state.status {
                return true
            }
            return false
        }, set: { _ in
        }), actions: {
            Button(action: {
                vm.send(event: .didrequestStopLoading)
            }, label: {
                Label("Close", systemImage: "xmark.icloud.fill")
            })
        }, message: {
            if case .error(let error) = vm.state.status {
                Text(verbatim: error.localizedDescription)
            }
            Text("Unknown error", comment: "TodoListMainView: error alert")
        })
        .sheet(
            item: $itemForDetails,
            onDismiss: {
                #warning("SUI bug for < 17.2.1: 1 second delay after closing Sheet and calling this function ")
                self.log.debug("sheet dismiss with 'onDismiss'")
                itemForDetails = nil
            },
            content: { mode in
                TodoItemDetailView(vm: vm, mode: mode, closeAction: {
                    self.log.debug("sheet dismiss with 'Close'")
                    itemForDetails = nil
                })
            }
        )
        .padding()
        .onChange(of:filterState, perform: {
            items = $0.todoItems(items: vm.state.todoItems)
        })
        .onReceive(vm.$state, perform: {
            items = filterState.todoItems(items: $0.todoItems)
        })
    }
}


extension TodoListMainView {
    enum FilterState : String, CaseIterable {
        case All
        case Open
        case Closed
        
        func todoItemsCount(items : [TodoItemViewData]) -> Int {
            switch self {
                case .All:
                    items.count
                case .Open:
                    items.filter({$0.isCompleted == false}).count
                case .Closed:
                    items.filter({$0.isCompleted == true}).count
            }
        }
        func todoItems(items : [TodoItemViewData]) -> [TodoItemViewData] {
            switch self {
                case .All:
                    items
                case .Open:
                    items.filter({$0.isCompleted == false})
                case .Closed:
                    items.filter({$0.isCompleted == true})
            }
        }
    }
}

private extension TodoListMainView {
    func list() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(items.sorted(by: {
                    $0.creationDate < $1.creationDate
                }),id:\.id) { item in
                    Button(action: {
                        itemForDetails = .edit(item: item)
                    }, label: {
                        TodoItemCellView(vm: vm, item: item)
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(10)
                            .contextMenu(menuItems: {
                                Button(action: {
                                    vm.send(event: .didRequestEditTodoItem(action: .deleting(id: item.id)))
                                }, label: {
                                    Label("Delete", systemImage: "xmark.bin.circle.fill")
                                })
                            })
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

private extension TodoListMainView {
    func header() -> some View {
        HStack {
            VStack(alignment: .leading){
                Text("Today's Task",comment: "TodoListMainView: Header")
                    .font(.system(size: 22,weight: .bold))
                Text(.now, style: .date)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            Spacer()
            switch vm.state.status {
                case .loadingFromAPI,.loadingFromDB,.editing,.validatingIfLoadedFromAPI:
                    ProgressView()
                        .font(.system(size: 15,weight: .medium))
                        .padding(.horizontal,10)
                        .padding(10)
                        .foregroundStyle(.blue)
                        .background(.blue.opacity(0.15),
                           in: RoundedRectangle(cornerRadius: 10))
                        .onTapGesture {
                            vm.send(event: .didCancelledLoadingFromAPI)
                        }
                default:
                    Button(action: {
                        itemForDetails = .create
                    }, label: {
                        Label("New Task", systemImage: "plus")
                            .font(.system(size: 15,weight: .medium))
                            .padding(.horizontal,10)
                            .padding(10)
                            .foregroundStyle(.blue)
                            .background(.blue.opacity(0.15),
                               in: RoundedRectangle(cornerRadius: 10))
                    })
                    
            }
        }
    }
}

private extension TodoListMainView {
    func filter() -> some View {
        HStack(spacing: 15) {
            ForEach(Self.FilterState.allCases, id: \.rawValue) { filterCase in
                Button(action: {
                    self.filterState = filterCase
                }, label: {
                    HStack(spacing: 5) {
                        Text(filterCase.rawValue)
                            .font(.system(size: 15,weight: self.filterState == filterCase ? .semibold : .medium))
                            .foregroundStyle(self.filterState == filterCase ? .blue : .secondary)
                        Text(verbatim: "\(filterCase.todoItemsCount(items: vm.state.todoItems))")
                            .padding(.horizontal,2)
                            .padding(1)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .background(self.filterState == filterCase ? .blue : .secondary)
                            .cornerRadius(10)
                    }
                    if filterCase == .All {
                        Divider()
                            .frame(height: 30)
                    }
                })
                .frame(minWidth: 70,minHeight: 43)
            }
            Spacer()
        }
    }
}

private extension TodoListMainViewModel.Status {
    var listIsDisabled : Bool {
        switch self {
            case .start,.loadingFromAPI,.loadingFromDB,.error,.validatingIfLoadedFromAPI:
                true
            default:
                false
        }
    }
}

#Preview {
    TodoListMainView(vm: .init(coreDataStore: .preview))
}
