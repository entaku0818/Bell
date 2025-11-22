# BoardingBell

**搭乗券を撮影して自動でアラーム設定するiOSアプリ**

📸 → 🔍 → ✈️ → ⏰

## 機能

- **写真選択**: ライブラリから搭乗券の写真を選択
- **自動認識**: Vision OCRでフライト情報を抽出
- **スマートアラーム**: 出発2時間前に自動でアラーム設定
- **Live Activity**: ロック画面でカウントダウン表示

## 対応環境

- iOS 26.0以上
- Xcode 16.0以上

## 使い方

1. **写真を選択**
   - 「写真を選択」ボタンをタップ
   - ライブラリから搭乗券の写真を選択

2. **情報を確認**
   - 便名、行き先、出発時刻が自動で認識されます
   - 認識された情報を確認

3. **アラームを設定**
   - 「アラームを設定」ボタンをタップ
   - 出発2時間前にアラームが設定されます

4. **Live Activityで確認**
   - ロック画面で搭乗までの残り時間を確認
   - アラート時にはアクションボタンで操作可能

## 認識可能な情報

### 便名
- 例: NH123, JL456, ANA 789

### 日付
- 2025/06/15
- 15JUN
- 6月15日

### 時刻
- 14:30
- 14時30分
- 2:30PM

### 行き先
- TOKYO, HND, 羽田
- OSAKA, KIX, 大阪
- など主要空港

## アーキテクチャ

```
iOS/Bell/
├── BellApp.swift                 # アプリエントリーポイント
├── ContentView.swift             # メイン画面
├── AlarmViewModel.swift          # アラーム管理
├── TextRecognitionService.swift  # Vision OCR
├── FlightDateParser.swift        # 日時解析
├── ExtractedFlightInfo.swift     # データモデル
├── FlightAlarmData.swift         # AlarmKit メタデータ
└── AlarmLiveActivity.swift       # Live Activity
```

## ライセンス

MIT License

## 開発

各フェーズの実装詳細は [DESIGN.md](DESIGN.md) を参照してください。
