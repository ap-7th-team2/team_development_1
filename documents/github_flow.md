# GitHubフローの仕様書
## はじめに
今回、チーム開発にてオリジナルの開発ルールを作成しました👍
開発に辺り以下の手順で開発手法を取り入れて行なってください🙇‍♂️

---

## Issueの作成
1. GitHub上の該当プロジェクトのタブから`Issues`を選択する
2. `New issue`を選択
3. 予めテンプレート化したnormal_issueの`Get stated`を選択
4. title、descriptionのテンプレート内容に従い記述
5. Assignees、Labelsを選択し担当者、Labelの選択を行う ※Labelがない場合は作成お願いします
6. `Submit new issue`を選択し作成完了

---

## 開発手順
#### 1. ローカル環境にクローン
```bash
git clone <URL>
```
#### 2. ブランチを切って開発
```bash
  git branch 新規ブランチ名_#issue番号
```
* `_#issue番号`と末尾につけることにより作成したissue番号と紐付けることができる
* `git switch 新規ブランチ名_#issue番号`にてブランチの切り替えもお忘れなく・・・

#### 3. コミットメッセージの注意点
・ファイルを編集し`git add ファイル名`後のコミットメッセージの記述方法
```bash
git commit -m "プレフィックス: コミットメッセージ #issue番号"
```
* コミットする際は**プレフィックス**と**issue番号**をお忘れなく

**プレフィックス一覧**
| Prefix   | 意味                                                  |
|----------|----------------------------------------------------- |
| `add`    | ちょっとしたファイル・コードの追加（例: 画像ファイルの追加）   |
| `change` | ちょっとしたファイル・コードの変更（例: 画像差し替え）        |
| `feat`   | ユーザーが利用する機能の追加。`add`/`change`を内包しても良い |
| `style`  | 機能部分を変更しない、コードの見た目の変化（例: CSSの調整）   |
| `refactor` | リファクタリング                                      |
| `fix`    | バグ修正                                               |
| `remove` | ファイルなどの削除                                      |
| `test`   | テスト関連                                             |
| `chore`  | ビルド、補助ツール、ライブラリ関連                         |
| `docs`   | ドキュメントのみ変更                                     |

#### 4. プッシュ
* 作業が完了したらローカルリポジトリの内容をリモートリポジトリにプッシュ
```bash
git push origin 作業ブランチ名
```
このとき作業ブランチ宛にプッシュすることに注意！

#### 5. プルリクエスト
1. `Compare & pull request`を選択
2. `Create pull request`を選択
* PRの際はPRテンプレートを作成しているのでテンプレートに従ってPRを行う
* PRビューはチームから1人`LGTM`をいただくとマージ可能

#### 6. マージ
* コードレビュー後、Approveされたらマージを実行
1. `Confirm merge`を選択し`mainブランチ`に反映
2. `Delete branch`を選択し、ブランチを削除

#### 7. プル
1. ローカル環境のブランチを`main`に切り替える
```bash
git pull origin main
```
* リモートリポジトリの`mainブランチ`をローカルリポジトリに反映
2. ローカル環境の作業ブランチを削除
```bash
git branch -b 作業ブランチ名
```
* 再度、開発手順の**2〜7を繰り返して**開発を行う

---

## コードレビュー
#### 動作確認
* プルリクエストの内容を自分のローカル環境で動作確認する場合の手順
1. GitHub上で`Pull requests`を選択
2. プルリクエストIDとブランチ名を確認
3. ターミナルにて`git fetch`コマンドを使用
```bash
git fetch origin pull/プルリクID/head:ブランチ名
```

#### レビュー
* プルリクエストのレビューの手順
1. `Pull requests`を選択
2. プルリクエスト内の`Files changed`を選択
3. レビューが完了したら`Finish your review`を選択
4. `Comment`、`Approve`、`Request changes`のどれかを選択
    * Comment：変更の提案やフィードバックを提供する。承認/非承認もしない場合は、Commentを選択しましょう。
    * Approve：変更を承認する。この変更で問題ないと思ったら、Approveを選択しましょう。
    * Request changes：修正が必要であることを示す。修正が必要であると思ったら、Request changeを選択しましょう。
5. `Submit review`を選択しレビュー完了

---

## まとめ
以上がチーム開発でのGitHubフローでした！他にも開発にあたってコンフリクトなど色々とエラーに直面すると思いますがチームで協力して乗り越えていきましょーう🙌
