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
        // 色の変換
        const colorMap = { "1": "赤", "2": "緑", "3": "青", "4": "黄", "5": "白" };
        // 大きさの変換
        const fontSizeMap = { "1": "小", "2": "中", "3": "大" };
        // 速度の変換
        const speedMap = { "1": "遅い", "2": "普通", "3": "早い" };

        document.getElementById('current-text').textContent =
            data.text && data.text.trim() !== "" ? data.text : '未設定';
        document.getElementById('current-color').textContent =
            colorMap[data.color] || '未設定';
        document.getElementById('current-font-size').textContent =
            fontSizeMap[data.font_size] || '未設定';
        document.getElementById('current-speed').textContent =
            speedMap[data.speed] || '未設定';
    });
}

// ページ読み込み時に両方実行
window.onload = function() {
    setupFaqToggle();
    updateCurrentStatus();
};