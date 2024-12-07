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
