console.log('🚀 Script.js loaded successfully!');

// Apply saved color when page loads
document.addEventListener('DOMContentLoaded', function() {
  const savedColor = localStorage.getItem('vibeAppBackgroundColor');
  if (savedColor) {
    console.log('🎨 Applying saved color:', savedColor);
    document.body.style.backgroundColor = savedColor;
    document.body.style.transition = 'background-color 0.8s ease-in-out';
  }
});

function changeBackgroundColor() {
  console.log('🎯 Button clicked! Starting effects...');
  const debugInfo = document.getElementById('debug-info');
  
  const colors = [
    '#f5f5f5', '#e8f4fd', '#fff2e8', '#f0fff0', '#fff0f5', '#f0f8ff', '#fdf5e6', '#f5fffa',
    '#ffe4e1', '#e6e6fa', '#f0f8ff', '#ffefd5', '#f5deb3', '#dda0dd', '#98fb98', '#afeeee',
    '#ffd1dc', '#b0e0e6', '#ffb6c1', '#87ceeb', '#deb887', '#f0e68c', '#ffa07a', '#20b2aa'
  ];
  const button = document.querySelector('.color-btn');
  
  if (!button) {
    console.error('❌ Button not found!');
    if (debugInfo) debugInfo.textContent = 'ERROR: Button not found!';
    return;
  }
  
  const currentColor = document.body.style.backgroundColor || '#f5f5f5';
  let newColor;
  do {
    newColor = colors[Math.floor(Math.random() * colors.length)];
  } while (newColor === currentColor);
  
  console.log('🎨 Changing color to:', newColor);
  if (debugInfo) debugInfo.textContent = `Changing to: ${newColor}`;
  
  // Play sound effects!
  playClickSound();
  
  // Save the color choice to localStorage
  localStorage.setItem('vibeAppBackgroundColor', newColor);
  console.log('💾 Saved color to localStorage:', newColor);
  
  // Add smooth transition
  document.body.style.transition = 'background-color 0.8s ease-in-out';
  document.body.style.backgroundColor = newColor;
  
  // Button animation and text change
  console.log('🌀 Starting button animation...');
  button.style.transition = 'transform 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55)';
  button.style.transform = 'scale(1.2) rotate(360deg)';
  button.textContent = '🎨 AMAZING!';
  
  // Create floating particles effect
  console.log('🎆 Creating particles...');
  createParticles();
  
  // Play success sound after animation
  setTimeout(() => {
    playSuccessSound();
  }, 400);
  
  // Reset button after animation
  setTimeout(() => {
    console.log('🔄 Resetting button...');
    button.style.transform = '';
    button.textContent = 'Change Background Color!';
    if (debugInfo) debugInfo.textContent = 'Effects completed! Click again...';
  }, 800);
}

function playClickSound() {
  try {
    // Create a satisfying click sound using Web Audio API
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    
    // Resume audio context if suspended (required by browsers)
    if (audioContext.state === 'suspended') {
      audioContext.resume();
    }
    
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(400, audioContext.currentTime + 0.1);
    
    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);
    
    oscillator.start(audioContext.currentTime);
    oscillator.stop(audioContext.currentTime + 0.1);
  } catch (e) {
    console.log('Audio not supported or blocked');
  }
}

function playSuccessSound() {
  try {
    // Create a magical success sound
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    
    // Resume audio context if suspended
    if (audioContext.state === 'suspended') {
      audioContext.resume();
    }
    
    const oscillator1 = audioContext.createOscillator();
    const oscillator2 = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator1.connect(gainNode);
    oscillator2.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    // Create a magical chord
    oscillator1.frequency.setValueAtTime(523.25, audioContext.currentTime); // C5
    oscillator2.frequency.setValueAtTime(659.25, audioContext.currentTime); // E5
    
    oscillator1.frequency.exponentialRampToValueAtTime(783.99, audioContext.currentTime + 0.3); // G5
    oscillator2.frequency.exponentialRampToValueAtTime(1046.50, audioContext.currentTime + 0.3); // C6
    
    gainNode.gain.setValueAtTime(0.2, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.4);
    
    oscillator1.start(audioContext.currentTime);
    oscillator2.start(audioContext.currentTime);
    oscillator1.stop(audioContext.currentTime + 0.4);
    oscillator2.stop(audioContext.currentTime + 0.4);
  } catch (e) {
    console.log('Audio not supported or blocked');
  }
}

function createParticles() {
  const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#ffeaa7', '#dda0dd', '#98fb98'];
  for (let i = 0; i < 15; i++) {
    const particle = document.createElement('div');
    particle.className = 'particle';
    particle.style.cssText = `
      position: fixed;
      width: 10px;
      height: 10px;
      background: ${colors[Math.floor(Math.random() * colors.length)]};
      border-radius: 50%;
      pointer-events: none;
      z-index: 1000;
      left: ${Math.random() * window.innerWidth}px;
      top: ${Math.random() * window.innerHeight}px;
      animation: float 2s ease-out forwards;
    `;
    document.body.appendChild(particle);
    setTimeout(() => particle.remove(), 2000);
  }
}// Gam
e Variables
let gameSequence = [];
let playerSequence = [];
let gameLevel = 1;
let gameScore = 0;
let gameActive = false;
let achievements = JSON.parse(localStorage.getItem('vibeAppAchievements') || '[]');

// Color Memory Game Functions
function startGame() {
  console.log('🎮 Starting Color Memory Game!');
  gameSequence = [];
  playerSequence = [];
  gameLevel = 1;
  gameScore = 0;
  gameActive = true;
  
  updateGameScore();
  document.getElementById('game-instructions').textContent = 'Watch the sequence...';
  
  setTimeout(() => {
    addToSequence();
    playSequence();
  }, 1000);
}

function addToSequence() {
  const colors = ['red', 'blue', 'green', 'yellow'];
  const randomColor = colors[Math.floor(Math.random() * colors.length)];
  gameSequence.push(randomColor);
  console.log('🎯 Added to sequence:', randomColor);
}

function playSequence() {
  let i = 0;
  const interval = setInterval(() => {
    if (i >= gameSequence.length) {
      clearInterval(interval);
      document.getElementById('game-instructions').textContent = 'Now repeat the sequence!';
      return;
    }
    
    flashTile(gameSequence[i]);
    i++;
  }, 800);
}

function flashTile(color) {
  const tile = document.querySelector(`[data-color="${color}"]`);
  tile.classList.add('flash');
  
  // Play tile sound
  playTileSound(color);
  
  setTimeout(() => {
    tile.classList.remove('flash');
  }, 500);
}

function gameClick(color) {
  if (!gameActive) return;
  
  console.log('🎯 Player clicked:', color);
  flashTile(color);
  playerSequence.push(color);
  
  // Check if player is correct so far
  const currentIndex = playerSequence.length - 1;
  if (playerSequence[currentIndex] !== gameSequence[currentIndex]) {
    // Wrong! Game over
    gameOver();
    return;
  }
  
  // Check if player completed the sequence
  if (playerSequence.length === gameSequence.length) {
    // Correct sequence completed!
    gameScore += gameLevel * 10;
    gameLevel++;
    playerSequence = [];
    
    updateGameScore();
    document.getElementById('game-instructions').textContent = 'Great! Next level...';
    
    // Check for achievements
    checkGameAchievements();
    
    setTimeout(() => {
      addToSequence();
      playSequence();
    }, 1500);
  }
}

function gameOver() {
  gameActive = false;
  document.getElementById('game-instructions').textContent = `Game Over! Final Score: ${gameScore}`;
  console.log('💀 Game Over! Score:', gameScore);
  
  // Save high score
  const highScore = localStorage.getItem('vibeAppHighScore') || 0;
  if (gameScore > highScore) {
    localStorage.setItem('vibeAppHighScore', gameScore);
    showAchievement('🏆 New High Score!', `You scored ${gameScore} points!`);
  }
}

function updateGameScore() {
  document.getElementById('game-score').textContent = `Score: ${gameScore} | Level: ${gameLevel}`;
}

function playTileSound(color) {
  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    if (audioContext.state === 'suspended') audioContext.resume();
    
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    // Different frequencies for different colors
    const frequencies = {
      red: 261.63,    // C4
      blue: 329.63,   // E4
      green: 392.00,  // G4
      yellow: 523.25  // C5
    };
    
    oscillator.frequency.setValueAtTime(frequencies[color], audioContext.currentTime);
    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
    
    oscillator.start(audioContext.currentTime);
    oscillator.stop(audioContext.currentTime + 0.3);
  } catch (e) {
    console.log('Audio not supported');
  }
}

// Color Palette Functions
function applyPalette(paletteName) {
  console.log('🎨 Applying palette:', paletteName);
  
  const palettes = {
    sunset: ['#ff6b6b', '#ffa726', '#ffcc02'],
    ocean: ['#4ecdc4', '#45b7d1', '#96ceb4'],
    forest: ['#98fb98', '#90ee90', '#8fbc8f'],
    royal: ['#667eea', '#764ba2', '#dda0dd']
  };
  
  const colors = palettes[paletteName];
  if (!colors) return;
  
  // Apply the first color as background
  const selectedColor = colors[0];
  localStorage.setItem('vibeAppBackgroundColor', selectedColor);
  document.body.style.transition = 'background-color 0.8s ease-in-out';
  document.body.style.backgroundColor = selectedColor;
  
  // Create palette particles
  createPaletteParticles(colors);
  
  // Show achievement
  showAchievement('🎨 Palette Applied!', `${paletteName.charAt(0).toUpperCase() + paletteName.slice(1)} theme activated!`);
  
  // Check for palette achievement
  checkPaletteAchievement(paletteName);
}

function createPaletteParticles(colors) {
  for (let i = 0; i < 20; i++) {
    const particle = document.createElement('div');
    particle.style.cssText = `
      position: fixed;
      width: 8px;
      height: 8px;
      background: ${colors[Math.floor(Math.random() * colors.length)]};
      border-radius: 50%;
      pointer-events: none;
      z-index: 1000;
      left: ${Math.random() * window.innerWidth}px;
      top: ${Math.random() * window.innerHeight}px;
      animation: float 3s ease-out forwards;
    `;
    document.body.appendChild(particle);
    setTimeout(() => particle.remove(), 3000);
  }
}

// Achievement System
function showAchievement(title, description) {
  // Remove existing toast if any
  const existingToast = document.querySelector('.achievement-toast');
  if (existingToast) existingToast.remove();
  
  const toast = document.createElement('div');
  toast.className = 'achievement-toast';
  toast.innerHTML = `
    <span class="achievement-icon">🏆</span>
    <div>
      <div style="font-weight: bold;">${title}</div>
      <div style="font-size: 12px; opacity: 0.9;">${description}</div>
    </div>
  `;
  
  document.body.appendChild(toast);
  
  // Animate in
  setTimeout(() => toast.classList.add('show'), 100);
  
  // Animate out
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 500);
  }, 3000);
  
  console.log('🏆 Achievement:', title, description);
}

function checkGameAchievements() {
  if (gameLevel === 5 && !achievements.includes('game_level_5')) {
    achievements.push('game_level_5');
    localStorage.setItem('vibeAppAchievements', JSON.stringify(achievements));
    showAchievement('🎮 Game Master!', 'Reached level 5 in Color Memory!');
  }
  
  if (gameScore >= 100 && !achievements.includes('score_100')) {
    achievements.push('score_100');
    localStorage.setItem('vibeAppAchievements', JSON.stringify(achievements));
    showAchievement('💯 Century Club!', 'Scored 100+ points!');
  }
}

function checkPaletteAchievement(paletteName) {
  const paletteKey = `palette_${paletteName}`;
  if (!achievements.includes(paletteKey)) {
    achievements.push(paletteKey);
    localStorage.setItem('vibeAppAchievements', JSON.stringify(achievements));
  }
  
  // Check if all palettes used
  const allPalettes = ['palette_sunset', 'palette_ocean', 'palette_forest', 'palette_royal'];
  const hasAllPalettes = allPalettes.every(p => achievements.includes(p));
  
  if (hasAllPalettes && !achievements.includes('palette_master')) {
    achievements.push('palette_master');
    localStorage.setItem('vibeAppAchievements', JSON.stringify(achievements));
    showAchievement('🌈 Palette Master!', 'Used all color palettes!');
  }
}

// Check for first visit achievement
document.addEventListener('DOMContentLoaded', function() {
  if (!achievements.includes('first_visit')) {
    achievements.push('first_visit');
    localStorage.setItem('vibeAppAchievements', JSON.stringify(achievements));
    setTimeout(() => {
      showAchievement('👋 Welcome!', 'Thanks for visiting our amazing app!');
    }, 2000);
  }
});