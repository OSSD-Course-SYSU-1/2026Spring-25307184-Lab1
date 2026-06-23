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
import { TodoDataStore } from '../common/utils/TodoDataStore';
import DatePickDialog from '../view/Detail/dialog/DatePickDialog';
import DimensionUtil from '../common/utils/DimensionUtil';
import { ScreenUtil, BreakpointType } from '../common/utils/ScreenUtil';

@Entry
@Component
struct TodoAddPage {
  private dataStore: TodoDataStore = TodoDataStore.getInstance();
  @State inputTitle: string = '';
  @State inputContent: string = '';
  @State hasDeadline: boolean = false;
  @State deadlineTimestamp: number = 0;
  @State deadlineLabel: string = '';
  @StorageLink('todoRefreshTrigger') refreshTrigger: number = 0;
  @StorageLink('deadlinePickerResult') @Watch('onDeadlinePicked') deadlinePickerResult: number = 0;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointType.SM;

  datePickDialogController: CustomDialogController = new CustomDialogController({
    builder: DatePickDialog(),
    autoCancel: true
  });

  /**
   * Whether current device is a tablet.
   */
  private isTablet(): boolean {
    return this.currentBreakpoint === BreakpointType.MD || this.currentBreakpoint === BreakpointType.LG;
  }

  onDeadlinePicked(): void {
    if (this.deadlinePickerResult > 0) {
      this.deadlineTimestamp = this.deadlinePickerResult;
      this.deadlineLabel = this.formatDeadlineLabel(this.deadlinePickerResult);
    }
  }

  private goBack(): void {
    router.back();
  }

  private saveTodo(): void {
    if (this.inputTitle.trim().length > 0) {
      this.dataStore.addTodo(this.inputTitle.trim(), this.inputContent.trim(), this.deadlineTimestamp);
      AppStorage.set('todoRefreshTrigger', Date.now());
      router.back();
    }
  }

  private formatDeadlineLabel(timestamp: number): string {
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

  build(): void {
    Column() {
      // Title bar
      Row() {
        Button() {
          Text($r('app.string.todo_back'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_add_back_font_size')))
            .fontColor($r('app.color.todo_primary'))
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.goBack();
        })

        Text($r('app.string.todo_new'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_title_font_size')))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.todo_text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(DimensionUtil.getVp($r('app.float.todo_add_title_bar_height')))
      .padding({
        left: DimensionUtil.getVp($r('app.float.todo_add_title_bar_padding')),
        right: DimensionUtil.getVp($r('app.float.todo_add_title_bar_padding'))
      })

      // Form content (centered with max-width on tablet)
      Column() {
        // Title input
        Text($r('app.string.todo_title_label'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_label_font_size')))
          .fontColor($r('app.color.todo_text_secondary'))
          .width('100%')
          .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_add_label_margin_bottom')) })

        TextInput({ text: this.inputTitle, placeholder: $r('app.string.todo_title_placeholder') })
          .width('100%')
          .height(DimensionUtil.getVp($r('app.float.todo_add_input_height')))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_input_font_size')))
          .backgroundColor($r('app.color.todo_surface'))
          .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_input_radius')))
          .padding({
            left: DimensionUtil.getVp($r('app.float.todo_add_input_padding_h')),
            right: DimensionUtil.getVp($r('app.float.todo_add_input_padding_h'))
          })
          .border({ width: 1, color: $r('app.color.todo_border') })
          .onChange((value: string) => {
            this.inputTitle = value;
          })

        Divider()
          .strokeWidth(1)
          .color($r('app.color.todo_border'))
          .margin({
            top: DimensionUtil.getVp($r('app.float.todo_add_divider_margin')),
            bottom: DimensionUtil.getVp($r('app.float.todo_add_divider_margin'))
          })

        // Content input
        Text($r('app.string.todo_content_label'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_label_font_size')))
          .fontColor($r('app.color.todo_text_secondary'))
          .width('100%')
          .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_add_label_margin_bottom')) })

        TextArea({ text: this.inputContent, placeholder: $r('app.string.todo_content_placeholder') })
          .width('100%')
          .height(DimensionUtil.getVp($r('app.float.todo_add_textarea_height')))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_textarea_font_size')))
          .backgroundColor($r('app.color.todo_surface'))
          .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_input_radius')))
          .padding({
            left: DimensionUtil.getVp($r('app.float.todo_add_textarea_padding_h')),
            right: DimensionUtil.getVp($r('app.float.todo_add_textarea_padding_h')),
            top: DimensionUtil.getVp($r('app.float.todo_add_textarea_padding_v')),
            bottom: DimensionUtil.getVp($r('app.float.todo_add_textarea_padding_v'))
          })
          .border({ width: 1, color: $r('app.color.todo_border') })
          .onChange((value: string) => {
            this.inputContent = value;
          })
      }
      .width('100%')
      .padding(DimensionUtil.getVp($r('app.float.todo_add_section_padding')))

      // Deadline section
      Divider()
        .strokeWidth(1)
        .color($r('app.color.todo_border'))
        .margin({
          top: DimensionUtil.getVp($r('app.float.todo_add_divider_margin_small_t')),
          bottom: DimensionUtil.getVp($r('app.float.todo_add_divider_margin_small_b'))
        })

      Text($r('app.string.todo_deadline_label'))
        .fontSize(DimensionUtil.getFp($r('app.float.todo_add_label_font_size')))
        .fontColor($r('app.color.todo_text_secondary'))
        .width('100%')
        .padding({
          left: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
          right: DimensionUtil.getVp($r('app.float.todo_add_section_padding'))
        })
        .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_add_deadline_section_margin_b')) })

      Row() {
        Radio({ value: 'none', group: 'deadlineGroup' })
          .checked(!this.hasDeadline)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.hasDeadline = false;
              this.deadlineTimestamp = 0;
              this.deadlineLabel = '';
            }
          })
        Text($r('app.string.todo_radio_none'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_radio_font_size')))
          .fontColor($r('app.color.todo_text_primary'))
          .margin({
            left: DimensionUtil.getVp($r('app.float.todo_add_radio_margin_left')),
            right: DimensionUtil.getVp($r('app.float.todo_add_radio_margin_right'))
          })

        Radio({ value: 'set', group: 'deadlineGroup' })
          .checked(this.hasDeadline)
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              this.hasDeadline = true;
            }
          })
        Text($r('app.string.todo_radio_set'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_radio_font_size')))
          .fontColor($r('app.color.todo_text_primary'))
          .margin({ left: DimensionUtil.getVp($r('app.float.todo_add_radio_margin_left')) })
      }
      .width('100%')
      .padding({
        left: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
        right: DimensionUtil.getVp($r('app.float.todo_add_section_padding'))
      })
      .margin({ bottom: DimensionUtil.getVp($r('app.float.todo_add_date_btn_margin_b')) })

      if (this.hasDeadline) {
        Button() {
          Text(this.deadlineLabel.length > 0 ? this.deadlineLabel : $r('app.string.todo_select_date'))
            .fontSize(DimensionUtil.getFp($r('app.float.todo_add_date_btn_font_size')))
            .fontColor($r('app.color.todo_surface'))
        }
        .width('100%')
        .height(DimensionUtil.getVp($r('app.float.todo_add_date_btn_height')))
        .backgroundColor($r('app.color.todo_primary'))
        .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_date_btn_radius')))
        .margin({
          left: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
          right: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
          bottom: DimensionUtil.getVp($r('app.float.todo_add_date_btn_margin_b'))
        })
        .onClick(() => {
          this.datePickDialogController.open();
        })
      }

      Blank()

      // Bottom buttons
      Row() {
        Button($r('app.string.todo_cancel_btn'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_bottom_btn_font_size')))
          .fontColor($r('app.color.todo_text_secondary'))
          .layoutWeight(1)
          .height(DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_height')))
          .backgroundColor($r('app.color.todo_background'))
          .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_radius')))
          .margin({ right: DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_margin')) })
          .onClick(() => {
            this.goBack();
          })

        Button($r('app.string.todo_save'))
          .fontSize(DimensionUtil.getFp($r('app.float.todo_add_bottom_btn_font_size')))
          .fontColor($r('app.color.todo_surface'))
          .layoutWeight(2)
          .height(DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_height')))
          .backgroundColor(this.inputTitle.trim().length > 0
            ? $r('app.color.todo_primary')
            : $r('app.color.todo_button_disabled'))
          .borderRadius(DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_radius')))
          .margin({ left: DimensionUtil.getVp($r('app.float.todo_add_bottom_btn_margin')) })
          .enabled(this.inputTitle.trim().length > 0)
          .onClick(() => {
            this.saveTodo();
          })
      }
      .width('100%')
      .padding({
        left: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
        right: DimensionUtil.getVp($r('app.float.todo_add_section_padding')),
        bottom: DimensionUtil.getVp($r('app.float.todo_add_bottom_padding_b'))
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.todo_background'))
    .constraintSize({ maxWidth: this.isTablet() ? 600 : undefined })
  }
}
