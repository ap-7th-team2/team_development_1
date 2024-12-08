"use strict";

// 削除モーダルダイアログ
document.addEventListener('DOMContentLoaded', () => {
  const modal = document.getElementById('deleteModal');
  const trashIcon = document.getElementById('trash-can-icon');
  const yesButton = document.getElementById('deleteYes');
  const noButton = document.getElementById('deleteNo');
  // URLからidを取得
  const snippetId = window.location.pathname.split('/').pop();

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
  yesButton.addEventListener('click', async () => {
    try {
      const response = await fetch(`/delete/${snippetId}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        window.location.href = '/?deleted=true';
      } else {
        alert('削除に失敗しました');
      }
    } catch (error) {
      console.error('Error:', error);
      alert('削除に失敗しました');
    }
  });
});
