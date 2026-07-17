"use strict";

/*
=========================================================
 LinuxOps Enterprise Server
 Main JavaScript
=========================================================
*/

document.addEventListener("DOMContentLoaded", () => {
    console.log("LinuxOps Enterprise Server Loaded");

    initializeApplication();
});

function initializeApplication() {
    updateCurrentDate();
    updateSystemStatus();
    animateCounters();
    initializeSmoothScroll();
    initializeBackToTop();
}

/* ==========================================
   Current Date
========================================== */

function updateCurrentDate() {
    const dateElement = document.getElementById("current-date");

    if (!dateElement) return;

    const today = new Date();

    dateElement.textContent = today.toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric"
    });
}

/* ==========================================
   Demo System Status
========================================== */

function updateSystemStatus() {

    const cpu = document.getElementById("cpu");
    const memory = document.getElementById("memory");
    const disk = document.getElementById("disk");
    const uptime = document.getElementById("uptime");

    if (cpu)
        cpu.textContent = randomNumber(15, 60) + "%";

    if (memory)
        memory.textContent = randomNumber(20, 70) + "%";

    if (disk)
        disk.textContent = randomNumber(30, 80) + "%";

    if (uptime)
        uptime.textContent = randomNumber(5, 150) + " Days";

}

setInterval(updateSystemStatus, 5000);

/* ==========================================
   Animated Counters
========================================== */

function animateCounters() {

    const counters = document.querySelectorAll("[data-count]");

    counters.forEach(counter => {

        const target = Number(counter.dataset.count);

        let current = 0;

        const increment = Math.ceil(target / 100);

        const timer = setInterval(() => {

            current += increment;

            if (current >= target) {

                counter.textContent = target;

                clearInterval(timer);

            } else {

                counter.textContent = current;

            }

        }, 20);

    });

}

/* ==========================================
   Smooth Scroll
========================================== */

function initializeSmoothScroll() {

    const links = document.querySelectorAll('a[href^="#"]');

    links.forEach(link => {

        link.addEventListener("click", function (e) {

            const target = document.querySelector(this.getAttribute("href"));

            if (!target)
                return;

            e.preventDefault();

            target.scrollIntoView({

                behavior: "smooth"

            });

        });

    });

}

/* ==========================================
   Back To Top Button
========================================== */

function initializeBackToTop() {

    const button = document.getElementById("backToTop");

    if (!button)
        return;

    window.addEventListener("scroll", () => {

        if (window.scrollY > 500) {

            button.style.display = "block";

        } else {

            button.style.display = "none";

        }

    });

    button.addEventListener("click", () => {

        window.scrollTo({

            top: 0,

            behavior: "smooth"

        });

    });

}

/* ==========================================
   Alert Box
========================================== */

function showAlert(message, type = "info") {

    const alertBox = document.createElement("div");

    alertBox.className = `alert ${type}`;

    alertBox.textContent = message;

    document.body.appendChild(alertBox);

    setTimeout(() => {

        alertBox.remove();

    }, 3000);

}

/* ==========================================
   Copy Text
========================================== */

function copyText(id) {

    const element = document.getElementById(id);

    if (!element)
        return;

    navigator.clipboard.writeText(element.textContent);

    showAlert("Copied to Clipboard", "success");

}

/* ==========================================
   Theme Toggle
========================================== */

function toggleTheme() {

    document.body.classList.toggle("dark-theme");

    const mode = document.body.classList.contains("dark-theme")
        ? "dark"
        : "light";

    localStorage.setItem("theme", mode);

}

(function loadTheme() {

    const theme = localStorage.getItem("theme");

    if (theme === "dark") {

        document.body.classList.add("dark-theme");

    }

})();

/* ==========================================
   Utility
========================================== */

function randomNumber(min, max) {

    return Math.floor(Math.random() * (max - min + 1)) + min;

}

/* ==========================================
   Console Banner
========================================== */

console.log(`
==========================================
 LinuxOps Enterprise Server
------------------------------------------
 Linux System Administration Project

 Modules

 ✔ User Management
 ✔ Backup Manager
 ✔ Nginx Web Server
 ✔ Samba File Sharing
 ✔ System Monitoring
 ✔ Firewall
 ✔ Port Scanner
 ✔ Reporting
 ✔ Cron Automation

 Developed By:
 Abhishek Shrivastava
==========================================
`);