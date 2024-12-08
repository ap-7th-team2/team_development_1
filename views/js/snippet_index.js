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

document.addEventListener('DOMContentLoaded', () => {
  // 数値のみのidを正規表現でフィルタリング
  const snippetElements = document.querySelectorAll('[id]'); // IDが設定されているすべての要素を取得

  snippetElements.forEach(element => {
    if (/^\d+$/.test(element.id)) { // 数値のみであることをチェック
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

  tagButtons.forEach(button => {
    button.addEventListener('click', (event) => {
      const selectedTag = event.target.textContent;
      window.location.href = `/get_snippets?tags=${encodeURIComponent(selectedTag)}`;
    });
  });

  sortButtons.forEach(button => {
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

// クリップボードにコピーする関数
// クリップボードにコピーする関数
async function copyToClipboard(content, btn) {
  try {
    // Clipboard APIを使用してクリップボードにコピー
    await navigator.clipboard.writeText(content);

    // 「copied」メッセージを表示
    const copiedMessage = btn.closest('.snippet').querySelector('.copied-message');
    if (copiedMessage) {
      copiedMessage.style.display = 'block';

      // 2秒後に非表示にする
      setTimeout(() => {
        copiedMessage.style.display = 'none';
      }, 2000);
    }
  } catch (error) {
    console.error('Clipboard API failed:', error);
    alert('Failed to copy!');
  }
}
