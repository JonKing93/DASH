---
---
This is a test page not under a heading.

{% assign tabs = "docs,showcase,resources" | split: "," %}

{% assign bool = "hello"=="hello" %}
{% if bool %}
Hello
{% endif %}

{% if tabs[4]==nil %}
Hi
{% endif %}
