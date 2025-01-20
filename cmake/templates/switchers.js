"use strict";

// 確認是否為本機檔案
const _is_file_uri = (uri) => uri.startsWith("file:/");
const _IS_LOCAL = _is_file_uri(window.location.href);
const _CURRENT_VERSION  = CURRENT_VERSION;
const _CURRENT_LANGUAGE = CURRENT_LANGUAGE;
const _SERVER_ROOT = document.documentElement.dataset.content_root || `${window.location.origin}`;
const _SCRIPT_SRC = document.currentScript?.src || "";
const _SCRIPT_DIR = _SCRIPT_SRC.substring(0, _SCRIPT_SRC.lastIndexOf("/"));
// alert(`_SCRIPT_DIR: ${_SCRIPT_DIR}`);
// alert(`_SERVER_ROOT: ${_SERVER_ROOT}`);

// 所有版本和語言的選項
const _ALL_VERSIONS = {
  'git-master': 'git-master',
  'latest': 'latest release',
  '3.30': '3.30',
  '3.29': '3.29',
  '3.28': '3.28',
  '3.27': '3.27',
  '3.26': '3.26',
  '3.25': '3.25',
  '3.24': '3.24',
  '3.23': '3.23',
  '3.22': '3.22',
  '3.21': '3.21',
  '3.20': '3.20',
  '3.19': '3.19',
  '3.18': '3.18',
  '3.17': '3.17',
  '3.16': '3.16',
  '3.15': '3.15',
  '3.14': '3.14',
  '3.13': '3.13',
  '3.12': '3.12',
  '3.11': '3.11',
  '3.10': '3.10',
  '3.9': '3.9',
  '3.8': '3.8',
  '3.7': '3.7',
  '3.6': '3.6',
  '3.5': '3.5',
  '3.4': '3.4',
  '3.3': '3.3',
  '3.2': '3.2',
  '3.1': '3.1',
  '3.0': '3.0'
};

const _ALL_LANGUAGES = {
  "en-us" : "English",
  "ja-jp" : "日本語",
  "ru-ru" : "Русский",
  "zh-cn" : "简体中文",
  "zh-tw" : "繁體中文",
};

// 生成版本選單
const _create_version_select = (versions) => {
  const select = document.createElement("select");
  select.className = "version-select";

  for (const [version, title] of Object.entries(versions)) {
    const option = document.createElement("option");
    option.value = version;
    option.text = title;
    if (version === _CURRENT_VERSION) option.selected = true;
    select.add(option);
  }

  select.addEventListener("change", async (event) => {
    const current_path = window.location.pathname;
    const selected_version = event.target.value;
    const selected_path = current_path.replace(
      `/${_CURRENT_VERSION}/`,
      `/${selected_version}/`
    );

    const target_url = _IS_LOCAL
      ? `file://${selected_path}`
      : `${_SERVER_ROOT}${selected_path}`;

    if (selected_path !== current_path) {
      if (_IS_LOCAL) {
        window.location.href = target_url;  // 直接嘗試跳轉
      } else {
        try {
          const response = await fetch(target_url, { method: "HEAD" });
          if (response.ok) {
            window.location.href = target_url;  // 目標存在，跳轉到目標頁面
          } else {
            console.error("Target file not found, redirecting to fallback.");
            const fallbackUrl = `${_SCRIPT_DIR}/${_CURRENT_LANGUAGE}/${selected_version}/`;
            window.location.href = fallbackUrl;
          }
        } catch (error) {
          console.error("Error checking target URL:", error);
        }
      }
    }
  });

  return select;
};

// 生成語言選單
const _create_language_select = (languages) => {
  const select = document.createElement("select");
  select.className = "language-select";

  for (const [language, title] of Object.entries(languages)) {
    const option = document.createElement("option");
    option.value = language;
    option.text = title;
    if (language === _CURRENT_LANGUAGE) option.selected = true;
    select.add(option);
  }

  select.addEventListener("change", async (event) => {
    const current_path = window.location.pathname;
    const selected_language = event.target.value;
    const selected_path = current_path.replace(
      `/${_CURRENT_LANGUAGE}/`,
      `/${selected_language}/`
    );

    const target_url = _IS_LOCAL
      ? `file://${selected_path}`
      : `${_SERVER_ROOT}${selected_path}`;

    if (selected_path !== current_path) {
      if (_IS_LOCAL) {
        window.location.href = target_url;  // 直接嘗試跳轉
      } else {
        try {
          const response = await fetch(target_url, { method: "HEAD" });
          if (response.ok) {
            window.location.href = target_url;  // 目標存在，跳轉到目標頁面
          } else {
            console.error("Target file not found, redirecting to fallback.");
            const fallbackUrl = `${_SCRIPT_DIR}/${selected_language}/${_CURRENT_VERSION}/`;
            window.location.href = fallbackUrl;
          }
        } catch (error) {
          console.error("Error checking target URL:", error);
        }
      }
    }
  });

  return select;
};


// 初始化選單
const _initialise_switchers = () => {
  const versions = _ALL_VERSIONS;
  const languages = _ALL_LANGUAGES;

  document
    .querySelectorAll(".version_switcher_placeholder")
    .forEach((placeholder) => {
      placeholder.append(_create_version_select(versions));
    });

  document
    .querySelectorAll(".language_switcher_placeholder")
    .forEach((placeholder) => {
      placeholder.append(_create_language_select(languages));
    });
};

// DOM 加載完成後初始化
if (document.readyState !== "loading") {
  _initialise_switchers();
} else {
  document.addEventListener("DOMContentLoaded", _initialise_switchers);
}
