import json
import os

def setup(app):
    """Sphinx extension entry point."""

    default_config_values = {
        "switchers": None,
        "html_baseurl": None,
        "current_version": None,
        "current_language": None,
    }

    for key, default in default_config_values.items():
        if key not in app.config.values:
            app.add_config_value(key, default, "env")

    def on_builder_inited(app):
        # Pass current_version and current_language to html_context
        app.config.html_context["switchers"] = app.config.switchers
        app.config.html_context["html_baseurl"] = app.config.html_baseurl
        app.config.html_context["current_version"] = app.config.current_version
        app.config.html_context["current_language"] = app.config.current_language

    app.connect("builder-inited", on_builder_inited)

    return {
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
