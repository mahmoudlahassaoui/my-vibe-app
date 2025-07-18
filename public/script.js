console.log('External script loaded!');

function changeBackgroundColor() {
  console.log('Button clicked from external script!');
  var colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];
  var newColor = colors[Math.floor(Math.random() * colors.length)];
  document.body.style.backgroundColor = newColor;
  localStorage.setItem('vibeAppBackgroundColor', newColor);
}

function startGame() {
  alert('Game starting from external script!');
}

function applyPalette(name) {
  var colors = { 
    sunset: '#ff6b6b', 
    ocean: '#4ecdc4', 
    forest: '#98fb98', 
    royal: '#667eea' 
  };
  document.body.style.backgroundColor = colors[name];
  localStorage.setItem('vibeAppBackgroundColor', colors[name]);
}

function gameClick(color) {
  alert('Game tile clicked: ' + color);
}// AI News F
unctionality
let currentFilter = 'all';
let newsData = [];

// Mock AI news data (we'll replace this with real API calls)
const mockAINews = [
  {
    id: 1,
    title: "Claude 3.5 Sonnet Introduces Revolutionary Code Generation",
    summary: "Anthropic's latest Claude model shows unprecedented accuracy in code generation and debugging tasks.",
    category: "claude",
    source: "AI Research Today",
    url: "https://example.com/claude-news",
    publishedAt: "2024-01-15T10:30:00Z"
  },
  {
    id: 2,
    title: "ChatGPT-4 Turbo Now Available with Enhanced Reasoning",
    summary: "OpenAI releases improved version with better logical reasoning and reduced hallucinations.",
    category: "chatgpt",
    source: "Tech AI News",
    url: "https://example.com/chatgpt-news",
    publishedAt: "2024-01-14T15:45:00Z"
  },
  {
    id: 3,
    title: "New Open Source LLM Rivals GPT-4 Performance",
    summary: "Meta releases Llama 3.1 with competitive performance on coding and reasoning benchmarks.",
    category: "llm",
    source: "Open Source AI",
    url: "https://example.com/llm-news",
    publishedAt: "2024-01-13T09:20:00Z"
  },
  {
    id: 4,
    title: "YouTube Creator Builds AI Assistant with Claude API",
    summary: "Popular tech YouTuber demonstrates building a personal AI assistant using Claude's API.",
    category: "youtube",
    source: "AI Creators Hub",
    url: "https://youtube.com/watch?v=example",
    publishedAt: "2024-01-12T18:15:00Z"
  },
  {
    id: 5,
    title: "Google Announces Gemini Pro with Multimodal Capabilities",
    summary: "Google's latest AI model can process text, images, and code simultaneously.",
    category: "tech",
    source: "Google AI Blog",
    url: "https://example.com/gemini-news",
    publishedAt: "2024-01-11T12:00:00Z"
  }
];

function loadAINews() {
  console.log('Loading AI news...');
  
  // Simulate API loading delay
  setTimeout(() => {
    newsData = mockAINews;
    displayNews(newsData);
    document.getElementById('loading-status').textContent = '✅ Latest AI news loaded!';
    setTimeout(() => {
      document.querySelector('.news-loading').style.display = 'none';
    }, 1000);
  }, 2000);
}

function displayNews(articles) {
  const container = document.getElementById('news-container');
  if (!container) return;
  
  if (articles.length === 0) {
    container.innerHTML = '<div class="news-empty">📰 No news articles found for this category.</div>';
    return;
  }
  
  container.innerHTML = articles.map(article => `
    <div class="news-card ${article.category}">
      <div class="news-header">
        <h3 class="news-title">
          <a href="${article.url}" target="_blank">${article.title}</a>
        </h3>
        <div class="news-meta">
          <span class="news-category">${article.category}</span>
          <span class="news-date">${formatDate(article.publishedAt)}</span>
        </div>
      </div>
      <div class="news-body">
        <p class="news-summary">${article.summary}</p>
        <a href="${article.url}" target="_blank" class="news-link">Read More →</a>
      </div>
    </div>
  `).join('');
}

function filterNews(category) {
  console.log('Filtering news by:', category);
  currentFilter = category;
  
  // Update active filter button
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.classList.remove('active');
  });
  event.target.classList.add('active');
  
  // Filter and display news
  const filteredNews = category === 'all' 
    ? newsData 
    : newsData.filter(article => article.category === category);
  
  displayNews(filteredNews);
}

function refreshNews() {
  console.log('Refreshing AI news...');
  document.querySelector('.news-loading').style.display = 'block';
  document.getElementById('loading-status').textContent = '🔄 Refreshing latest AI news...';
  document.getElementById('news-container').innerHTML = '';
  
  // Reload news
  loadAINews();
}

function formatDate(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  const diffTime = Math.abs(now - date);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  if (diffDays === 1) return 'Yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  return date.toLocaleDateString();
}

// Auto-load news when on AI news page
document.addEventListener('DOMContentLoaded', function() {
  if (window.location.pathname === '/ai-news') {
    console.log('AI News page detected, loading news...');
    loadAINews();
  }
});// AI Ne
ws functionality
var aiNewsData = [
  {
    id: 1,
    title: "Claude 3.5 Sonnet Achieves New Benchmarks in AI Reasoning",
    summary: "Anthropic's latest Claude model shows significant improvements in complex reasoning tasks and coding capabilities.",
    category: "claude",
    date: "2024-12-15",
    link: "#"
  },
  {
    id: 2,
    title: "ChatGPT-4 Turbo Gets Major Speed Improvements",
    summary: "OpenAI announces faster response times and improved accuracy for their flagship language model.",
    category: "chatgpt",
    date: "2024-12-14",
    link: "#"
  },
  {
    id: 3,
    title: "New Research Shows LLMs Can Learn from Fewer Examples",
    summary: "Breakthrough in few-shot learning could make AI training more efficient and accessible.",
    category: "llm",
    date: "2024-12-13",
    link: "#"
  },
  {
    id: 4,
    title: "Google Announces Gemini Pro with Multimodal Capabilities",
    summary: "The new model can process text, images, and audio simultaneously for more comprehensive AI interactions.",
    category: "tech",
    date: "2024-12-12",
    link: "#"
  },
  {
    id: 5,
    title: "Claude Gets New Creative Writing Features",
    summary: "Enhanced storytelling and creative writing capabilities make Claude more versatile for content creators.",
    category: "claude",
    date: "2024-12-11",
    link: "#"
  },
  {
    id: 6,
    title: "AI Safety Research Makes Progress on Alignment",
    summary: "New techniques for ensuring AI systems behave according to human values show promising results.",
    category: "llm",
    date: "2024-12-10",
    link: "#"
  }
];

function loadAINews() {
  console.log('Loading AI News...');
  var container = document.getElementById('news-container');
  var loadingStatus = document.getElementById('loading-status');
  
  if (!container) return;
  
  // Simulate loading delay
  setTimeout(function() {
    container.innerHTML = '';
    
    aiNewsData.forEach(function(news) {
      var newsCard = document.createElement('div');
      newsCard.className = 'news-card ' + news.category;
      newsCard.setAttribute('data-category', news.category);
      
      newsCard.innerHTML = 
        '<div class="news-category">' + news.category.toUpperCase() + '</div>' +
        '<h3>' + news.title + '</h3>' +
        '<div class="news-date">📅 ' + news.date + '</div>' +
        '<p>' + news.summary + '</p>' +
        '<a href="' + news.link + '" class="news-link">Read More →</a>';
      
      container.appendChild(newsCard);
    });
    
    if (loadingStatus) {
      loadingStatus.textContent = '✅ Latest AI news loaded successfully!';
    }
    
    console.log('AI News loaded successfully!');
  }, 1000);
}

function filterNews(category) {
  console.log('Filtering news by category:', category);
  
  // Update active filter button
  var filterButtons = document.querySelectorAll('.filter-btn');
  filterButtons.forEach(function(btn) {
    btn.classList.remove('active');
  });
  
  event.target.classList.add('active');
  
  // Filter news cards
  var newsCards = document.querySelectorAll('.news-card');
  newsCards.forEach(function(card) {
    if (category === 'all' || card.getAttribute('data-category') === category) {
      card.classList.remove('hidden');
    } else {
      card.classList.add('hidden');
    }
  });
}

function refreshNews() {
  console.log('Refreshing AI News...');
  var loadingStatus = document.getElementById('loading-status');
  
  if (loadingStatus) {
    loadingStatus.textContent = '🔄 Refreshing AI news...';
  }
  
  // Simulate refresh
  setTimeout(function() {
    loadAINews();
  }, 500);
}

// Load AI news when page loads
document.addEventListener('DOMContentLoaded', function() {
  if (window.location.pathname === '/ai-news') {
    loadAINews();
  }
});