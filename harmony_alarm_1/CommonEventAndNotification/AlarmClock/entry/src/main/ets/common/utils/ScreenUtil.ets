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

import window from '@ohos.window';
import { common } from '@kit.AbilityKit';

/**
 * Breakpoint types for responsive layout.
 * Follows HarmonyOS official breakpoint ranges.
 */
export enum BreakpointType {
  /** Phone portrait: width <= 520 vp */
  SM = 'sm',
  /** Tablet portrait / phone landscape: 520 < width <= 840 vp */
  MD = 'md',
  /** Tablet landscape / large tablet: width > 840 vp */
  LG = 'lg'
}

/**
 * Layout type for component arrangement.
 */
export enum LayoutType {
  /** Single column layout for phones */
  SINGLE_COLUMN = 0,
  /** Two column layout for tablets */
  TWO_COLUMN = 1
}

/**
 * Screen adaptation utility.
 * Detects screen size breakpoints and provides layout decisions.
 * Uses window size change listener for reactive updates via AppStorage.
 */
export class ScreenUtil {
  private static instance: ScreenUtil;
  private currentBreakpoint: BreakpointType = BreakpointType.SM;
  private initialized: boolean = false;

  private constructor() {
  }

  /**
   * Get singleton instance.
   */
  public static getInstance(): ScreenUtil {
    if (ScreenUtil.instance == null) {
      ScreenUtil.instance = new ScreenUtil();
    }
    return ScreenUtil.instance;
  }

  /**
   * Initialize the breakpoint system.
   * Must be called from EntryAbility.onWindowStageCreate() after the window is created.
   *
   * @param context application context
   */
  public init(context: common.Context): void {
    if (this.initialized) {
      return;
    }
    this.initialized = true;

    window.getLastWindow(context).then((win: window.Window) => {
      // Set initial breakpoint based on current window size
      this.updateBreakpointFromWindow(win);

      // Listen for window size changes
      win.on('windowSizeChange', (size: window.Size) => {
        let widthVp: number = px2vp(size.width);
        this.setBreakpointFromWidth(widthVp);
      });
    }).catch((err: Error) => {
      console.error('ScreenUtil.init: failed to get window, ' + JSON.stringify(err));
    });
  }

  /**
   * Update breakpoint from window properties (initial detection).
   */
  private updateBreakpointFromWindow(win: window.Window): void {
    let properties = win.getWindowProperties();
    let widthPx: number = properties.windowRect.width;
    let widthVp: number = px2vp(widthPx);
    this.setBreakpointFromWidth(widthVp);
  }

  /**
   * Determine and update breakpoint from vp width.
   */
  private setBreakpointFromWidth(widthVp: number): void {
    let newBp: BreakpointType;
    if (widthVp <= 520) {
      newBp = BreakpointType.SM;
    } else if (widthVp <= 840) {
      newBp = BreakpointType.MD;
    } else {
      newBp = BreakpointType.LG;
    }
    if (newBp !== this.currentBreakpoint) {
      this.currentBreakpoint = newBp;
      AppStorage.setOrCreate('currentBreakpoint', this.currentBreakpoint);
    }
  }

  /**
   * Check if current device is a tablet (MD or LG breakpoint).
   */
  public static isTablet(): boolean {
    let bp: BreakpointType = ScreenUtil.getInstance().currentBreakpoint;
    return bp === BreakpointType.MD || bp === BreakpointType.LG;
  }

  /**
   * Check if current device is a phone (SM breakpoint).
   */
  public static isPhone(): boolean {
    return ScreenUtil.getInstance().currentBreakpoint === BreakpointType.SM;
  }

  /**
   * Get recommended layout type based on current breakpoint.
   * SM -> SINGLE_COLUMN, MD/LG -> TWO_COLUMN
   */
  public static getLayoutType(): LayoutType {
    if (ScreenUtil.isTablet()) {
      return LayoutType.TWO_COLUMN;
    }
    return LayoutType.SINGLE_COLUMN;
  }

  /**
   * Get current breakpoint string value.
   */
  public static getCurrentBreakpoint(): string {
    return ScreenUtil.getInstance().currentBreakpoint;
  }
}
