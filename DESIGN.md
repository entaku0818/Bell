# BoardingBell 設計書

**航空券を撮影 → 自動でアラーム設定**

| 項目 | 内容 |
|------|------|
| 対応OS | iOS 26.0+ |
| フレームワーク | SwiftUI, AlarmKit, Vision |

---

## 1. 概要

```
📸 搭乗券を撮影 → 🔍 文字認識 → ✈️ フライト情報抽出 → ⏰ 出発2時間前にアラーム
```

---

## 2. 認識する情報

| 項目 | 認識パターン例 |
|------|----------------|
| 便名 | NH123, JL456, ANA 789 |
| 日付 | 2025/06/15, 15JUN, 6月15日 |
| 時刻 | 14:30, 14時30分, 2:30PM |
| 行き先 | TOKYO, HND, 羽田 |

---

## 3. 画面フロー

```
ホーム → 撮影/選択 → 読み取り中 → 確認・編集 → 設定完了
```

---

## 4. ファイル構成

```
BoardingBell/
├── BoardingBellApp.swift
├── ContentView.swift              # メイン画面
├── AlarmViewModel.swift           # ビジネスロジック
├── TextRecognitionService.swift   # Vision OCR
├── FlightDateParser.swift         # 日時解析
├── FlightAlarmData.swift          # AlarmKit用メタデータ
└── AlarmLiveActivity.swift        # Live Activity
```

---

## 5. データモデル

```swift
// 抽出されたフライト情報
struct ExtractedFlightInfo {
    let flightNumber: String      // NH123
    let departureDate: Date       // 出発日時
    let destination: String       // 行き先
    let gate: String?             // ゲート番号
}

// AlarmKit用メタデータ
struct FlightAlarmData: AlarmMetadata {
    let flightNumber: String
    let destination: String
}
```

---

## 6. 認識パターン（正規表現）

```swift
// 便名
let flightPattern = "[A-Z]{2,3}\\s?\\d{1,4}"

// 日付
let datePatterns = [
    "\\d{4}/\\d{1,2}/\\d{1,2}",     // 2025/6/15
    "\\d{2}[A-Z]{3}",               // 15JUN
    "\\d{1,2}月\\d{1,2}日"           // 6月15日
]

// 時刻
let timePatterns = [
    "\\d{1,2}:\\d{2}",              // 14:30
    "\\d{1,2}時\\d{1,2}分"           // 14時30分
]
```

---

## 7. アラーム設定

| 設定項目 | 値 |
|----------|-----|
| デフォルト通知 | 出発2時間前 |
| preAlert | 10分 |
| postAlert | 5分 |
| tintColor | .blue |

---

## 8. Live Activity表示

**カウントダウン中**
```
🔔 NH123 羽田行き
   搭乗まで 1:45:30
   [一時停止]
```

**アラート時**
```
🔔 搭乗時刻です！
   NH123 羽田行き
   [確認済み] [5分後]
```

---

## 9. 開発スケジュール

| フェーズ | 内容 | 期間 | 状態 |
|----------|------|------|------|
| Phase 1 | 基本UI + 写真選択 | 1週間 | ✅ 完了 |
| Phase 2 | Vision OCR + 日時解析 | 1週間 | ✅ 完了 |
| Phase 3 | AlarmKit連携 | 1週間 | ✅ 完了 |
| Phase 4 | Live Activity | 3日 | ✅ 完了 |
| Phase 5 | テスト・調整 | 3日 | ✅ 完了 |

**合計: 約4週間**

---

## 10. 実装済み機能

### Phase 1: 基本UI + 写真選択
- ✅ PhotosPickerで写真選択
- ✅ 選択した画像のプレビュー表示
- ✅ ナビゲーションとレイアウト

### Phase 2: Vision OCR + 日時解析
- ✅ TextRecognitionServiceによる文字認識
- ✅ FlightDateParserで日時抽出
- ✅ 複数の日付・時刻フォーマット対応
- ✅ 便名・行き先・ゲート番号の抽出
- ✅ 認識結果のカード表示

### Phase 3: AlarmKit連携
- ✅ FlightAlarmDataでメタデータ管理
- ✅ AlarmViewModelでアラーム制御
- ✅ 2時間前アラーム自動設定
- ✅ アラームキャンセル機能
- ✅ スヌーズ機能

### Phase 4: Live Activity
- ✅ ActivityKit統合
- ✅ カウントダウンタイマー表示
- ✅ アラート時のアクションボタン
- ✅ ロック画面/Dynamic Island対応

### Phase 5: テスト・調整
- ✅ README.md作成
- ✅ ドキュメント整備
- ✅ エラーハンドリング
