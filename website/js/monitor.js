/*
=========================================================
 LinuxOps Enterprise Server
 File: website/js/monitor.js
 Description:
 Frontend System Monitor Simulation Dashboard
=========================================================
*/

"use strict";

const monitor = {
  cpu: 0,
  memory: 0,
  disk: 0,
  network: 0,
  uptime: "0 Days",
  users: 0,
  firewall: "Active",
  nginx: "Running",
  samba: "Running",
  lastUpdated: "--"
};

function random(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomStatus() {
  return Math.random() > 0.1 ? "Running" : "Stopped";
}

function getUptime() {
  const days = random(1, 365);
  const hours = random(0, 23);
  return `${days} Days ${hours} Hours`;
}

function updateMonitorData() {

  monitor.cpu = random(5, 95);
  monitor.memory = random(10, 90);
  monitor.disk = random(15, 92);
  monitor.network = random(20, 1000);

  monitor.users = random(1, 20);

  monitor.nginx = randomStatus();
  monitor.samba = randomStatus();
  monitor.firewall = "Active";
  monitor.uptime = getUptime();

  monitor.lastUpdated = new Date().toLocaleTimeString();

  renderDashboard();
}

function progressColor(value) {

  if (value < 50)
    return "#16a34a";

  if (value < 75)
    return "#f59e0b";

  return "#dc2626";
}

function setProgress(id, value) {

  const bar = document.getElementById(id);

  if (!bar)
    return;

  bar.style.width = value + "%";
  bar.style.background = progressColor(value);

}

function setText(id, value) {

  const el = document.getElementById(id);

  if (el)
    el.textContent = value;

}

function renderDashboard() {

  setText("cpu-value", monitor.cpu + "%");
  setText("memory-value", monitor.memory + "%");
  setText("disk-value", monitor.disk + "%");
  setText("network-value", monitor.network + " Mbps");
  setText("uptime-value", monitor.uptime);
  setText("users-value", monitor.users);

  setText("nginx-status", monitor.nginx);
  setText("samba-status", monitor.samba);
  setText("firewall-status", monitor.firewall);

  setText("last-updated", monitor.lastUpdated);

  setProgress("cpu-progress", monitor.cpu);
  setProgress("memory-progress", monitor.memory);
  setProgress("disk-progress", monitor.disk);

  checkAlerts();

}

function checkAlerts() {

  const alerts = [];

  if (monitor.cpu >= 80)
    alerts.push("⚠ High CPU Usage");

  if (monitor.memory >= 80)
    alerts.push("⚠ High Memory Usage");

  if (monitor.disk >= 90)
    alerts.push("⚠ Disk Almost Full");

  if (monitor.nginx === "Stopped")
    alerts.push("❌ Nginx Service Down");

  if (monitor.samba === "Stopped")
    alerts.push("❌ Samba Service Down");

  const alertBox = document.getElementById("alerts");

  if (!alertBox)
    return;

  if (alerts.length === 0) {

    alertBox.innerHTML =
      "<div class='success'>✅ System Healthy</div>";

    return;

  }

  alertBox.innerHTML = "";

  alerts.forEach(function (msg) {

    const div = document.createElement("div");
    div.className = "warning";
    div.textContent = msg;

    alertBox.appendChild(div);

  });

}

function createCards() {

  const dashboard = document.getElementById("dashboard");

  if (!dashboard)
    return;

  dashboard.innerHTML = `

<div class="card">
<h3>CPU Usage</h3>
<p id="cpu-value">0%</p>
<div class="progress">
<div id="cpu-progress" class="progress-bar"></div>
</div>
</div>

<div class="card">
<h3>Memory Usage</h3>
<p id="memory-value">0%</p>
<div class="progress">
<div id="memory-progress" class="progress-bar"></div>
</div>
</div>

<div class="card">
<h3>Disk Usage</h3>
<p id="disk-value">0%</p>
<div class="progress">
<div id="disk-progress" class="progress-bar"></div>
</div>
</div>

<div class="card">
<h3>Network Speed</h3>
<p id="network-value">0 Mbps</p>
</div>

<div class="card">
<h3>Logged Users</h3>
<p id="users-value">0</p>
</div>

<div class="card">
<h3>System Uptime</h3>
<p id="uptime-value">--</p>
</div>

<div class="card">
<h3>Nginx</h3>
<p id="nginx-status">--</p>
</div>

<div class="card">
<h3>Samba</h3>
<p id="samba-status">--</p>
</div>

<div class="card">
<h3>Firewall</h3>
<p id="firewall-status">--</p>
</div>

`;

}

function createAlertContainer() {

  if (document.getElementById("alerts"))
    return;

  const container = document.createElement("div");

  container.id = "alerts";

  container.style.marginTop = "30px";

  document.body.appendChild(container);

}

function createFooter() {

  if (document.getElementById("monitor-footer"))
    return;

  const footer = document.createElement("div");

  footer.id = "monitor-footer";

  footer.style.marginTop = "30px";
  footer.style.padding = "20px";
  footer.style.textAlign = "center";
  footer.style.fontWeight = "bold";

  footer.innerHTML = `
Last Updated:
<span id="last-updated">--</span>
`;

  document.body.appendChild(footer);

}

function initializeMonitor() {

  createCards();

  createAlertContainer();

  createFooter();

  updateMonitorData();

  setInterval(updateMonitorData, 5000);

}

document.addEventListener("DOMContentLoaded", initializeMonitor);