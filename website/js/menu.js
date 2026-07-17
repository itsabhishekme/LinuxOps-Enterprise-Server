/**
 * LinuxOps Enterprise Server
 * website/js/menu.js
 * ------------------------------------
 * Navigation Menu Controller
 * Author: Abhishek Shrivastava
 * Version: 1.0
 */

document.addEventListener("DOMContentLoaded", () => {
    initializeMenu();
    initializeScrollSpy();
    initializeBackToTop();
});

/* ================================
   Mobile Menu
================================ */

function initializeMenu() {
    const menuButton = document.getElementById("menu-toggle");
    const navigation = document.getElementById("navigation");

    if (!menuButton || !navigation) return;

    menuButton.addEventListener("click", () => {
        navigation.classList.toggle("active");

        menuButton.setAttribute(
            "aria-expanded",
            navigation.classList.contains("active")
        );
    });

    document.querySelectorAll("#navigation a").forEach((link) => {
        link.addEventListener("click", () => {
            navigation.classList.remove("active");
            menuButton.setAttribute("aria-expanded", "false");
        });
    });
}

/* ================================
   Active Navigation
================================ */

function initializeScrollSpy() {
    const sections = document.querySelectorAll("section[id]");
    const navLinks = document.querySelectorAll("#navigation a");

    if (sections.length === 0 || navLinks.length === 0) return;

    window.addEventListener("scroll", () => {
        let current = "";

        sections.forEach((section) => {
            const sectionTop = section.offsetTop - 120;
            const sectionHeight = section.offsetHeight;

            if (
                window.scrollY >= sectionTop &&
                window.scrollY < sectionTop + sectionHeight
            ) {
                current = section.getAttribute("id");
            }
        });

        navLinks.forEach((link) => {
            link.classList.remove("active");

            if (link.getAttribute("href") === "#" + current) {
                link.classList.add("active");
            }
        });
    });
}

/* ================================
   Smooth Scrolling
================================ */

document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (event) {
        event.preventDefault();

        const target = document.querySelector(this.getAttribute("href"));

        if (target) {
            target.scrollIntoView({
                behavior: "smooth",
                block: "start",
            });
        }
    });
});

/* ================================
   Sticky Header Shadow
================================ */

window.addEventListener("scroll", () => {
    const header = document.querySelector("header");

    if (!header) return;

    if (window.scrollY > 20) {
        header.style.boxShadow = "0 8px 20px rgba(0,0,0,.35)";
    } else {
        header.style.boxShadow = "none";
    }
});

/* ================================
   Back To Top Button
================================ */

function initializeBackToTop() {
    const button = document.getElementById("backToTop");

    if (!button) return;

    window.addEventListener("scroll", () => {
        if (window.scrollY > 400) {
            button.style.display = "block";
        } else {
            button.style.display = "none";
        }
    });

    button.addEventListener("click", () => {
        window.scrollTo({
            top: 0,
            behavior: "smooth",
        });
    });
}

/* ================================
   Console Information
================================ */

console.log(`
=========================================
 LinuxOps Enterprise Server
=========================================

Website Status : Running
Version        : 1.0.0
JavaScript     : Loaded Successfully

Modules

✔ User Management
✔ Backup Manager
✔ System Monitor
✔ Nginx Web Server
✔ Samba File Sharing
✔ Firewall
✔ Port Scanner
✔ Reports

=========================================
`);