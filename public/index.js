// document.querySelectorAll('.faq-question').forEach(question => {
//     question.addEventListener('click', () => {
//         question.classList.toggle('active');
//         const answer = question.nextElementSibling;
//         answer.style.display = (answer.style.display === 'block') ? 'none' : 'block';
//     });
// });

function setupFaqToggle() {
    document.querySelectorAll('.faq-question').forEach(question => {
        question.addEventListener('click', () => {
            question.classList.toggle('active');
            const answer = question.nextElementSibling;
            if (answer.style.display === 'block') {
                answer.style.display = 'none';
            } else {
                answer.style.display = 'block';
            }
        });
    });
}

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

// ページ読み込み時に両方実行
window.onload = function() {
    setupFaqToggle();
    updateCurrentStatus();
};