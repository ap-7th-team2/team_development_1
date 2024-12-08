'use strict';

// 削除モーダルダイアログ
document.addEventListener('DOMContentLoaded', () => {
  const modal = document.getElementById('deleteModal');
  const trashIcon = document.getElementById('trash-can-icon');
  const yesButton = document.getElementById('deleteYes');
  const noButton = document.getElementById('deleteNo');
  // URLからidを取得
  const snippetId = window.location.pathname.split('/snippets/').pop();

  // ごみ箱アイコンをクリック
  trashIcon.addEventListener('click', (e) => {
    e.preventDefault();
    // displayをblockにして表示
    modal.style.display = 'block';
  });

  // Cancelボタン
  noButton.addEventListener('click', () => {
    modal.style.display = 'none';
  });

  // Deleteボタン
  yesButton.addEventListener('click', () => {
    // 削除用のフォームを作成して送信
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = `/delete/${snippetId}`;

    // method-override用の隠しフィールド
    const methodInput = document.createElement('input');
    methodInput.type = 'hidden';
    methodInput.name = '_method';
    methodInput.value = 'DELETE';

    form.appendChild(methodInput);
    document.body.appendChild(form);
    form.submit();
  });
});


// スニペットのピー機能
document.addEventListener('DOMContentLoaded', () => {

  // 要素の取得
  const copyIcon = document.getElementById('copy-icon');
  const snippetContent = document.querySelector('.code').textContent;
  const copied = document.querySelector('.copied');

  // コピーアイコンをクリック
  copyIcon.addEventListener('click', () => {
    // クリップボードにコピー
    navigator.clipboard.writeText(snippetContent);
    // copiedのスタイルを表示
    copied.style.display = 'block';
    // 2秒後に非表示
    setTimeout(() => {
      copied.style.display = 'none';
    }, 2000);
  });
});
