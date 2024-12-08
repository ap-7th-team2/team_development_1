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

  if (!toast || !toastMessage) {
    console.error('トースト通知用の要素が見つかりません');
    return; // 要素が見つからない場合は処理を中断
  }

  // メッセージをセット
  toastMessage.textContent = message;

  // トーストを表示
  console.log('Before removing hidden:', toast.classList);
  toast.classList.remove('hidden');
  console.log('After removing hidden:', toast.classList);
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

document.addEventListener('DOMContentLoaded', () => {
  const urlParams = new URLSearchParams(window.location.search);
  const toastMessage = urlParams.get('toast_message');
  if (toastMessage) {
    showToast(toastMessage);
  }
});

document.addEventListener('DOMContentLoaded', () => {
  // 数値のみのidを正規表現でフィルタリング
  const snippetElements = document.querySelectorAll('[id]'); // IDが設定されているすべての要素を取得

  snippetElements.forEach((element) => {
    if (/^\d+$/.test(element.id)) {
      // 数値のみであることをチェック
      element.addEventListener('click', (event) => {
        const snippetId = event.target.id; // IDを取得
        if (snippetId) {
          window.location.href = `/snippets/${snippetId}`; // 遷移処理
        }
      });
    }
  });
});

document.addEventListener('DOMContentLoaded', () => {
  const tagButtons = document.querySelectorAll('#filter-menu .tag');
  const sortButtons = document.querySelectorAll('#filter-menu button[data-sort]');

  tagButtons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const selectedTag = event.target.textContent;
      window.location.href = `/get_snippets?tags=${encodeURIComponent(selectedTag)}`;
    });
  });

  sortButtons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const sortBy = event.target.getAttribute('data-sort');
      window.location.href = `/get_snippets?sort_by=${encodeURIComponent(sortBy)}`;
    });
  });

  // 検索機能
  const searchInput = document.querySelector('.search-container input');
  searchInput.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
      const searchTerm = event.target.value;
      window.location.href = `/get_snippets?search=${encodeURIComponent(searchTerm)}`;
    }
  });
});
