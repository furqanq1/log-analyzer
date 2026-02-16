function loadReport() {
  fetch("/reports/latest.txt")
    .then(r => r.text())
    .then(t => document.getElementById("output").innerText = t)
    .catch(() => document.getElementById("output").innerText = "Error loading report");
}

function downloadReport() {
  const link = document.createElement("a");
  link.href = "/reports/latest.txt";
  link.download = "latest-report.txt";
  link.click();
}
