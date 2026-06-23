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
import DimensionUtil from '../common/utils/DimensionUtil';
import { ScreenUtil, BreakpointType, LayoutType } from '../common/utils/ScreenUtil';

@Component
export struct TodoPage {
  private dataStore: TodoDataStore = TodoDataStore.getInstance();
  @State todoList: TodoItem[] = [];
  @StorageLink('todoRefreshTrigger') @Watch('onTodoRefresh') refreshTrigger: number = 0;
  @State sortByDeadline: boolean = false;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointType.SM;

  aboutToAppear(): void {
    this.loadTodoList();
  }

  /**
   * Whether current device is a tablet (MD or LG breakpoint).
   */
  private isTablet(): boolean {
    return this.currentBreakpoint === BreakpointType.MD || this.currentBreakpoint === BreakpointType.LG;
  }

  /**
   * Load todo list from shared data store.
   */
  private loadTodoList(): void {
    this.todoList = [...this.dataStore.todoList];
  }

  /**
   * Called when AppStorage refresh trigger changes.
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
    let date: Date = new Date(timestamp);
    let year: number = date.getFullYear();
    let monthNum: number = date.getMonth() + 1;
    let monthStr: string = monthNum.toString();
    if (monthStr.length < 2) {
      monthStr = '0' + monthStr;
    }
    let dayStr: string = date.getDate().toString();
    if (dayStr.length < 2) {
      dayStr = '0' + dayStr;
    }
    let hourStr: string = date.getHours().toString();
    if (hourStr.length < 2) {
      hourStr = '0' + hourStr;
    }
    let minuteStr: string = date.getMinutes().toString();
    if (minuteStr.length < 2) {
      minuteStr = '0' + minuteStr;
    }
    return '📅 ' + year + '-' + monthStr + '-' + dayStr + ' ' + hourStr + ':' + minuteStr;
  }

  /**
   * Check if a todo item is overdue.
   */
  private isOverdue(item: TodoItem): boolean {
    let dl: number = item.deadline;
    if (dl === 0 || dl === undefined) {
      return false;
    }
    return dl < Date.now() && !item.isCompleted;
  }

  /**
   * Return a sorted copy of the todo list.
   */
  private getSortedList(): TodoItem[] {
    if (!this.sortByDeadline) {
      return this.todoList;
    }
    let list: TodoItem[] = [...this.todoList];
    list.sort((a: TodoItem, b: TodoItem) => {
      let aDeadline: number = a.deadline;
      let bDeadline: number = b.deadline;
      if (aDeadline === undefined) {
        aDeadline = 0;
      }
      if (bDeadline === undefined) {
        bDeadline = 0;
      }
      if (aDeadline === 0 && bDeadline === 0) {
        return 0;
      }
      if (aDeadline === 0) {
        return 1;
      }
      if (bDeadline === 0) {
        return -1;
      }
      return aDeadline - bDeadline;
    });
    return list;
  }

  /**
   * Build a single todo list item.
   */
  @Builder TodoItemRow(item: TodoItem) {
    Row() {
      Checkbox({ name: 'todo_' + item.id, group: 'todoGroup' })
        .select(item.isCompleted)
        .selectedColor($r('app.color.todo_primary'))
        .width(DimensionUtil.getVp($r('app.float.todo_checkbox_size')))
        .height(DimensionUtil.getVp($r('app.float.todo_checkbox_size')))
        .onChange((value: boolean) => {
          this.dataStore.toggleTodo(item.id);
          this.loadTodoList();
        })

      Column() {
        Text(item.title)
          .fontSize(DimensionUtil.getFp($r('app.float.todo_item_title_font_size')))
          .fontColor(item.isCompleted ? $r('app.color.todo_text_hint') : $r('app.color.todo_text_primary'))
          .decoration({ type: item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(this.formatDeadline(item.deadline))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_item_deadline_font_size')))
          .fontColor(this.isOverdue(item) ? $r('app.color.todo_danger') : $r('app.color.todo_text_hint'))
          .margin({ top: DimensionUtil.getVp($r('app.float.todo_item_deadline_margin_top')) })
          .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: DimensionUtil.getVp($r('app.float.todo_item_margin_h')),
        right: DimensionUtil.getVp($r('app.float.todo_item_margin_h')) })
      .alignItems(HorizontalAlign.Start)

      Text('›')
        .fontSize(DimensionUtil.getFp($r('app.float.todo_arrow_font_size')))
        .fontColor($r('app.color.todo_text_light'))
        .margin({ right: DimensionUtil.getVp($r('app.float.todo_arrow_margin_right')) })

      Button($r('app.string.todo_delete_btn'))
        .fontSize(DimensionUtil.getFp($r('app.float.todo_delete_btn_font_size')))
        .height(DimensionUtil.getVp($r('app.float.todo_delete_btn_height')))
        .backgroundColor($r('app.color.todo_danger'))
        .borderRadius(DimensionUtil.getVp($r('app.float.todo_delete_btn_radius')))
        .onClick(() => {
          this.dataStore.deleteTodo(item.id);
          this.loadTodoList();
        })
        .fontColor($r('app.color.todo_surface'))
    }
    .width('100%')
    .constraintSize({ minHeight: DimensionUtil.getVp($r('app.float.todo_item_min_height')) })
    .padding({
      left: DimensionUtil.getVp($r('app.float.todo_item_padding_h')),
      right: DimensionUtil.getVp($r('app.float.todo_item_padding_h')),
      top: DimensionUtil.getVp($r('app.float.todo_item_padding_v')),
      bottom: DimensionUtil.getVp($r('app.float.todo_item_padding_v'))
    })
    .backgroundColor($r('app.color.todo_surface'))
    .borderRadius(DimensionUtil.getVp($r('app.float.todo_item_radius')))
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      router.pushUrl({ url: 'pages/TodoDetailPage', params: { todoId: item.id } });
    })
  }

  build(): void {
    Column() {
      // Title bar
      Row() {
        Text($r('app.string.todo_title'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_page_title_font_size')))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.todo_text_primary'))
          .textAlign(TextAlign.Start)

        Blank()

        Button() {
          Text(this.sortByDeadline ? $r('app.string.todo_sort_active') : $r('app.string.todo_sort_by_deadline'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_sort_btn_font_size')))
            .fontColor(this.sortByDeadline ? $r('app.color.todo_surface') : $r('app.color.todo_primary'))
        }
        .height(DimensionUtil.getVp($r('app.float.todo_sort_btn_height')))
        .backgroundColor(this.sortByDeadline ? $r('app.color.todo_primary') : $r('app.color.trans_parent'))
        .borderRadius(DimensionUtil.getVp($r('app.float.todo_sort_btn_radius')))
        .border({ width: DimensionUtil.getVp($r('app.float.todo_sort_btn_border')),
          color: $r('app.color.todo_primary') })
        .padding({
          left: DimensionUtil.getVp($r('app.float.todo_sort_btn_padding_h')),
          right: DimensionUtil.getVp($r('app.float.todo_sort_btn_padding_h'))
        })
        .onClick(() => {
          this.sortByDeadline = !this.sortByDeadline;
        })
      }
      .width('100%')
      .height(DimensionUtil.getVp($r('app.float.todo_page_bar_height')))
      .padding({
        left: DimensionUtil.getVp($r('app.float.todo_page_bar_padding')),
        right: DimensionUtil.getVp($r('app.float.todo_page_bar_padding'))
      })
      .alignItems(VerticalAlign.Center)

      // Content area
      if (this.todoList.length === 0) {
        Column() {
          Text($r('app.string.todo_empty'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_empty_font_size')))
            .fontColor($r('app.color.todo_text_hint'))
            .margin({ top: DimensionUtil.getVp($r('app.float.todo_empty_margin_top')) })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        if (this.isTablet()) {
          // Tablet: two-column grid layout
          Grid() {
            ForEach(this.getSortedList(), (item: TodoItem) => {
              GridItem() {
                this.TodoItemRow(item)
              }
            }, (item: TodoItem) => item.id.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(DimensionUtil.getVp($r('app.float.todo_list_space')))
          .rowsGap(DimensionUtil.getVp($r('app.float.todo_list_space')))
          .padding({
            left: DimensionUtil.getVp($r('app.float.todo_list_padding_h')),
            right: DimensionUtil.getVp($r('app.float.todo_list_padding_h')),
            top: DimensionUtil.getVp($r('app.float.todo_list_padding_top'))
          })
          .layoutWeight(1)
          .constraintSize({ maxWidth: 680 })
          .alignSelf(ItemAlign.Center)
        } else {
          // Phone: single-column list
          List({ space: DimensionUtil.getVp($r('app.float.todo_list_space')) }) {
            ForEach(this.getSortedList(), (item: TodoItem) => {
              ListItem() {
                this.TodoItemRow(item)
              }
            }, (item: TodoItem) => item.id.toString())
          }
          .padding({
            left: DimensionUtil.getVp($r('app.float.todo_list_padding_h')),
            right: DimensionUtil.getVp($r('app.float.todo_list_padding_h')),
            top: DimensionUtil.getVp($r('app.float.todo_list_padding_top'))
          })
          .layoutWeight(1)
          .listDirection(Axis.Vertical)
        }
      }

      // Bottom add button
      Button() {
        Row() {
          Text('+')
            .fontSize(DimensionUtil.getFp($r('app.float.todo_add_btn_icon_size')))
            .fontColor($r('app.color.todo_surface'))
            .margin({ right: DimensionUtil.getVp($r('app.float.todo_arrow_margin_right')) })
          Text($r('app.string.todo_new'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_add_btn_text_size')))
            .fontColor($r('app.color.todo_surface'))
        }
      }
      .width('100%')
      .height(DimensionUtil.getVp($r('app.float.todo_add_btn_height')))
      .backgroundColor($r('app.color.todo_primary'))
      .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_btn_radius')))
      .margin({
        left: DimensionUtil.getVp($r('app.float.todo_add_btn_margin_h')),
        right: DimensionUtil.getVp($r('app.float.todo_add_btn_margin_h')),
        bottom: DimensionUtil.getVp($r('app.float.todo_add_btn_margin_bottom')),
        top: DimensionUtil.getVp($r('app.float.todo_add_btn_margin_top'))
      })
      .onClick(() => {
        router.pushUrl({ url: 'pages/TodoAddPage' });
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.todo_background'))
  }
}
