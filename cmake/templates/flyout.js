"use strict";

// 語言與版本列表（按順序排列）
const _ALL_LANGUAGES = [
  ["en-us", "English"],
  ["ja-jp", "日本語"],
  ["ru-ru", "Русский"],
  ["zh-cn", "简体中文"],
  ["zh-tw", "繁體中文"],
];
const _ALL_VERSIONS = [
  ["master", "master"],
  ["latest", "latest"],
  ["3.30", "3.30"],
  ["3.29", "3.29"],
  ["3.26", "3.26"],
  ["3.25", "3.25"],
  ["3.24", "3.24"],
  ["3.23", "3.23"],
  ["3.22", "3.22"],
  ["3.20", "3.20"],
  ["3.19", "3.19"],
  ["3.18", "3.18"],
  ["3.17", "3.17"],
  ["3.16", "3.16"],
  ["3.15", "3.15"],
  ["3.14", "3.14"],
  ["3.13", "3.13"],
  ["3.12", "3.12"],
  ["3.11", "3.11"],
  ["3.10", "3.10"],
  ["3.9", "3.9"],
  ["3.8", "3.8"],
  ["3.7", "3.7"],
  ["3.6", "3.6"],
  ["3.5", "3.5"],
  ["3.4", "3.4"],
  ["3.3", "3.3"],
  ["3.2", "3.2"],
  ["3.1", "3.1"],
  ["3.0", "3.0"],
];
const _ALL_PROJECTS = [
  ["Crowdin", "https://org-test.crowdin.com/cmake-docs-l10n"],
  ["GitHub",  "https://github.com/hwhsu1231/cmake-docs-l10n-v7"],
  ["GitCode", "https://gitcode.com/hwhsu1231/cmake-docs-l10n-v7"],
  ["GitFlic", "https://gitflic.ru/project/hwhsu1231/cmake-docs-l10n-v7"],
];

// 
const _is_file_uri = (uri) => uri.startsWith("file:/");
const _IS_LOCAL = _is_file_uri(window.location.href);
const _CURRENT_VERSION  = SWITCHERS_OPTIONS.CURRENT_VERSION;
const _CURRENT_LANGUAGE = SWITCHERS_OPTIONS.CURRENT_LANGUAGE;
const _HTML_BASEURL     = SWITCHERS_OPTIONS.HTML_BASEURL;
const _SERVER_ROOT      = window.location.origin;

// function getTargetUrl(type, selectedValue) {
//   const currentPath = window.location.pathname;
//   let targetPath;
//   if (type === "language") {
//     targetPath = currentPath.replace(`/${_CURRENT_LANGUAGE}/`, `/${selectedValue}/`);
//   } else if (type === "version") {
//     targetPath = currentPath.replace(`/${_CURRENT_VERSION}/`, `/${selectedValue}/`);
//   }
//   return _IS_LOCAL ? `file://${targetPath}` : `${_SERVER_ROOT}${targetPath}`;
// }

async function getTargetUrl(type, selectedValue) {
  const currentPath = window.location.pathname;
  let targetPath;

  if (type === "language") {
    targetPath = currentPath.replace(`/${_CURRENT_LANGUAGE}/`, `/${selectedValue}/`);
  } else if (type === "version") {
    targetPath = currentPath.replace(`/${_CURRENT_VERSION}/`, `/${selectedValue}/`);
  }

  const targetUrl = _IS_LOCAL
    ? `file://${targetPath}`
    : `${_SERVER_ROOT}${targetPath}`;

  // 如果是本地模式，直接返回
  if (_IS_LOCAL) return targetUrl;

  try {
    // 檢查目標頁面是否存在
    const response = await fetch(targetUrl, { method: "HEAD" });
    if (response.ok) {
      return targetUrl; // 目標存在，回傳該網址
    } else {
      console.warn("目標網址不存在，使用備用網址:", targetUrl);
    }
  } catch (error) {
    console.error("檢查目標網址時出錯:", error);
  }

  // 返回預設備用網址
  return `${_HTML_BASEURL}/${type === "language" ? selectedValue : _CURRENT_LANGUAGE}/${type === "version" ? selectedValue : _CURRENT_VERSION}/index.html`;
}

// **跳轉邏輯**
async function switchVersionOrLanguage(type, selectedValue) {
  const currentPath = window.location.pathname;
  let targetPath;

  if (type === "language") {
    targetPath = currentPath.replace(`/${_CURRENT_LANGUAGE}/`, `/${selectedValue}/`);
  } else if (type === "version") {
    targetPath = currentPath.replace(`/${_CURRENT_VERSION}/`, `/${selectedValue}/`);
  }

  const targetUrl = _IS_LOCAL
    ? `file://${targetPath}`
    : `${_SERVER_ROOT}${targetPath}`;

  if (targetPath !== currentPath) {
    if (_IS_LOCAL) {
      window.location.href = targetUrl; // 直接跳轉
    } else {
      try {
        const response = await fetch(targetUrl, { method: "HEAD" });
        if (response.ok) {
          window.location.href = targetUrl; // 目標存在，跳轉
        } else {
          console.error("Target file not found, redirecting to fallback.");
          const fallbackUrl = `${_HTML_BASEURL}/${type === "language" ? selectedValue : _CURRENT_LANGUAGE}/${type === "version" ? selectedValue : _CURRENT_VERSION}/index.html`;
          window.location.href = fallbackUrl;
        }
      } catch (error) {
        console.error("Error checking target URL:", error);
      }
    }
  }
}

// 生成語言與版本的 HTML 列表
function createFlyout() {
  const sortedLanguages = _ALL_LANGUAGES.map(([code, name]) => `
    <a href="#"
      title="${name}"
      class="${code === _CURRENT_LANGUAGE ? "selected" : ""}"
      onmouseover="getTargetUrl('language', '${code}').then(url => this.href = url)">
      ${code}
    </a>
  `).join("");

  // const sortedLanguages = _ALL_LANGUAGES.map(([code, name]) => `
  //   <a href="javascript:void(0);"
  //     title="${name}"
  //     class="${code === _CURRENT_LANGUAGE ? "selected" : ""}"
  //     onclick="switchVersionOrLanguage('language', '${code}')">
  //     ${code}
  //   </a>
  // `).join("");

  const sortedVersions = _ALL_VERSIONS.map(([code, name]) => `
    <a href="#"
      title="${name}"
      class="${code === _CURRENT_VERSION ? "selected" : ""}"
      onmouseover="getTargetUrl('version', '${code}').then(url => this.href = url)">
      ${code}
    </a>
  `).join("");

  // const sortedVersions = _ALL_VERSIONS.map(([code, name]) => `
  //   <a href="javascript:void(0);"
  //     title="${name}"
  //     class="${code === _CURRENT_VERSION ? "selected" : ""}"
  //     onclick="switchVersionOrLanguage('version', '${code}')">
  //     ${code}
  //   </a>
  // `).join("");

  const sortedProjects = _ALL_PROJECTS.map(([project, link]) => `
    <a href="${link}">
      ${project}
    </a>
  `).join("");

  const flyoutHTML = `
    <div class="rtd-flyout">
      <span class="rtd-flyout-header">
        Language: ${_CURRENT_LANGUAGE} | Version: ${_CURRENT_VERSION}
        <span class="fa fa-caret-down"></span>
      </span>
      <div class="rtd-flyout-content closed">
        <dl>
          <dt>Languages</dt>
          <dd class="options">${sortedLanguages}</dd>
        </dl>
        <dl>
          <dt>Versions</dt>
          <dd class="options">${sortedVersions}</dd>
        </dl>
        <dl>
          <dt>Project Links</dt>
          <dd class="options">${sortedProjects}</dd>
        </dl>
      </div>
    </div>
  `;

  document.body.insertAdjacentHTML("beforeend", flyoutHTML);

  const flyout = document.querySelector(".rtd-flyout");
  const header = document.querySelector(".rtd-flyout-header");
  const content = document.querySelector(".rtd-flyout-content");

  content.classList.add("closed");

  function toggleFlyout(event) {
    const isHidden = content.classList.contains("closed");
    content.classList.toggle("closed", !isHidden);
    localStorage.setItem("rtd-flyout-collapsed", !isHidden);
    event.stopPropagation();
  }

  function closeFlyout(event) {
    if (!flyout.contains(event.target)) {
      content.classList.add("closed");
      localStorage.setItem("rtd-flyout-collapsed", "true");
    }
  }

  header.addEventListener("click", toggleFlyout);
  document.addEventListener("click", closeFlyout);
}

// 加載 CSS
function addStyles() {
  const css = `
    .rtd-flyout {
      position: fixed;
      right: 20px;
      bottom: 40px;
      background-color: #272725;
      color: rgb(252, 252, 252);
      font-family: Arial, sans-serif;
      font-size: 1.0rem;
      z-index: 5000;
      border-radius: 5px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
      padding: 5px;
      width: auto;
      min-width: 200px;
      max-width: 300px;
    }

    .rtd-flyout-header {
      display: block;
      text-align: right;
      padding: 10px 10px;
      cursor: pointer;
      background-color: #272725;
      font-weight: bold;
      color: #27ae60;
      position: relative;
    }

    .rtd-flyout-header .fa-caret-down {
      position: absolute;
      right: 10px;
      top: 50%;
      transform: translateY(-50%);
      color: #27ae60;
    }

    .rtd-flyout-content {
      padding: 10px;
      background: #272725;
    }

    .rtd-flyout-content.closed {
      display: none;
    }

    dl {
      margin: 0;
      padding: 0;
    }

    dt {
      font-size: 1.0rem;
      color: rgb(128, 128, 128);
      font-weight: bold;
      text-align: left;
      padding: 5px 3px;
    }

    dd {
      margin: 0;
      padding: 0;
    }

    dd.options {
      display: flex;
      flex-wrap: wrap;
      gap: 5px;
      justify-content: flex-start;
    }

    dd.options a {
      text-decoration: none;
      color: rgb(252, 252, 252);
      background-color: #272725;
      padding: 1px 3px;
      display: inline-block;
      border-radius: 3px;
      transition: background 0.3s;
      font-size: 1.0rem;
    }

    dd.options a:hover {
      background-color: #27ae60;
    }

    dd.options a.selected {
      background-color: #27ae60;
      font-weight: bold;
      color: white;
    }
  `;

  const styleTag = document.createElement("style");
  styleTag.innerHTML = css;
  document.head.appendChild(styleTag);
}

// 初始化
document.addEventListener("DOMContentLoaded", () => {
  addStyles();
  createFlyout();
});
