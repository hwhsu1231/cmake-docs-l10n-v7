import json
import os

# Default configuration values
DEFAULT_CONFIG_VALUES = {
    "enable_switchers"  : 0,
    "current_version"   : "",
    "current_language"  : "",
    "html_baseurl"      : "",
}

def add_default_config_values(app):
    """
    Add default configuration values to the Sphinx app if not already defined.
    """
    for key, default in DEFAULT_CONFIG_VALUES.items():
        if key not in app.config.values:
            app.add_config_value(key, default, "env")

def configure_html_context(app):
    """
    Configure the html_context with necessary switchers, base URL,
    current version, and current language for Sphinx HTML output.
    """
    for key in DEFAULT_CONFIG_VALUES.keys():
        app.config.html_context[key] = getattr(app.config, key, "")
    # app.config.html_context["enable_switchers"] = app.config.enable_switchers
    # app.config.html_context["current_version"] = app.config.current_version
    # app.config.html_context["current_language"] = app.config.current_language
    # app.config.html_context["html_baseurl"] = app.config.html_baseurl

def setup(app):
    """
    Sphinx extension entry point.
    """
    add_default_config_values(app)
    app.connect("builder-inited", configure_html_context)
    return {
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
