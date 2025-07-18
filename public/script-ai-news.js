// Clean AI News System - Built from scratch with RSS feeds

function loadAINews() {
    console.log('📰 Loading AI news from RSS feeds...');
    
    const container = document.getElementById('news-container');
    const loadingStatus = document.getElementById('loading-status');
    
    if (!container) {
        console.error('❌ News container not found');
        return;
    }
    
    // Show loading
    showLoading(loadingStatus);
    container.innerHTML = '';
    
    // Fetch real RSS news
    fetch('/api/rss-news')
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }
            return response.json();
        })
        .then(newsData => {
            console.log('✅ Loaded', newsData.length, 'articles');
            hideLoading(loadingStatus);
            renderNewsCards(newsData, container);
        })
        .catch(error => {
            console.error('❌ Failed to load RSS news:', error);
            hideLoading(loadingStatus);
            showErrorMessage(container);
        });
}

function showLoading(loadingStatus) {
    if (loadingStatus) {
        loadingStatus.innerHTML = '🔄 Loading latest AI news...';
        loadingStatus.style.display = 'block';
        loadingStatus.style.opacity = '1';
    }
}

function hideLoading(loadingStatus) {
    if (loadingStatus) {
        loadingStatus.style.opacity = '0';
        setTimeout(() => {
            loadingStatus.style.display = 'none';
        }, 300);
    }
}

function renderNewsCards(newsData, container) {
    newsData.forEach((article, index) => {
        setTimeout(() => {
            const card = createNewsCard(article);
            container.appendChild(card);
            
            // Animate in
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, 50);
        }, index * 100);
    });
}

function createNewsCard(article) {
    const card = document.createElement('div');
    card.className = 'news-card';
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'all 0.3s ease';
    card.style.cursor = 'pointer';
    
    const title = article.title || 'Untitled';
    const summary = article.summary || article.description || 'Click to read more...';
    const date = formatDate(article.date || article.pubDate);
    const source = article.source || 'AI News';
    const url = article.url || article.link;
    
    card.innerHTML = `
        <div class="news-content">
            <h3>${title}</h3>
            <p class="news-summary">${summary}</p>
            <div class="news-footer">
                <p class="news-date">📅 ${date}</p>
                <p class="news-source">📰 ${source} | 🔗 Click to read</p>
            </div>
        </div>
        <div class="news-external-icon">🔗</div>
    `;
    
    // Add click handler
    card.addEventListener('click', () => {
        if (url) {
            console.log('🔗 Opening:', url);
            window.open(url, '_blank', 'noopener,noreferrer');
        }
    });
    
    // Hover effects
    card.addEventListener('mouseenter', () => {
        card.style.transform = 'translateY(-5px)';
        card.style.boxShadow = '0 10px 25px rgba(0,0,0,0.15)';
    });
    
    card.addEventListener('mouseleave', () => {
        card.style.transform = 'translateY(0)';
        card.style.boxShadow = '0 5px 15px rgba(0,0,0,0.1)';
    });
    
    return card;
}

function formatDate(dateString) {
    if (!dateString) return 'Recent';
    
    try {
        const date = new Date(dateString);
        const now = new Date();
        const diffTime = Math.abs(now - date);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays === 1) return 'Yesterday';
        if (diffDays < 7) return `${diffDays} days ago`;
        
        return date.toLocaleDateString();
    } catch (e) {
        return 'Recent';
    }
}

function showErrorMessage(container) {
    container.innerHTML = `
        <div class="error-message" style="text-align: center; padding: 40px; color: #666;">
            <h3>⚠️ Unable to load news</h3>
            <p>We're having trouble fetching the latest AI news.</p>
            <button onclick="loadAINews()" style="margin-top: 20px; padding: 10px 20px; background: #007acc; color: white; border: none; border-radius: 5px; cursor: pointer;">
                🔄 Try Again
            </button>
        </div>
    `;
}

function refreshNews() {
    console.log('🔄 Refreshing news...');
    loadAINews();
}

function filterNews(category) {
    console.log('🔍 Filtering by:', category);
    const cards = document.querySelectorAll('.news-card');
    
    cards.forEach(card => {
        if (category === 'all') {
            card.style.display = 'block';
        } else {
            // Simple filtering - you can enhance this based on your needs
            const content = card.textContent.toLowerCase();
            const shouldShow = content.includes(category.toLowerCase());
            card.style.display = shouldShow ? 'block' : 'none';
        }
    });
}

// Auto-load news when page loads
if (window.location.pathname === '/ai-news') {
    document.addEventListener('DOMContentLoaded', () => {
        setTimeout(loadAINews, 500);
    });
}