document.addEventListener('DOMContentLoaded', function() {
    function updateProgressBar() {
        const article = document.querySelector('.post-content');
        if (!article) return; 

        const scrollY = window.scrollY;
        const articleHeight = article.scrollHeight;
        const articleTop = article.getBoundingClientRect().top + window.pageYOffset;
        const viewportHeight = window.innerHeight;

        const totalScrollable = articleHeight - viewportHeight;
        const currentProgress = window.pageYOffset - (articleTop - 100); // 稍微提前開始

        let progress = (currentProgress / totalScrollable) * 100;
        progress = Math.max(0, Math.min(100, progress));

        const progressBar = document.querySelector('.reading-progress-bar');
        if (progressBar) {
            progressBar.style.width = progress + '%';
        }
    }

    window.addEventListener('scroll', updateProgressBar);
    updateProgressBar();
});