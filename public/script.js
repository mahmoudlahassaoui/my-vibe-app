// 🎮 Amazing Vibe.d App - Interactive Features (Clean Version)
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
        audioContext.resume().then(function() {
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
    
    if (!audioContext) {
        initAudio();
    }
    
    var colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];
    var randomColor = colors[Math.floor(Math.random() * colors.length)];
    
    var button = document.querySelector('.color-btn');
    if (button) {
        button.style.transform = 'rotate(360deg) scale(1.1)';
        setTimeout(function() {
            button.style.transform = 'rotate(0deg) scale(1)';
        }, 600);
    }
    
    document.body.style.transition = 'background-color 0.8s ease-in-out';
    document.body.style.backgroundColor = randomColor;
    
    createConfetti();
    playSoundEffect(sounds.success, 200);
    
    var debugInfo = document.getElementById('debug-info');
    if (debugInfo) {
        debugInfo.style.opacity = '0';
        setTimeout(function() {
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
        setTimeout(function() {
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
            
            setTimeout(function() {
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
        var paletteOption = document.querySelector('.palette-option[onclick*="' + name + '"]');
        if (paletteOption) {
            paletteOption.style.transform = 'scale(1.2) rotate(5deg)';
            setTimeout(function() {
                paletteOption.style.transform = 'scale(1) rotate(0deg)';
            }, 300);
        }
        
        document.body.style.transition = 'background-color 1s ease-in-out';
        document.body.style.backgroundColor = palettes[name].bg;
        
        createPaletteEffect(palettes[name].colors);
        playSoundEffect(sounds.success + (Math.random() * 100 - 50), 400);
        
        localStorage.setItem('vibeAppBackgroundColor', palettes[name].bg);
        console.log('✅ Palette applied:', name, palettes[name].bg);
    }
}

// Create palette-specific visual effects
function createPaletteEffect(colors) {
    for (var i = 0; i < 20; i++) {
        setTimeout(function() {
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
            
            setTimeout(function() {
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
    
    if (!audioContext) {
        initAudio();
    }
    
    gameState = {
        sequence: [],
        playerSequence: [],
        level: 0,
        score: 0,
        isPlaying: true,
        isShowingSequence: false
    };
    
    updateGameScore();
    
    var startBtn = document.querySelector('.game-btn');
    if (startBtn) {
        startBtn.style.transform = 'scale(0.9)';
        startBtn.textContent = 'Playing...';
        startBtn.disabled = true;
        setTimeout(function() {
            startBtn.style.transform = 'scale(1)';
        }, 200);
    }
    
    setTimeout(function() {
        nextLevel();
    }, 1000);
}

function nextLevel() {
    gameState.level++;
    gameState.playerSequence = [];
    
    var colors = ['red', 'blue', 'green', 'yellow'];
    var randomColor = colors[Math.floor(Math.random() * colors.length)];
    gameState.sequence.push(randomColor);
    
    console.log('🎯 Level ' + gameState.level + ', Sequence:', gameState.sequence);
    
    updateGameScore();
    showSequence();
}

function showSequence() {
    gameState.isShowingSequence = true;
    var delay = 0;
    
    gameState.sequence.forEach(function(color, index) {
        setTimeout(function() {
            flashTile(color, true);
        }, delay);
        delay += 800;
    });
    
    setTimeout(function() {
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
    
    tile.style.transform = 'scale(1.1)';
    tile.style.boxShadow = '0 0 30px rgba(255,255,255,0.9)';
    tile.style.filter = 'brightness(1.5)';
    
    if (shouldPlaySound && sounds[color]) {
        console.log('🔊 Playing sound for:', color, 'frequency:', sounds[color]);
        playSoundEffect(sounds[color], 400);
    }
    
    setTimeout(function() {
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
    
    if (!audioContext) {
        console.log('🔧 Initializing audio for game click...');
        initAudio();
    }
    
    gameState.playerSequence.push(color);
    flashTile(color, true);
    
    var currentIndex = gameState.playerSequence.length - 1;
    if (gameState.playerSequence[currentIndex] !== gameState.sequence[currentIndex]) {
        gameOver();
        return;
    }
    
    if (gameState.playerSequence.length === gameState.sequence.length) {
        gameState.score += gameState.level * 10;
        updateGameScore();
        
        setTimeout(function() {
            createConfetti();
            playSoundEffect(sounds.success, 600);
            
            setTimeout(function() {
                nextLevel();
            }, 1500);
        }, 500);
    }
}

function gameOver() {
    console.log('💥 Game Over! Final Score:', gameState.score);
    gameState.isPlaying = false;
    
    playSoundEffect(sounds.fail, 800);
    
    var tiles = document.querySelectorAll('.color-tile');
    tiles.forEach(function(tile) {
        tile.style.backgroundColor = '#ff4444';
        tile.style.animation = 'shake 0.5s ease-in-out';
    });
    
    setTimeout(function() {
        resetTileColors();
    }, 1000);
    
    var startBtn = document.querySelector('.game-btn');
    if (startBtn) {
        startBtn.textContent = 'Game Over! Play Again?';
        startBtn.disabled = false;
    }
    
    setTimeout(function() {
        alert('🎮 Game Over!\n\nFinal Score: ' + gameState.score + '\nLevel Reached: ' + gameState.level + '\n\nGreat job! 🎉');
    }, 1000);
}

function resetTileColors() {
    var tiles = document.querySelectorAll('.color-tile');
    tiles.forEach(function(tile) {
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
        
        scoreElement.style.transform = 'scale(1.1)';
        setTimeout(function() {
            scoreElement.style.transform = 'scale(1)';
        }, 200);
    }
}

// Load saved background color when page loads
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 DOM loaded');
    
    var savedColor = localStorage.getItem('vibeAppBackgroundColor');
    if (savedColor) {
        document.body.style.transition = 'background-color 1s ease-in-out';
        document.body.style.backgroundColor = savedColor;
        console.log('🎨 Restored background color:', savedColor);
    }
    
    setTimeout(function() {
        var container = document.querySelector('.container');
        if (container) {
            container.style.opacity = '0';
            container.style.transform = 'translateY(20px)';
            container.style.transition = 'all 0.8s ease-out';
            
            setTimeout(function() {
                container.style.opacity = '1';
                container.style.transform = 'translateY(0)';
            }, 100);
        }
    }, 200);
    
    console.log('✅ App initialized');
});