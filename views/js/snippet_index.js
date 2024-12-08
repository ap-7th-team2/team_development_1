document.addEventListener('DOMContentLoaded', () => {
  const filterMenuOverlay = document.getElementById('filter-menu-overlay');
  const filterButton = document.getElementById('filter-button');

  // フィルターメニューを表示
  filterButton.addEventListener('click', () => {
    // console.log('Opening menu'); // デバッグ用
    filterMenuOverlay.classList.remove('hidden');
  });

  // オーバーレイの外をクリックしてメニューを閉じる
  filterMenuOverlay.addEventListener('click', (event) => {
    if (event.target === filterMenuOverlay) {
      // console.log('Clicked outside menu'); // デバッグ用
      filterMenuOverlay.classList.add('hidden');
    }
  });
});

// トースト通知を表示する関数
const showToast = (message) => {
  const toast = document.getElementById('toast-notification');
  const toastMessage = document.getElementById('toast-message');

  // メッセージをセット
  toastMessage.textContent = message;

  // トーストを表示
  toast.classList.remove('hidden');
  toast.style.opacity = '1';
  toast.style.transform = 'translateX(-50%) translateY(0)';

  // 一定時間後に非表示
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(-50%) translateY(20px)';
    setTimeout(() => {
      toast.classList.add('hidden');
    }, 500); // トランジション後に完全に非表示
  }, 3000); // 3秒間表示
};

// ページ読み込み時にクエリパラメータをチェック
document.addEventListener('DOMContentLoaded', () => {
  const urlParams = new URLSearchParams(window.location.search);
  const toastMessage = urlParams.get('toast_message');

  if (toastMessage) {
    showToast(toastMessage);
  }
});
