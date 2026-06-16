/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import router from '@ohos.router';
import { TodoDataStore, TodoItem } from '../common/utils/TodoDataStore';

@Component
export struct TodoPage {
  private dataStore: TodoDataStore = TodoDataStore.getInstance();
  @State todoList: TodoItem[] = [];
  @StorageLink('todoRefreshTrigger') @Watch('onTodoRefresh') refreshTrigger: number = 0;
  @State sortByDeadline: boolean = false;

  aboutToAppear(): void {
    this.loadTodoList();
  }

  /**
   * Load todo list from shared data store.
   */
  private loadTodoList(): void {
    this.todoList = [...this.dataStore.todoList];
  }

  /**
   * Called when AppStorage refresh trigger changes (after adding from TodoAddPage).
   */
  onTodoRefresh(): void {
    if (this.refreshTrigger > 0) {
      this.loadTodoList();
    }
  }

  /**
   * Format deadline timestamp to display string with icon.
   */
  private formatDeadline(timestamp: number): string {
    if (timestamp === 0 || timestamp === undefined) {
      return '📅 无截止日期';
    }
    let date = new Date(timestamp);
    let year = date.getFullYear();
    let month = (date.getMonth() + 1).toString();
    if (month.length < 2) {
      month = '0' + month;
    }
    let day = date.getDate().toString();
    if (day.length < 2) {
      day = '0' + day;
    }
    let hour = date.getHours().toString();
    if (hour.length < 2) {
      hour = '0' + hour;
    }
    let minute = date.getMinutes().toString();
    if (minute.length < 2) {
      minute = '0' + minute;
    }
    return '📅 ' + year + '-' + month + '-' + day + ' ' + hour + ':' + minute;
  }

  /**
   * Check if a todo item is overdue (deadline passed and not completed).
   */
  private isOverdue(item: TodoItem): boolean {
    let dl = item.deadline;
    if (dl === 0 || dl === undefined) {
      return false;
    }
    return dl < Date.now() && !item.isCompleted;
  }

  /**
   * Return a sorted copy of the todo list.
   * When sortByDeadline is active, items with a deadline come first (earliest first),
   * items without a deadline go to the bottom.
   */
  private getSortedList(): TodoItem[] {
    if (!this.sortByDeadline) {
      return this.todoList;
    }
    let list: TodoItem[] = [...this.todoList];
    list.sort((a: TodoItem, b: TodoItem) => {
      let aDeadline = a.deadline;
      let bDeadline = b.deadline;
      if (aDeadline === undefined) {
        aDeadline = 0;
      }
      if (bDeadline === undefined) {
        bDeadline = 0;
      }
      // Items without deadline go to the bottom
      if (aDeadline === 0 && bDeadline === 0) {
        return 0;
      }
      if (aDeadline === 0) {
        return 1;
      }
      if (bDeadline === 0) {
        return -1;
      }
      // Both have deadlines: sort ascending (earliest first)
      return aDeadline - bDeadline;
    });
    return list;
  }

  build(): void {
    Column() {
      // Title bar
      Row() {
        Text('待办事项')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .textAlign(TextAlign.Start)

        Blank()

        Button() {
          Text(this.sortByDeadline ? '✓ 截止日期' : '按截止日期')
            .fontSize(13)
            .fontColor(this.sortByDeadline ? '#FFFFFF' : '#007DFF')
        }
        .height(32)
        .backgroundColor(this.sortByDeadline ? '#007DFF' : '#00000000')
        .borderRadius(16)
        .border({ width: 1, color: '#007DFF' })
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.sortByDeadline = !this.sortByDeadline;
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 24, right: 24 })
      .alignItems(VerticalAlign.Center)

      // Todo list
      if (this.todoList.length === 0) {
        Column() {
          Text('暂无待办事项')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 60 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List({ space: 8 }) {
          ForEach(this.getSortedList(), (item: TodoItem) => {
            ListItem() {
              Row() {
                // Completion checkbox
                Checkbox({ name: 'todo_' + item.id, group: 'todoGroup' })
                  .select(item.isCompleted)
                  .selectedColor('#007DFF')
                  .width(24)
                  .height(24)
                  .onChange((value: boolean) => {
                    this.dataStore.toggleTodo(item.id);
                    this.loadTodoList();
                  })

                // Title and deadline
                Column() {
                  Text(item.title)
                    .fontSize(15)
                    .fontColor(item.isCompleted ? '#999999' : '#182431')
                    .decoration({ type: item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(this.formatDeadline(item.deadline))
                    .fontSize(13)
                    .fontColor(this.isOverdue(item) ? '#FA2A2D' : '#999999')
                    .margin({ top: 4 })
                    .width('100%')
                }
                .layoutWeight(1)
                .margin({ left: 12, right: 12 })
                .alignItems(HorizontalAlign.Start)

                // Right arrow indicator
                Text('›')
                  .fontSize(20)
                  .fontColor('#CCCCCC')
                  .margin({ right: 4 })

                // Delete button
                Button('删除')
                  .fontSize(12)
                  .height(30)
                  .backgroundColor('#FA2A2D')
                  .borderRadius(8)
                  .onClick(() => {
                    this.dataStore.deleteTodo(item.id);
                    this.loadTodoList();
                  })
              }
              .width('100%')
              .constraintSize({ minHeight: 56 })
              .padding({ left: 12, right: 12, top: 10, bottom: 10 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .alignItems(VerticalAlign.Center)
            }
            .onClick(() => {
              router.pushUrl({ url: 'pages/TodoDetailPage', params: { todoId: item.id } });
            })
          }, (item: TodoItem) => item.id.toString())
        }
        .padding({ left: 12, right: 12, top: 8 })
        .layoutWeight(1)
        .listDirection(Axis.Vertical)
      }

      // Bottom add button
      Button() {
        Row() {
          Text('+')
            .fontSize(24)
            .fontColor('#FFFFFF')
            .margin({ right: 4 })
          Text('新建待办')
            .fontSize(16)
            .fontColor('#FFFFFF')
        }
      }
      .width('100%')
      .height(48)
      .backgroundColor('#007DFF')
      .borderRadius(12)
      .margin({ left: 24, right: 24, bottom: 16, top: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/TodoAddPage' });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}
