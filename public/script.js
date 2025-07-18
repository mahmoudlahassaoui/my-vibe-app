// 🎮 Amazing Vibe.d App - Interactive Features
console.log('🎮 Script loaded!');

// Game state
var gameState = {
    sequence: [],
    playerSequence: [],
    level: 0,
    score: 0,
    isPlaying: false,
    isShowingSequence: false
};

// Sound effects using Web Audio API
var audioContext;
var sounds = {
    red: 261.63,    // C4
    blue: 329.63,   // E4
    green: 392.00,  // G4
    yellow: 523.25, // C5
    success: 659.25, // E5
    fail: 146.83    // D3
};

// Initialize audio context
function initAudio() {
    try {
        // Check for AudioContext support
        if (window.AudioContext) {
            audioContext = new window.AudioContext();
            console.log('🔊 Audio context created with AudioContext:', audioContext.state);
        } else if (window.webkitAudioContext) {
            audioContext = new window.webkitAudioContext();
            console.log('🔊 Audio context created with webkitAudioContext:', audioContext.state);
        } else {
            console.log('🔇 Web Audio API not supported');
            return;
        }

        // Resume audio context if suspended (required by some browsers)
        if (audioContext.state === 'suspended') {
            console.log('🔄 Audio context is suspended, will resume on user interaction');
        }

        console.log('🔊 Audio initialized successfully, state:', audioContext.state);
    } catch (e) {
        console.log('🔇 Audio initialization failed:', e);
    }
}

// Play sound with frequency
function playSoundEffect(frequency, duration = 300) {
    console.log('🎵 Attempting to play sound:', frequency, 'Hz for', duration, 'ms');

    if (!audioContext) {
        console.log('🔧 Audio context not initialized, initializing...');
        initAudio();
    }

    if (!audioContext) {
        console.log('❌ Audio context still not available');
        return;
    }

    if (audioContext.state === 'suspended') {
        console.log('🔄 Audio context suspended, resuming...');
        audioContext.resume().then(function () {
            console.log('✅ Audio context resumed');
            playTone(frequency, duration);
        });
    } else {
        playTone(frequency, duration);
    }
}

function playTone(frequency, duration) {
    try {
        var oscillator = audioContext.createOscillator();
        var gainNode = audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);

        oscillator.frequency.value = frequency;
        oscillator.type = 'sine';

        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration / 1000);

        oscillator.start(audioContext.currentTime);
        oscillator.stop(audioContext.currentTime + duration / 1000);

        console.log('✅ Sound played successfully:', frequency, 'Hz');
    } catch (e) {
        console.log('🔇 Audio playback failed:', e);
    }
}

// Enhanced background color change with animations
function changeBackgroundColor() {
    console.log('🎨 Button clicked!');

    // Initialize audio on first user interaction
    if (!audioContext) {
        initAudio();
    }

    var colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];
    var randomColor = colors[Math.floor(Math.random() * colors.length)];

    // Add spinning animation to button
    var button = document.querySelector('.color-btn');
    if (button) {
        button.style.transform = 'rotate(360deg) scale(1.1)';
        setTimeout(function () {
            button.style.transform = 'rotate(0deg) scale(1)';
        }, 600);
    }

    // Smooth color transition
    document.body.style.transition = 'background-color 0.8s ease-in-out';
    document.body.style.backgroundColor = randomColor;

    // Create confetti effect
    createConfetti();

    // Play success sound
    playSoundEffect(sounds.success, 200);

    // Update debug text with animation
    var debugInfo = document.getElementById('debug-info');
    if (debugInfo) {
        debugInfo.style.opacity = '0';
        setTimeout(function () {
            debugInfo.textContent = '✨ Background changed to: ' + randomColor + ' ✨';
            debugInfo.style.color = 'white';
            debugInfo.style.textShadow = '2px 2px 4px rgba(0,0,0,0.5)';
            debugInfo.style.opacity = '1';
        }, 200);
    }

    localStorage.setItem('vibeAppBackgroundColor', randomColor);
    console.log('✅ Background changed to:', randomColor);
}

// Create confetti animation
function createConfetti() {
    var colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];

    for (var i = 0; i < 50; i++) {
        setTimeout(function () {
            var confetti = document.createElement('div');
            confetti.style.position = 'fixed';
            confetti.style.left = Math.random() * 100 + 'vw';
            confetti.style.top = '-10px';
            confetti.style.width = '10px';
            confetti.style.height = '10px';
            confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.borderRadius = '50%';
            confetti.style.pointerEvents = 'none';
            confetti.style.zIndex = '9999';
            confetti.style.animation = 'confetti-fall 3s linear forwards';

            document.body.appendChild(confetti);

            setTimeout(function () {
                if (confetti.parentNode) {
                    confetti.parentNode.removeChild(confetti);
                }
            }, 3000);
        }, i * 50);
    }
}

// Enhanced palette application with animations
function applyPalette(name) {
    console.log('🎨 Applying palette:', name);

    // Initialize audio on first user interaction
    if (!audioContext) {
        initAudio();
    }

    var palettes = {
        sunset: {
            bg: '#ff6b6b',
            colors: ['#ff6b6b', '#ffa726', '#ffcc02']
        },
        ocean: {
            bg: '#4ecdc4',
            colors: ['#4ecdc4', '#45b7d1', '#96ceb4']
        },
        forest: {
            bg: '#98fb98',
            colors: ['#98fb98', '#90ee90', '#8fbc8f']
        },
        royal: {
            bg: '#667eea',
            colors: ['#667eea', '#764ba2', '#dda0dd']
        }
    };

    if (palettes[name]) {
        // Animate palette selection
        var paletteOption = document.querySelector('.palette-option[onclick*="' + name + '"]');
        if (paletteOption) {
            paletteOption.style.transform = 'scale(1.2) rotate(5deg)';
            setTimeout(function () {
                paletteOption.style.transform = 'scale(1) rotate(0deg)';
            }, 300);
        }

        // Apply background with transition
        document.body.style.transition = 'background-color 1s ease-in-out';
        document.body.style.backgroundColor = palettes[name].bg;

        // Create palette-specific effects
        createPaletteEffect(palettes[name].colors);

        // Play palette sound
        playSoundEffect(sounds.success + (Math.random() * 100 - 50), 400);

        localStorage.setItem('vibeAppBackgroundColor', palettes[name].bg);
        console.log('✅ Palette applied:', name, palettes[name].bg);
    }
}

// Create palette-specific visual effects
function createPaletteEffect(colors) {
    for (var i = 0; i < 20; i++) {
        setTimeout(function () {
            var effect = document.createElement('div');
            effect.style.position = 'fixed';
            effect.style.left = Math.random() * 100 + 'vw';
            effect.style.top = Math.random() * 100 + 'vh';
            effect.style.width = '20px';
            effect.style.height = '20px';
            effect.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            effect.style.borderRadius = '50%';
            effect.style.pointerEvents = 'none';
            effect.style.zIndex = '9998';
            effect.style.opacity = '0.8';
            effect.style.animation = 'pulse-fade 2s ease-out forwards';

            document.body.appendChild(effect);

            setTimeout(function () {
                if (effect.parentNode) {
                    effect.parentNode.removeChild(effect);
                }
            }, 2000);
        }, i * 100);
    }
}

// 🎮 MEMORY GAME IMPLEMENTATION
function startGame() {
    console.log('🎮 Game starting...');

    // Initialize audio on first interaction
    if (!audioContext) {
        initAudio();
    }

    // Reset game state
    gameState = {
        sequence: [],
        playerSequence: [],
        level: 0,
        score: 0,
        isPlaying: true,
        isShowingSequence: false
    };

    // Update UI
    updateGameScore();

    // Animate start button
    var startBtn = document.querySelector('.game-btn');
    if (startBtn) {
        startBtn.style.transform = 'scale(0.9)';
        startBtn.textContent = 'Playing...';
        startBtn.disabled = true;
        setTimeout(function () {
            startBtn.style.transform = 'scale(1)';
        }, 200);
    }

    // Start first level
    setTimeout(function () {
        nextLevel();
    }, 1000);
}

function nextLevel() {
    gameState.level++;
    gameState.playerSequence = [];

    // Add new color to sequence
    var colors = ['red', 'blue', 'green', 'yellow'];
    var randomColor = colors[Math.floor(Math.random() * colors.length)];
    gameState.sequence.push(randomColor);

    console.log('🎯 Level ' + gameState.level + ', Sequence:', gameState.sequence);

    // Update score display
    updateGameScore();

    // Show sequence to player
    showSequence();
}

function showSequence() {
    gameState.isShowingSequence = true;
    var delay = 0;

    gameState.sequence.forEach(function (color, index) {
        setTimeout(function () {
            flashTile(color, true);
        }, delay);
        delay += 800;
    });

    // Allow player input after sequence is shown
    setTimeout(function () {
        gameState.isShowingSequence = false;
        console.log('👆 Your turn! Click the sequence...');
    }, delay + 500);
}

function flashTile(color, shouldPlaySound = false) {
    var tile = document.querySelector('.color-tile[data-color="' + color + '"]');
    if (!tile) {
        console.log('❌ Tile not found for color:', color);
        return;
    }

    console.log('🎯 Flashing tile:', color, 'with sound:', shouldPlaySound);

    // Visual flash effect
    tile.style.transform = 'scale(1.1)';
    tile.style.boxShadow = '0 0 30px rgba(255,255,255,0.9)';
    tile.style.filter = 'brightness(1.5)';

    // Play sound
    if (shouldPlaySound && sounds[color]) {
        console.log('🔊 Playing sound for:', color, 'frequency:', sounds[color]);
        playSoundEffect(sounds[color], 400);
    }

    // Reset after flash
    setTimeout(function () {
        tile.style.transform = 'scale(1)';
        tile.style.boxShadow = '';
        tile.style.filter = 'brightness(1)';
    }, 400);
}

function gameClick(color) {
    if (!gameState.isPlaying || gameState.isShowingSequence) {
        console.log('🚫 Game click ignored - isPlaying:', gameState.isPlaying, 'isShowingSequence:', gameState.isShowingSequence);
        return;
    }

    console.log('🎯 Player clicked:', color);

    // Initialize audio on first game interaction
    if (!audioContext) {
        console.log('🔧 Initializing audio for game click...');
        initAudio();
    }

    // Add to player sequence
    gameState.playerSequence.push(color);

    // Flash the clicked tile with sound
    flashTile(color, true);

    // Check if correct
    var currentIndex = gameState.playerSequence.length - 1;
    if (gameState.playerSequence[currentIndex] !== gameState.sequence[currentIndex]) {
        // Wrong! Game over
        gameOver();
        return;
    }

    // Check if sequence complete
    if (gameState.playerSequence.length === gameState.sequence.length) {
        // Level complete!
        gameState.score += gameState.level * 10;
        updateGameScore();

        // Celebrate
        setTimeout(function () {
            createConfetti();
            playSoundEffect(sounds.success, 600);

            // Next level after celebration
            setTimeout(function () {
                nextLevel();
            }, 1500);
        }, 500);
    }
}

function gameOver() {
    console.log('💥 Game Over! Final Score:', gameState.score);
    gameState.isPlaying = false;

    // Play fail sound
    playSoundEffect(sounds.fail, 800);

    // Flash all tiles red
    var tiles = document.querySelectorAll('.color-tile');
    tiles.forEach(function (tile) {
        tile.style.backgroundColor = '#ff4444';
        tile.style.animation = 'shake 0.5s ease-in-out';
    });

    // Reset tiles after animation
    setTimeout(function () {
        resetTileColors();
    }, 1000);

    // Update UI
    var startBtn = document.querySelector('.game-btn');
    if (startBtn) {
        startBtn.textContent = 'Game Over! Play Again?';
        startBtn.disabled = false;
    }

    // Show final score
    setTimeout(function () {
        alert('🎮 Game Over!\n\nFinal Score: ' + gameState.score + '\nLevel Reached: ' + gameState.level + '\n\nGreat job! 🎉');
    }, 1000);
}

function resetTileColors() {
    var tiles = document.querySelectorAll('.color-tile');
    tiles.forEach(function (tile) {
        var color = tile.getAttribute('data-color');
        var colors = {
            red: '#ff6b6b',
            blue: '#4ecdc4',
            green: '#98fb98',
            yellow: '#ffd93d'
        };
        tile.style.backgroundColor = colors[color];
        tile.style.animation = '';
    });
}

function updateGameScore() {
    var scoreElement = document.getElementById('game-score');
    if (scoreElement) {
        scoreElement.textContent = 'Score: ' + gameState.score + ' | Level: ' + gameState.level;

        // Animate score update
        scoreElement.style.transform = 'scale(1.1)';
        setTimeout(function () {
            scoreElement.style.transform = 'scale(1)';
        }, 200);
    }
}

// Load saved background color when page loads
document.addEventListener('DOMContentLoaded', function () {
    console.log('🚀 DOM loaded');

    // Restore saved background color with smooth transition
    var savedColor = localStorage.getItem('vibeAppBackgroundColor');
    if (savedColor) {
        document.body.style.transition = 'background-color 1s ease-in-out';
        document.body.style.backgroundColor = savedColor;
        console.log('🎨 Restored background color:', savedColor);
    }

    // Add welcome animation
    setTimeout(function () {
        var container = document.querySelector('.container');
        if (container) {
            container.style.opacity = '0';
            container.style.transform = 'translateY(20px)';
            container.style.transition = 'all 0.8s ease-out';

            setTimeout(function () {
                container.style.opacity = '1';
                container.style.transform = 'translateY(0)';
            }, 100);
        }
    }, 200);

    console.log('✅ App initialized');
});

// Enhanced AI News functionality
function loadAINews() {
    console.log('📰 Loading AI News from RSS feeds... (Cache bust: ' + Date.now() + ')');

    var container = document.getElementById('news-container');
    var loadingStatus = document.getElementById('loading-status');

    if (!container) {
        console.log('❌ News container not found');
        return;
    }

    // Show loading animation
    if (loadingStatus) {
        loadingStatus.innerHTML = '🔄 Loading latest AI news from RSS feeds...';
        loadingStatus.style.animation = 'pulse 1.5s infinite';
    }

    // Fetch real RSS news from backend
    fetch('/api/rss-news')
        .then(function(response) {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(function(news) {
            console.log('✅ RSS News loaded:', news.length, 'articles');
            displayNews(news, container, loadingStatus);
        })
        .catch(function(error) {
            console.log('❌ RSS fetch failed, using fallback news:', error);
            loadFallbackNews(container, loadingStatus);
        });
}

function displayNews(news, container, loadingStatus) {
    container.innerHTML = '';
    
    // Add news cards with staggered animation
    news.forEach(function(item, index) {
        setTimeout(function() {
            var newsCard = document.createElement('div');
            newsCard.className = 'news-card ' + (item.category || 'tech');
            newsCard.style.opacity = '0';
            newsCard.style.transform = 'translateY(20px)';
            newsCard.style.cursor = 'pointer';
            newsCard.innerHTML = 
                '<div class="news-content">' +
                    '<h3>' + item.title + ' <span class="clickable-indicator">👆</span></h3>' +
                    '<p class="news-summary">' + (item.summary || 'Click to read more...') + '</p>' +
                    '<div class="news-footer">' +
                        '<p class="news-date">📅 ' + (item.date || 'Recent') + ' | 🏷️ ' + (item.category || 'TECH').toUpperCase() + '</p>' +
                        '<p class="news-source">📰 Source: ' + (item.source || 'AI News') + ' | 🔗 <span class="click-hint">Click to read more</span></p>' +
                    '</div>' +
                '</div>' +
                '<div class="news-external-icon">🔗</div>';
            
            // Add click handler
            newsCard.addEventListener('click', function(e) {
                e.preventDefault();
                console.log('📰 Opening news article:', item.title);
                console.log('🔗 URL:', item.url);
                
                // Add visual feedback
                newsCard.style.transform = 'translateY(-4px) scale(1.01)';
                newsCard.style.transition = 'all 0.2s ease';
                
                setTimeout(function() {
                    // Open link in same tab to avoid tab issues
                    try {
                        console.log('🔗 Opening:', item.url);
                        window.location.href = item.url;
                    } catch (error) {
                        console.error('❌ Error opening URL:', error);
                        alert('Unable to open link: ' + item.url);
                    }
                }, 200);
            });
            
            // Add hover effects
            newsCard.addEventListener('mouseenter', function() {
                var clickHint = newsCard.querySelector('.click-hint');
                if (clickHint) {
                    clickHint.style.animation = 'pulse 1s infinite';
                }
            });
            
            newsCard.addEventListener('mouseleave', function() {
                var clickHint = newsCard.querySelector('.click-hint');
                if (clickHint) {
                    clickHint.style.animation = '';
                }
            });
            
            container.appendChild(newsCard);
            
            // Animate in
            setTimeout(function() {
                newsCard.style.transition = 'all 0.5s ease-out';
                newsCard.style.opacity = '1';
                newsCard.style.transform = 'translateY(0)';
            }, 50);
            
        }, index * 150);
    });
    
    // Hide loading status
    if (loadingStatus) {
        setTimeout(function() {
            loadingStatus.style.opacity = '0';
            setTimeout(function() {
                loadingStatus.style.display = 'none';
            }, 300);
        }, news.length * 150 + 500);
    }
}

function loadFallbackNews(container, loadingStatus) {
    // Simple fallback news when RSS fails
    var news = [
        {
            title: 'AI News Feed Temporarily Unavailable',
            category: 'tech',
            date: new Date().toISOString().split('T')[0],
            summary: 'We are experiencing issues loading the latest AI news. Please try refreshing the page.',
            url: 'https://www.artificialintelligence-news.com/',
            source: 'AI News'
        },
        {
            title: 'Visit TechCrunch AI for Latest Updates',
            category: 'tech',
            date: new Date().toISOString().split('T')[0],
            summary: 'Stay updated with the latest AI developments and breakthroughs.',
            url: 'https://techcrunch.com/category/artificial-intelligence/',
            source: 'TechCrunch'
        },
        {
            title: 'Explore VentureBeat AI Coverage',
            category: 'tech',
            date: new Date().toISOString().split('T')[0],
            summary: 'Comprehensive coverage of AI industry news and analysis.',
            url: 'https://venturebeat.com/ai/',
            source: 'VentureBeat'
        }
    ];
    
    displayNews(news, container, loadingStatus);
            {
                title: 'Claude 3.5 Sonnet Computer Use Feature Expansion',
                category: 'claude',
                date: '2025-07-17',
                summary: 'Anthropic expands Claude\'s computer use capabilities with improved screen interaction and automation features for developers.',
                url: 'https://www.anthropic.com/',
                source: 'Anthropic'
            },
            {
                title: 'OpenAI Announces GPT-5 Development Progress',
                category: 'chatgpt',
                date: '2025-07-16',
                summary: 'OpenAI shares updates on GPT-5 development, highlighting significant improvements in reasoning and multimodal capabilities.',
                url: 'https://openai.com/',
                source: 'OpenAI'
            },
            {
                title: 'New Transformer Architecture Reduces Training Costs by 40%',
                category: 'llm',
                date: '2025-07-15',
                summary: 'Researchers publish breakthrough paper on efficient transformer architecture that dramatically reduces computational requirements.',
                url: 'https://arxiv.org/',
                source: 'arXiv'
            },
            {
                title: 'EU AI Act Implementation Guidelines Released',
                category: 'tech',
                date: '2025-07-14',
                summary: 'European Union publishes comprehensive guidelines for AI Act compliance, affecting major tech companies globally.',
                url: 'https://digital-strategy.ec.europa.eu/en/policies/european-approach-artificial-intelligence',
                source: 'European Commission'
            },
            {
                title: 'Claude API Rate Limits Increased for Enterprise Users',
                category: 'claude',
                date: '2025-07-13',
                summary: 'Anthropic announces significant rate limit increases and new enterprise features for Claude API customers.',
                url: 'https://docs.anthropic.com/',
                source: 'Anthropic Docs'
            },
            {
                title: 'ChatGPT Canvas Mode Gets Real-Time Collaboration',
                category: 'chatgpt',
                date: '2025-07-12',
                summary: 'OpenAI introduces real-time collaboration features in ChatGPT Canvas, enabling multiple users to work together.',
                url: 'https://openai.com/chatgpt/',
                source: 'OpenAI Blog'
            },
            {
                title: 'Google Gemini 2.0 Multimodal Capabilities Unveiled',
                category: 'tech',
                date: '2025-07-11',
                summary: 'Google demonstrates Gemini 2.0\'s advanced multimodal understanding with live video processing and real-time analysis.',
                url: 'https://gemini.google.com/',
                source: 'Google AI'
            },
            {
                title: 'Microsoft Copilot Studio Launches AI Agent Builder',
                category: 'tech',
                date: '2025-07-12',
                summary: 'Microsoft releases new tools for building custom AI agents within Copilot Studio, targeting enterprise automation.',
                url: 'https://www.microsoft.com/en-us/microsoft-copilot/',
                source: 'Microsoft'
            }
        ];

        // Debug: Log the dates being used
        console.log('📅 News dates loaded:', news.map(function (item) { return item.date; }));
        console.log('✅ AI News v2.0 loaded successfully with current week dates!');

        container.innerHTML = '';

        // Add news cards with staggered animation
        news.forEach(function (item, index) {
            setTimeout(function () {
                var newsCard = document.createElement('div');
                newsCard.className = 'news-card ' + item.category;
                newsCard.style.opacity = '0';
                newsCard.style.transform = 'translateY(20px)';
                newsCard.style.cursor = 'pointer';
                newsCard.innerHTML =
                    '<div class="news-content">' +
                    '<h3>' + item.title + ' <span class="clickable-indicator">👆</span></h3>' +
                    '<p class="news-summary">' + item.summary + '</p>' +
                    '<div class="news-footer">' +
                    '<p class="news-date">📅 ' + item.date + ' | 🏷️ ' + item.category.toUpperCase() + '</p>' +
                    '<p class="news-source">📰 Source: ' + item.source + ' | 🔗 <span class="click-hint">Click anywhere to read more</span></p>' +
                    '</div>' +
                    '</div>' +
                    '<div class="news-external-icon">🔗</div>';

                // Add click handler to open the news source
                newsCard.addEventListener('click', function (e) {
                    e.preventDefault();
                    console.log('📰 Opening news article:', item.title);
                    console.log('🔗 URL:', item.url);

                    // Add visual feedback for click
                    newsCard.style.transform = 'translateY(-4px) scale(1.01)';
                    newsCard.style.transition = 'all 0.2s ease';

                    setTimeout(function () {
                        newsCard.style.transform = 'translateY(-8px) scale(1.02)';
                    }, 100);

                    // Reset transform after a moment
                    setTimeout(function () {
                        newsCard.style.transform = 'translateY(-8px) scale(1.02)';
                    }, 300);

                    // Open link in same tab to avoid tab issues
                    try {
                        console.log('🔗 Opening:', item.url);
                        window.location.href = item.url;
                    } catch (error) {
                        console.error('❌ Error opening URL:', error);
                        alert('Unable to open link: ' + item.url);
                    }
                });

                // Add hover effect for better UX
                newsCard.addEventListener('mouseenter', function () {
                    var clickHint = newsCard.querySelector('.click-hint');
                    if (clickHint) {
                        clickHint.style.animation = 'pulse 1s infinite';
                    }
                });

                newsCard.addEventListener('mouseleave', function () {
                    var clickHint = newsCard.querySelector('.click-hint');
                    if (clickHint) {
                        clickHint.style.animation = '';
                    }
                });

                container.appendChild(newsCard);

                // Animate in
                setTimeout(function () {
                    newsCard.style.transition = 'all 0.5s ease-out';
                    newsCard.style.opacity = '1';
                    newsCard.style.transform = 'translateY(0)';
                }, 50);

            }, index * 150);
        });

        // Hide loading status
        if (loadingStatus) {
            setTimeout(function () {
                loadingStatus.style.opacity = '0';
                setTimeout(function () {
                    loadingStatus.style.display = 'none';
                }, 300);
            }, news.length * 150 + 500);
        }

        console.log('✅ News loaded with animations');
    }, 1000);
}

function filterNews(category) {
    console.log('🔍 Filtering news:', category);

    // Update active filter button
    var filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(function (btn) {
        btn.classList.remove('active');
        if (btn.textContent.toLowerCase().includes(category) ||
            (category === 'all' && btn.textContent.includes('All'))) {
            btn.classList.add('active');
        }
    });

    // Filter cards with animation
    var cards = document.querySelectorAll('.news-card');
    cards.forEach(function (card, index) {
        setTimeout(function () {
            if (category === 'all' || card.classList.contains(category)) {
                card.style.display = 'block';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.8)';
                setTimeout(function () {
                    card.style.transition = 'all 0.3s ease-out';
                    card.style.opacity = '1';
                    card.style.transform = 'scale(1)';
                }, 50);
            } else {
                card.style.transition = 'all 0.3s ease-out';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.8)';
                setTimeout(function () {
                    card.style.display = 'none';
                }, 300);
            }
        }, index * 50);
    });
}

function refreshNews() {
    console.log('🔄 Refreshing news...');

    // Animate refresh button
    var refreshBtn = document.querySelector('.refresh-btn');
    if (refreshBtn) {
        refreshBtn.style.transform = 'rotate(360deg)';
        refreshBtn.disabled = true;
        setTimeout(function () {
            refreshBtn.style.transform = 'rotate(0deg)';
            refreshBtn.disabled = false;
        }, 1000);
    }

    // Show loading status again
    var loadingStatus = document.getElementById('loading-status');
    if (loadingStatus) {
        loadingStatus.style.display = 'block';
        loadingStatus.style.opacity = '1';
    }

    // Clear current news with animation
    var cards = document.querySelectorAll('.news-card');
    cards.forEach(function (card, index) {
        setTimeout(function () {
            card.style.transition = 'all 0.3s ease-out';
            card.style.opacity = '0';
            card.style.transform = 'translateX(-20px)';
        }, index * 50);
    });

    // Reload news after animation
    setTimeout(function () {
        loadAINews();
    }, cards.length * 50 + 300);
}

// Test function to verify news card clicks are working
function testNewsClick() {
    console.log('🧪 Testing news card click functionality...');
    var newsCards = document.querySelectorAll('.news-card');
    if (newsCards.length > 0) {
        console.log('✅ Found', newsCards.length, 'news cards');
        newsCards[0].click();
        console.log('🔄 Triggered click on first news card');
    } else {
        console.log('❌ No news cards found');
    }
}

// Auto-load news on AI news page with enhanced loading
if (window.location.pathname === '/ai-news') {
    document.addEventListener('DOMContentLoaded', function () {
        setTimeout(function () {
            loadAINews();
            // Add test button for debugging (remove in production)
            setTimeout(function () {
                console.log('🔧 Debug: You can test news clicks by running testNewsClick() in console');
            }, 2000);
        }, 800);
    });
}