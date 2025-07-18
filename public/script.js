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