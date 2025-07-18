// Simple test to see if JavaScript is working
console.log('🎮 Script loaded!');

// Test function - simple background color change
function changeBackgroundColor() {
    console.log('🎨 Button clicked!');
    
    // Simple color array
    var colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];
    var randomColor = colors[Math.floor(Math.random() * colors.length)];
    
    // Change background
    document.body.style.backgroundColor = randomColor;
    
    // Update debug text
    var debugInfo = document.getElementById('debug-info');
    if (debugInfo) {
        debugInfo.textContent = 'Background changed to: ' + randomColor;
        debugInfo.style.color = 'white';
    }
    
    // Save to localStorage
    localStorage.setItem('vibeAppBackgroundColor', randomColor);
    
    console.log('✅ Background changed to:', randomColor);
}

// Test function - simple palette application
function applyPalette(name) {
    console.log('🎨 Applying palette:', name);
    
    var colors = {
        sunset: '#ff6b6b',
        ocean: '#4ecdc4', 
        forest: '#98fb98',
        royal: '#667eea'
    };
    
    if (colors[name]) {
        document.body.style.backgroundColor = colors[name];
        localStorage.setItem('vibeAppBackgroundColor', colors[name]);
        console.log('✅ Palette applied:', name, colors[name]);
    }
}

// Test function - simple game start
function startGame() {
    console.log('🎮 Game starting...');
    alert('Game started! (This is a test - full game coming next)');
}

// Test function - simple game click
function gameClick(color) {
    console.log('🎯 Game tile clicked:', color);
    
    // Flash the clicked tile
    var tile = document.querySelector('.color-tile[data-color="' + color + '"]');
    if (tile) {
        tile.style.transform = 'scale(1.1)';
        tile.style.boxShadow = '0 0 20px rgba(255,255,255,0.8)';
        
        setTimeout(function() {
            tile.style.transform = 'scale(1)';
            tile.style.boxShadow = '';
        }, 200);
    }
    
    alert('You clicked: ' + color);
}

// Load saved background color when page loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOM loaded');
    
    // Restore saved background color
    var savedColor = localStorage.getItem('vibeAppBackgroundColor');
    if (savedColor) {
        document.body.style.backgroundColor = savedColor;
        console.log('🎨 Restored background color:', savedColor);
    }
    
    console.log('✅ App initialized');
});

// AI News functionality (simplified)
function loadAINews() {
    console.log('📰 Loading AI News...');
    
    var container = document.getElementById('news-container');
    if (!container) {
        console.log('❌ News container not found');
        return;
    }
    
    // Simple news data
    var news = [
        { title: 'Claude 3.5 Sonnet Update', category: 'claude', date: '2024-12-15' },
        { title: 'ChatGPT-4 Improvements', category: 'chatgpt', date: '2024-12-14' },
        { title: 'New LLM Research', category: 'llm', date: '2024-12-13' }
    ];
    
    container.innerHTML = '';
    
    news.forEach(function(item) {
        var newsCard = document.createElement('div');
        newsCard.className = 'news-card ' + item.category;
        newsCard.innerHTML = '<h3>' + item.title + '</h3><p>Date: ' + item.date + '</p>';
        container.appendChild(newsCard);
    });
    
    console.log('✅ News loaded');
}

function filterNews(category) {
    console.log('🔍 Filtering news:', category);
    // Simple filter implementation
    var cards = document.querySelectorAll('.news-card');
    cards.forEach(function(card) {
        if (category === 'all' || card.classList.contains(category)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

function refreshNews() {
    console.log('🔄 Refreshing news...');
    loadAINews();
}

// Auto-load news on AI news page
if (window.location.pathname === '/ai-news') {
    document.addEventListener('DOMContentLoaded', function() {
        setTimeout(loadAINews, 500);
    });
}