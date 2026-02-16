const out = document.getElementById('output');
const statusEl = document.getElementById('status');
const btnShow = document.getElementById('btnShow');
const btnDownload = document.getElementById('btnDownload');
const autoChk = document.getElementById('autoChk');
let timer = null;

async function loadReport() {
  statusEl.textContent = 'Loading...';
  try {
    const url = '/reports/latest.txt?ts=' + Date.now(); // cache-bust
    const res = await fetch(url, { cache: 'no-store' });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const text = await res.text();
    out.textContent = text || 'Report empty.';
    statusEl.textContent = 'Loaded ✓';
  } catch (e) {
    out.textContent = 'Failed to load report: ' + e.message;
    statusEl.textContent = 'Failed ✗';
  }
}

function downloadReport() {
  const a = document.createElement('a');
  a.href = '/reports/latest.txt?ts=' + Date.now();
  a.download = 'latest-report.txt';
  a.click();
}

function toggleAuto() {
  if (autoChk.checked) {
    loadReport();
    timer = setInterval(loadReport, 10000); // 10s
    statusEl.textContent = 'Auto‑refresh ON';
  } else {
    if (timer) clearInterval(timer);
    statusEl.textContent = 'Auto‑refresh OFF';
  }
}

btnShow.addEventListener('click', loadReport);
btnDownload.addEventListener('click', downloadReport);
autoChk.addEventListener('change', toggleAuto);
