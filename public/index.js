  // 現在の設定を取得して表示
function updateCurrentStatus() {
    fetch('/status')
    .then(response => response.json())
    .then(data => {
        document.getElementById('current-text').textContent = data.text;
        document.getElementById('current-color').textContent = data.color;
        document.getElementById('current-font-size').textContent = data.font_size;
        document.getElementById('current-speed').textContent = data.speed;
    });
}

document.querySelectorAll('.faq-question').forEach(question => {
    question.addEventListener('click', () => {
        question.classList.toggle('active');
        const answer = question.nextElementSibling;
        answer.style.display = (answer.style.display === 'block') ? 'none' : 'block';
    });
});

  // ページ読み込み時に現在の設定を表示
window.onload = updateCurrentStatus;