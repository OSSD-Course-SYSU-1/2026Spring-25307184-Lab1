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

import { AlarmPage } from './AlarmPage';
import { TodoPage } from './TodoPage';
import DimensionUtil from '../common/utils/DimensionUtil';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  /**
   * Custom tab bar builder.
   * Uses text icon characters to avoid resource loading issues.
   */
  @Builder TabBuilder(title: string, targetIndex: number, iconText: string) {
    Column() {
      Text(iconText)
        .fontSize(DimensionUtil.getFp($r('app.float.tab_icon_font_size')))
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.todo_primary') : $r('app.color.todo_text_hint'))

      Text(title)
        .fontSize(DimensionUtil.getFp($r('app.float.tab_label_font_size')))
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.todo_primary') : $r('app.color.todo_text_hint'))
        .margin({ top: DimensionUtil.getVp($r('app.float.tab_label_margin_top')) })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({
      top: DimensionUtil.getVp($r('app.float.tab_bar_padding_vertical')),
      bottom: DimensionUtil.getVp($r('app.float.tab_bar_padding_vertical'))
    })
  }

  build(): void {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {
      // Tab 0: Alarm page
      TabContent() {
        AlarmPage()
      }
      .tabBar(this.TabBuilder('闹钟', 0, '⏰'))

      // Tab 1: Todo page
      TabContent() {
        TodoPage()
      }
      .tabBar(this.TabBuilder('待办', 1, '☑'))
    }
    .scrollable(false)
    .barHeight(DimensionUtil.getVp($r('app.float.tab_bar_height')))
    .barMode(BarMode.Fixed)
    .barBackgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
