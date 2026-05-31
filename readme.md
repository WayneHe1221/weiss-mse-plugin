ronelm2000's Weiss Schwarz Plugin for MSE2
===========
[![Discord](https://img.shields.io/discord/831048458608705627?label=Discord)](https://discord.gg/9T55jJGHJD)
[![Downloads](https://img.shields.io/github/downloads/ronelm2000/weiss-mse-plugin/total.svg)](https://tooomm.github.io/github-release-stats/?username=ronelm2000&repository=weiss-mse-plugin)
[![WS Discord](https://img.shields.io/badge/WS%20Discord-%3F%3F%3F-lime)](https://discord.gg/B5RbYXH)

Weiss Schwarz ©bushiroad All Rights Reserved.

This plugin for MSE2 (or Magic Set Editor 2) is designed to make custom cards for Weiss Schwarz, a TCG from Bushiroad. There's actually 2 major card forks for this plugin; one is by Benitez and is currently developed by Chairman, and the other (which is the the older one from sion) is currently this fork.

This fork supports the newest mechanics, including "Link", "Choice", "Replay", "Standby", three traits, long 2nd trait, etc.. This fork also supports the JP Text Name bar found exclusively in English Imported Sets using the latest style from Chainsaw Man English Edition, as well as importing sets from Benitez (but with some missing data). This set also supports foil/SP mechanics, but not SEC.

![MSE UI](https://user-images.githubusercontent.com/12634987/220225328-485ba3ae-0c9a-410a-9770-bf1b8f4ca2dc.png)

## Installation
### Stable
1. Ensure all necessary files are downloaded.
   - You can get the latest stable release [here](https://github.com/ronelm2000/weiss-mse-plugin/releases).
   - You need [Magic Set Editor 2.1.2](https://github.com/twanvl/MagicSetEditor2/releases/) and not any other older versions.
2. Run downloaded `weiss2.mse-installer` in MSE.
   1. Go to the downloaded file.
   2. Drag it.
   3. Open your MSE installation folder.
   4. Drop it into `MSE.exe`.
   5. This will open MSE.
   6. Click on "OK" to install all missing packages.
3. Download provided `fonts.zip` and install all fonts in it.
   1. Extract all files in the zip file.
   2. The first file should be `__install_fonts.ps1`. Right-Click on it.
   3. Click on `Run With PowerShell`.
### From Source
1. Download the latest source file [here](https://github.com/ronelm2000/weiss-mse-plugin/archive/refs/heads/master.zip).
2. Extract the Files on the data folder of your Magic Set Editor installation (release binaries on the link above)
3. Go to `\data\weiss2-real-multiple-layouts.mse-style\font` and install all fonts on that folder.

## Usage
1. After creating a new set with `RWeiss > Standard`, you can create cards with the `Add Card` button.
2. You can click on any of the following to change its card stats:
   - Level Icon
   - Cost Icon
   - Trigger
   - Icons Under the Cost (Counter or Alarm)
   - The area where `CH` is (Card Type)
   - The area on the right of the serial (Card Rarity)
   - Soul Icon
   - Logo
   - Art
3. Blank inputs provide the following information:
   - Flavor Text
   - Rules Text
   - Replay Text (Separate from the Rules Text)
   - Traits (Traits 1, 2, and 3) (Only avaiable for Characters)
   - Copyright Text
   - Export Card Name (To access this, go to `Style` and change `Card Meta Type` to `EN/JP Import`)
4. Click on `Style` Tab to change specific details for Weiss cards
   *Note: To change the style of only 1 card, be sure to check `Options specific to this card`.
5. Click on `Set Info` tab to change details pertaining to the set.
   - Set ID and Subset ID changes the Serial Prefix used for each card
   - Side changes the default Side color used for the set (can be overrided from `Style` settings)
   - `Is using legacy card images` is for compatibility for older sets
6. When typing on `Rules Text` and `Replay Text`, the following features are also available:
   - As with MSE2, Bold, Italics, and Symbols are provided for usage, including their keyboard shortcuts.
   - If you type \`\``Replay Text`\`\`, it will be replaced with Red Bold Text (Used for Replay and Rules Text involving Replay)
   - If you type `(1)`, it will be replaced with the corresponding symbol for stock.
   - If you type `<<<` and `>>>`, it will be replaced with the corresponding trait symbol.
   - If you type `AUTO`, it will be replaced with `<sym>A|</sym>` which outputs the AUTO symbol text. Further rules are provided in the `Keywords`.

## 高畫質 / 印刷匯出（中文）

若你想把卡片**印刷成實體卡**，請依下列步驟取得高畫質、可裁切的圖檔。

### 1. 選擇匯出格式
用 `File → Export Set`，選擇 `wsmtools Exporter` 模板後，在選項中：
- **Export images**：勾選（要輸出圖檔才需要）。
- **Image format**：選擇輸出格式。
  - `jpg`：檔案最小、有失真壓縮（Tabletop Simulator 預設用此）。
  - `png` / `tiff` / `bmp`：無損格式，**印刷建議使用**（推薦 `png` 或 `tiff`）。
  - 註：`tiff` / `bmp` 是否能成功輸出，取決於你的 MSE 版本，請實際輸出一張確認檔案可開啟。
- 也可以用 `File → Export Image` 單張匯出（該對話框可選 PNG/JPG 與縮放倍率）。

### 2. 拉高畫質（解析度）
卡片基準畫布為 448×626 px / 178 DPI，對印刷偏低。請在 wsmtools 的 **Zoom multiplier** 欄位填較大的值：
- 填 `3` → 約 1344×1878 px，已遠超印刷常見的 300 DPI 需求。
- 想更高可填 `4`。倍率越高，檔案越大、輸出越慢。
- 用內建 `Export Image` 時，同樣把 scale 設為 `3` 以上。

### 3. 加上 5mm 印刷留邊（方便裁切）
MSE 本身無法在匯出時加留白，因此提供一支後處理腳本（Windows 內建 .NET，免安裝額外軟體）。

匯出完成後，在 `weiss2.mse-game/devtools/` 內對輸出資料夾執行：
```powershell
.\add-print-border.ps1 -Path "你的卡圖資料夾"
```
常用參數：
- `-BorderMM 5`：留邊寬度（毫米），預設 5mm，四邊皆套用。
- `-Color White`：留邊顏色，可選 `White` / `Black` / `Transparent`（透明僅 png/tiff 有效）。
- `-OutDir "輸出資料夾"`：指定另存位置；不填則直接覆蓋原圖。
- `-JpegQuality 95`：jpg/jpeg 的存檔品質（1–100）。

留邊以「實際毫米」計算（依每張圖的真實寬度換算），因此不論你用多少倍率匯出，都會是準確的 5mm。

> 💡 macOS 注意：MSE2 沒有 macOS 版本，需透過 Wine / CrossOver 或 Windows 虛擬機執行 MSE 與上述 PowerShell 腳本。

## Known Issues
#### I cannot type in Korean/Japanese!
This has been reported to be a [known issue](https://github.com/twanvl/MagicSetEditor2/issues/121) in MSE 2.1.2. In order to resolve this issue, please instead download [this version of MSE](https://github.com/haganbmj/MagicSetEditor2/releases/tag/v2.2.2) while waiting for an update that hopefully fixes the issue. I have not created this plugin with these languages in mind tho, so if you need to request some adjustments, please file a issue and attach your `.mse-set` file so I can work on it.

#### I changed the one of the styles options but my changes did not persist!
This is a minor UI issue caused by MSE not updating the card UI when going from Style to Card. As long as you click on the Rules Text your changes should be reflected.


