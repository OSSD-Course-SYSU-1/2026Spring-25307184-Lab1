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

@CustomDialog
export default struct DatePickDialog {
  controller: CustomDialogController;

  @State yearData: string[] = [];
  @State monthData: string[] = [];
  @State dayData: string[] = [];
  @State hourData: string[] = [];
  @State minuteData: string[] = [];

  @State selectedYearIndex: number = 0;
  @State selectedMonthIndex: number = 0;
  @State selectedDayIndex: number = 0;
  @State selectedHourIndex: number = 0;
  @State selectedMinuteIndex: number = 0;

  aboutToAppear(): void {
    let now = new Date();
    let currentYear = now.getFullYear();
    let currentMonth = now.getMonth(); // 0~11
    let currentDay = now.getDate();
    let currentHour = now.getHours();
    let currentMinute = now.getMinutes();

    // Year: current year +/- 5
    this.yearData = [];
    for (let i = currentYear - 5; i <= currentYear + 5; i++) {
      this.yearData.push(i.toString());
    }
    this.selectedYearIndex = 5;

    // Month: 01~12
    this.monthData = [];
    for (let i = 1; i <= 12; i++) {
      let m = i.toString();
      if (i < 10) {
        m = '0' + m;
      }
      this.monthData.push(m);
    }
    this.selectedMonthIndex = currentMonth;

    // Hour: 00~23
    this.hourData = [];
    for (let i = 0; i <= 23; i++) {
      let h = i.toString();
      if (i < 10) {
        h = '0' + h;
      }
      this.hourData.push(h);
    }
    this.selectedHourIndex = currentHour;

    // Minute: 00~59
    this.minuteData = [];
    for (let i = 0; i <= 59; i++) {
      let min = i.toString();
      if (i < 10) {
        min = '0' + min;
      }
      this.minuteData.push(min);
    }
    this.selectedMinuteIndex = currentMinute;

    // Day: dynamic based on current year/month
    this.dayData = this.generateDayData(currentYear, currentMonth + 1);
    this.selectedDayIndex = currentDay - 1;
  }

  private getDaysInMonth(year: number, month: number): number {
    if (month === 2) {
      let isLeap = (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
      if (isLeap) {
        return 29;
      }
      return 28;
    }
    if (month === 4 || month === 6 || month === 9 || month === 11) {
      return 30;
    }
    return 31;
  }

  private generateDayData(year: number, month: number): string[] {
    let days = this.getDaysInMonth(year, month);
    let result: string[] = [];
    for (let i = 1; i <= days; i++) {
      let d = i.toString();
      if (i < 10) {
        d = '0' + d;
      }
      result.push(d);
    }
    return result;
  }

  private getSelectedYear(): number {
    let yearStr: string = this.yearData[this.selectedYearIndex];
    return Number(yearStr);
  }

  private getSelectedMonth(): number {
    return this.selectedMonthIndex + 1;
  }

  private updateDayData(): void {
    let year = this.getSelectedYear();
    let month = this.getSelectedMonth();
    this.dayData = this.generateDayData(year, month);
    if (this.selectedDayIndex >= this.dayData.length) {
      this.selectedDayIndex = this.dayData.length - 1;
    }
  }

  build(): void {
    Column() {
      // Title
      Text('选择截止日期')
        .fontSize(20)
        .fontColor('#182431')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 12 })

      // Five TextPickers in a Row
      Row() {
        TextPicker({ range: this.yearData, selected: this.selectedYearIndex })
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .canLoop(false)
          .onChange((_value: string | string[], index: number | number[]) => {
            this.selectedYearIndex = index as number;
            this.updateDayData();
          })

        TextPicker({ range: this.monthData, selected: this.selectedMonthIndex })
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .canLoop(false)
          .onChange((_value: string | string[], index: number | number[]) => {
            this.selectedMonthIndex = index as number;
            this.updateDayData();
          })

        TextPicker({ range: this.dayData, selected: this.selectedDayIndex })
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .canLoop(false)
          .onChange((_value: string | string[], index: number | number[]) => {
            this.selectedDayIndex = index as number;
          })

        TextPicker({ range: this.hourData, selected: this.selectedHourIndex })
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .canLoop(false)
          .onChange((_value: string | string[], index: number | number[]) => {
            this.selectedHourIndex = index as number;
          })

        TextPicker({ range: this.minuteData, selected: this.selectedMinuteIndex })
          .layoutWeight(1)
          .backgroundColor('#F1F3F5')
          .canLoop(false)
          .onChange((_value: string | string[], index: number | number[]) => {
            this.selectedMinuteIndex = index as number;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Cancel / Confirm buttons
      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#17A98E')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#00000000')
          .onClick(() => {
            this.controller.close();
          })

        Button('确定')
          .fontSize(15)
          .fontColor('#17A98E')
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#00000000')
          .onClick(() => {
            let year = this.getSelectedYear();
            let month = this.getSelectedMonth();
            let day = Number(this.dayData[this.selectedDayIndex]);
            let hour = Number(this.hourData[this.selectedHourIndex]);
            let minute = Number(this.minuteData[this.selectedMinuteIndex]);
            let timestamp: number = new Date(year, month - 1, day, hour, minute).getTime();
            AppStorage.setOrCreate('deadlinePickerResult', timestamp);
            this.controller.close();
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(24)
  }
}
