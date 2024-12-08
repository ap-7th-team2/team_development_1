// モーダル関連の要素を取得
const modal = document.getElementById('confirmation-modal');
const submitButton = document.getElementById('modal-submit');
const cancelButton = document.getElementById('modal-cancel');
const form = document.querySelector('form');

// エラーメッセージを表示する関数
const showError = (message) => {
  const errorContainer = document.getElementById('error-container');
  const errorText = document.getElementById('error-text');

  // メッセージをセット
  errorText.textContent = message;

  // エラー表示を有効にする
  errorContainer.classList.remove('hidden');
  clearTimeout(showError.timeout);

  // 5秒後にエラーを非表示にする
  showError.timeout = setTimeout(() => {
    errorContainer.classList.add('hidden');
  }, 5000);
};

// バリデーション関数
const validateForm = () => {
  const title = document.querySelector('input[name="title"]').value.trim();
  const code = document.querySelector('textarea[name="code"]').value.trim();

  if (title === '' || code === '') {
    showError('タイトルとコードは必須です！');
    return false;
  }
  return true;
};

// フォーム送信時にバリデーションとモーダル表示を連携
form.addEventListener('submit', (event) => {
  event.preventDefault(); // デフォルトの送信動作を一時停止

  if (validateForm()) {
    modal.classList.remove('hidden'); // モーダルを表示
  }
});

// モーダルのSubmitボタンをクリックした場合
submitButton.addEventListener('click', () => {
  modal.classList.add('hidden'); // モーダルを非表示
  form.submit(); // フォームを送信
});

// モーダルのCancelボタンをクリックした場合
cancelButton.addEventListener('click', () => {
  modal.classList.add('hidden'); // モーダルを非表示
});
