<script src="https://cdn.jsdelivr.net/npm/devtools-detect@1.2.0/dist/devtools-detect.min.js"></script>
<script>
    (function() {
        if (window.devtools.isOpen) {
            document.body.innerHTML = "<h1>Developer tools detected! Access denied.</h1>";
        }
        window.addEventListener('devtoolschange', function (e) {
            if (e.detail.isOpen) {
                document.body.innerHTML = "<h1>Developer tools detected! Access denied.</h1>";
            }
        });
    })();
</script>


<script>
    document.addEventListener('keydown', (event) => {
        // F12
        if (event.key === 'F12') {
            event.preventDefault();
        }
        // Ctrl + Shift + I (Inspect)
        if (event.ctrlKey && event.shiftKey && event.key === 'I') {
            event.preventDefault();
        }
        // Ctrl + U (View Source)
        if (event.ctrlKey && event.key === 'U') {
            event.preventDefault();
        }
    });
</script>


<script>
    document.addEventListener('contextmenu', event => event.preventDefault());
</script>
