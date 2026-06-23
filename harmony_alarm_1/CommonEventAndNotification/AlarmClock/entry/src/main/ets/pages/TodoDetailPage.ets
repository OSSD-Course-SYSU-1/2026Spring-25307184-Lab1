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
import { ScreenUtil, BreakpointType } from '../common/utils/ScreenUtil';

@Entry
@Component
struct TodoDetailPage {
  private dataStore: TodoDataStore = TodoDataStore.getInstance();
  private todoId: number = 0;
  @State todoItem: TodoItem | undefined = undefined;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointType.SM;

  aboutToAppear(): void {
    let params: Record<string, number> = router.getParams() as Record<string, number>;
    if (params != null && params['todoId'] !== undefined) {
      this.todoId = params['todoId'];
      this.todoItem = this.dataStore.getTodoById(this.todoId);
    }
  }

  /**
   * Whether current device is a tablet.
   */
  private isTablet(): boolean {
    return this.currentBreakpoint === BreakpointType.MD || this.currentBreakpoint === BreakpointType.LG;
  }

  private formatTime(timestamp: number): string {
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
    return year + '-' + monthStr + '-' + dayStr + ' ' + hourStr + ':' + minuteStr;
  }

  private isDeadlineOverdue(): boolean {
    if (this.todoItem == null) {
      return false;
    }
    let dl: number = this.todoItem.deadline;
    if (dl === 0 || dl === undefined) {
      return false;
    }
    return dl < Date.now() && !this.todoItem.isCompleted;
  }

  build(): void {
    Column() {
      // Title bar
      Row() {
        Button() {
          Text($r('app.string.todo_back'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_back_font_size')))
            .fontColor($r('app.color.todo_primary'))
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text($r('app.string.todo_detail'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_title_font_size')))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.todo_text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(DimensionUtil.getVp($r('app.float.todo_detail_bar_height')))
      .padding({
        left: DimensionUtil.getVp($r('app.float.todo_detail_bar_padding')),
        right: DimensionUtil.getVp($r('app.float.todo_detail_bar_padding'))
      })

      if (this.todoItem != null) {
        Column() {
          // Title section
          Column() {
            Text(this.todoItem.title)
              .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_title_font_size')))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.todo_text_primary'))
              .width('100%')

            Row() {
              Text($r('app.string.todo_create_time_label'))
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_create_font_size')))
                .fontColor($r('app.color.todo_text_hint'))
              Text(this.formatTime(this.todoItem.createTime))
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_create_font_size')))
                .fontColor($r('app.color.todo_text_hint'))
            }
            .width('100%')
            .margin({ top: DimensionUtil.getVp($r('app.float.todo_detail_create_margin_top')) })
          }
          .width('100%')
          .padding(DimensionUtil.getVp($r('app.float.todo_detail_card_padding')))
          .alignItems(HorizontalAlign.Start)

          Divider()
            .strokeWidth(1)
            .color($r('app.color.todo_border'))

          // Content section
          Column() {
            Text($r('app.string.todo_content_label'))
              .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_label_font_size')))
              .fontColor($r('app.color.todo_text_secondary'))
              .width('100%')
              .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_detail_label_margin_bottom')) })

            if (this.todoItem.content.length > 0) {
              Text(this.todoItem.content)
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_value_font_size')))
                .fontColor($r('app.color.todo_text_primary'))
                .lineHeight(DimensionUtil.getVp($r('app.float.todo_detail_content_line_height')))
                .width('100%')
            } else {
              Text($r('app.string.todo_no_content'))
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_value_font_size')))
                .fontColor($r('app.color.todo_text_light'))
                .fontStyle(FontStyle.Italic)
                .width('100%')
            }
          }
          .width('100%')
          .padding(DimensionUtil.getVp($r('app.float.todo_detail_card_padding')))
          .alignItems(HorizontalAlign.Start)

          Divider()
            .strokeWidth(1)
            .color($r('app.color.todo_border'))

          // Deadline section
          Column() {
            Text($r('app.string.todo_deadline_label'))
              .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_label_font_size')))
              .fontColor($r('app.color.todo_text_secondary'))
              .width('100%')
              .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_detail_label_margin_bottom')) })

            if (this.todoItem.deadline === 0 || this.todoItem.deadline === undefined) {
              Text($r('app.string.todo_no_deadline'))
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_value_font_size')))
                .fontColor($r('app.color.todo_text_light'))
                .fontStyle(FontStyle.Italic)
                .width('100%')
            } else {
              Text(this.formatTime(this.todoItem.deadline))
                .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_value_font_size')))
                .fontColor(this.isDeadlineOverdue()
                  ? $r('app.color.todo_danger')
                  : $r('app.color.todo_text_primary'))
                .width('100%')
            }
          }
          .width('100%')
          .padding(DimensionUtil.getVp($r('app.float.todo_detail_card_padding')))
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .borderRadius(DimensionUtil.getVp($r('app.float.todo_detail_card_radius')))
        .backgroundColor($r('app.color.todo_surface'))
        .margin({
          top: DimensionUtil.getVp($r('app.float.todo_detail_card_margin')),
          left: DimensionUtil.getVp($r('app.float.todo_detail_card_margin')),
          right: DimensionUtil.getVp($r('app.float.todo_detail_card_margin'))
        })
      } else {
        Column() {
          Text($r('app.string.todo_not_found'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_detail_not_found_font_size')))
            .fontColor($r('app.color.todo_text_hint'))
            .margin({ top: DimensionUtil.getVp($r('app.float.todo_detail_not_found_margin_top')) })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.todo_background'))
    .constraintSize({ maxWidth: this.isTablet() ? 600 : undefined })
  }
}
