let currentOffset = 0; // 現在のオフセット値
const limit = 4; // 一度に表示するスニペットの数

// スニペットデータを取得して表示する
async function fetchSnippets(offset = 0) {
  try {
    const response = await fetch(`http://localhost:8000/get_snippets?offset=${offset}&limit=${limit}`);
    
    if (response.ok) {
      const snippets = await response.json();
      displaySnippets(snippets);
      currentOffset += limit; // オフセットを更新
    } else {
      console.error('Error:', response.status);
    }
  } catch (error) {
    console.error('Fetch error:', error);
  }
}

// スニペットをHTMLに表示
function displaySnippets(snippets) {
  const container = document.getElementById('snippet-container');
  snippets.forEach(snippet => {
    const snippetDiv = document.createElement('div');
    snippetDiv.classList.add('snippet');
    
    const title = document.createElement('h2');
    title.innerText = snippet.title;
    
    const content = document.createElement('p');
    // 10文字で打ち切り、文字数が100を超える場合は...を追加
    content.innerText = snippet.content.length > 100 
      ? snippet.content.substring(0, 100) + '...' 
      : snippet.content;
    
    const tagsContainer = document.createElement('div');
    tagsContainer.classList.add('snippet-tags');
    
    if (snippet.tags && snippet.tags.length > 0) {
      snippet.tags.forEach(tag => {
        const tagSpan = document.createElement('span');
        tagSpan.classList.add('tag');
        tagSpan.innerText = tag;
        tagsContainer.appendChild(tagSpan);
      });
    }
    
    snippetDiv.appendChild(title);
    snippetDiv.appendChild(content);
    snippetDiv.appendChild(tagsContainer);
    container.appendChild(snippetDiv);
  });
}

// 初回のスニペット表示
fetchSnippets(currentOffset, limit);

// 「もっと見る」ボタンのイベントリスナー
document.getElementById('load-more').addEventListener('click', () => {
  fetchSnippets(currentOffset, limit);
});
